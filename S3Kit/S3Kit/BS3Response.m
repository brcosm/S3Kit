//
//  BS3Response.m
//  BS3Request
//
//  Created by Brandon Smith on 7/15/12.
//  Copyright (c) 2012 TokenGnome. All rights reserved.
//

#import "BS3Response.h"
#import "BS3Parser.h"

static NSDateFormatter *_s3DateFormat;

@implementation BS3Response
@synthesize parser;
@synthesize data = _data, error = _error;
@synthesize dataDictionary = _dataDictionary, type = _type;

+ (NSDictionary *)parseBucket:(NSDictionary *)rawDict {
    NSDate *creationDate = [_s3DateFormat dateFromString:[rawDict objectForKey:@"CreationDate"]];
    NSString *name = [rawDict objectForKey:@"Name"];
    return [NSDictionary dictionaryWithObjectsAndKeys:creationDate, @"creationDate", name, @"name", nil];
}

+ (NSDictionary *)parseObject:(NSDictionary *)rawDict {
    NSDate *lastModified = [_s3DateFormat dateFromString:[rawDict objectForKey:@"LastModified"]];
    NSString *name = [rawDict objectForKey:@"Key"];
    NSString *tag = [rawDict objectForKey:@"ETag"];
    NSNumber *size = [rawDict objectForKey:@"Size"];
    NSString *ownerName = [rawDict valueForKeyPath:@"Owner.DisplayName"];
    return [NSDictionary dictionaryWithObjectsAndKeys:lastModified, @"lastModified", name, @"name", tag, @"tag", size, @"size", ownerName, @"ownerName", nil];
}

+ (NSDictionary *)parseListAllMyBucketsResult:(NSDictionary *)rawDict {
    NSMutableDictionary *bucketListResponse = [NSMutableDictionary dictionary];
    [bucketListResponse setValue:@"ListAllMyBucketsResult" forKey:@"type"];
    id buckets = [rawDict valueForKeyPath:@"ListAllMyBucketsResult.Buckets.Bucket"];
    NSMutableArray *parsedBuckets = [NSMutableArray array];
    if (![buckets isKindOfClass:[NSArray class]]) {
        buckets = [NSArray arrayWithObject:buckets];
    }
    for (NSDictionary *bucket in buckets) {
        [parsedBuckets addObject:[BS3Response parseBucket:bucket]];
    }
    [bucketListResponse setValue:parsedBuckets forKey:@"buckets"];
    return bucketListResponse;
}

+ (NSDictionary *)parseListBucketResult:(NSDictionary *)rawDict {
    NSMutableDictionary *bucketListResponse = [NSMutableDictionary dictionary];
    [bucketListResponse setValue:@"ListBucketResult" forKey:@"type"];
    NSString *nextMarker = [[rawDict objectForKey:@"ListBucketResult"] objectForKey:@"NextMarker"];
    if (nextMarker) {
        [bucketListResponse setValue:nextMarker forKey:@"nextMarker"];
    }
    id objects = [rawDict valueForKeyPath:@"ListBucketResult.Contents"];
    NSMutableArray *parsedObjects = [NSMutableArray array];
    if (![objects isKindOfClass:[NSArray class]]) {
        objects = [NSArray arrayWithObject:objects];
    }
    for (NSDictionary *object in objects) {
        [parsedObjects addObject:[BS3Response parseObject:object]];
    }
    [bucketListResponse setValue:parsedObjects forKey:@"objects"];
    return bucketListResponse;
}

+ (NSDictionary *)formattedDictionaryWithParsedDictionary:(NSDictionary *)parsedDict {
    NSMutableDictionary *formattedDict = [NSMutableDictionary dictionary];
    NSString *s3Type = [[parsedDict allKeys] lastObject];
    SEL s = NSSelectorFromString([NSString stringWithFormat:@"parse%@:", s3Type]);
    if ([BS3Response respondsToSelector:s]) {
        formattedDict = [BS3Response performSelector:s withObject:parsedDict];
    } else {
        formattedDict = [NSDictionary dictionaryWithObject:@"Couldn't parse result" forKey:@"Error"];
    }
    return formattedDict;
}

- (id)initWithHTTPResponse:(NSHTTPURLResponse *)response data:(NSData *)data error:(NSError *)error {
    self = [super initWithURL:response.URL statusCode:response.statusCode HTTPVersion:@"1.1" headerFields:response.allHeaderFields];
    if (self) {
        _data = data;
        _error = error;
        self.parser = [[BS3Parser alloc] init];
    }
    return self;
}

- (NSDictionary *)dataDictionary {
    if(!_s3DateFormat) {
        static dispatch_once_t oncePredicate;
        dispatch_once(&oncePredicate, ^{
            _s3DateFormat = [[NSDateFormatter alloc] init];
            _s3DateFormat.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US"];
            _s3DateFormat.timeZone = [NSTimeZone timeZoneWithAbbreviation:@"GMT"];
            _s3DateFormat.dateFormat = @"yyyy-MM-dd'T'HH':'mm':'ss'.000Z'";
        });
    }
    if (!_dataDictionary && _data) {
        NSDictionary *rawDictionary = [self.parser dictionaryWithData:_data];
        _dataDictionary = [BS3Response formattedDictionaryWithParsedDictionary:rawDictionary];
    }
    return _dataDictionary;
}

- (NSString *)responseType {
    if (!_type) {
        _type = [self.dataDictionary objectForKey:@"type"];
    }
    return _type;
}

@end
