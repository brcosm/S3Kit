//
//  BS3Request.m
//  BS3Request
//
//  Created by Brandon Smith on 7/15/12.
//  Copyright (c) 2012 TokenGnome. All rights reserved.
//

#import "BS3Request.h"
#import "NSData+Base64.h"
#import <CommonCrypto/CommonHMAC.h>

@implementation BS3Request {
    NSString *resourcePath;
}
@synthesize accessKey = _accessKey, secretKey =_secretKey;

+ (NSString *)urlEncodedParameter:(NSString *)parameterValue {
    return [[parameterValue  stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding] stringByReplacingOccurrencesOfString:@"+" withString:@"%2B"];
}

+ (NSString *)dateHeaderForDate:(NSDate *)date {
    static NSDateFormatter *df = nil;
    if(!df) {
        static dispatch_once_t oncePredicate;
        dispatch_once(&oncePredicate, ^{
            df = [[NSDateFormatter alloc] init];
            df.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US"];
            df.timeZone = [NSTimeZone timeZoneWithAbbreviation:@"GMT"];
            df.dateFormat = @"EEE',' dd MMM yyyy HH':'mm':'ss '+0000'";
        });
    }
    return [df stringFromDate:date];
}

+ (NSString *)authorizationHeaderForString:(NSString *)stringToSign accessKey:(NSString *)accessKey secretKey:(NSString *)secretKey {
    NSData *encryptedStringData = [BS3Request encrypt:stringToSign withKey:secretKey];
    NSString *authToken = [encryptedStringData base64EncodedString];
    return [NSString stringWithFormat:@"AWS %@:%@", accessKey, authToken];
}

+ (NSData *)encrypt:(NSString *)string withKey:(NSString *)privateKey {
    
    // encode the string and the private key as NSData
    NSData *clearTextData = [string dataUsingEncoding:NSUTF8StringEncoding];
    NSData *privateKeyData = [privateKey dataUsingEncoding:NSUTF8StringEncoding];
    
    uint8_t digest[CC_SHA1_DIGEST_LENGTH] = {0};
    // create a crypto context and apply hmac algorithm
    CCHmacContext hmacContext;
    CCHmacInit(&hmacContext, kCCHmacAlgSHA1, privateKeyData.bytes, privateKeyData.length);
    CCHmacUpdate(&hmacContext, clearTextData.bytes, clearTextData.length);
    CCHmacFinal(&hmacContext, digest);
    
    // convert the encrypted bytes back into a NS data object
    NSData *encryptedData = [NSData dataWithBytes:digest length:CC_SHA1_DIGEST_LENGTH];
    
    return encryptedData;
}

+ (NSString *)base64EncodedStringWithData:(NSData *)dataToEncode {
    return nil;
}

+ (NSString *)md5SignatureForData:(NSData *)data {
    unsigned char result[16];
    CC_MD5(data.bytes, data.length, result);
    return [NSString stringWithFormat:
            @"%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x",
            result[0], result[1], result[2], result[3], 
            result[4], result[5], result[6], result[7],
            result[8], result[9], result[10], result[11],
            result[12], result[13], result[14], result[15]
            ];  
}

+ (NSString *)stringForParameters:(NSDictionary *)parameters {
    if (!parameters || [[parameters allKeys] count] < 1) return @"";
    static NSSet *validParameters;
    if (!validParameters) validParameters = [NSSet setWithObjects:@"delimiter", @"marker", @"max-keys", @"prefix", nil];
    NSString *paramStr = @"";
    for (NSString *key in [parameters allKeys]) {
        paramStr = [validParameters containsObject:key] ? 
        [paramStr stringByAppendingFormat:@"&%@=%@", key, [BS3Request urlEncodedParameter:[parameters objectForKey:key]]] :
        paramStr;
    }
    NSLog(@"%@", paramStr);
    return [paramStr isEqualToString:@""] ? @"" : [paramStr stringByReplacingCharactersInRange:NSMakeRange(0, 1) withString:@""];
}

+ (NSString *)URLStringForBucket:(NSString *)bucketName action:(NSString *)actionName params:(NSDictionary *)params {
    NSString *host = @"s3.amazonaws.com";
    
    NSString *protocol = @"https";
    if (bucketName && ![bucketName isEqualToString:@""]) {
        host = [NSString stringWithFormat:@"%@.%@", bucketName, host];
        // If the bucket name has a period we can't use https :(
        // http://docs.amazonwebservices.com/AmazonS3/2006-03-01/dev/VirtualHosting.html#VirtualHostingSpecifyBucket
        if ([bucketName rangeOfString:@"."].location != NSNotFound) protocol = @"http";
    }
    
    NSString *urlString = [NSString stringWithFormat:@"%@://%@/", protocol, host];
    
    NSString *action = actionName ? actionName : @"";
    NSString *parameterString = [BS3Request stringForParameters:params];
        
    if ([action length] > 0 || [parameterString  length] > 0) {
        if ([action length] > 0) {
            urlString = [urlString stringByAppendingFormat:@"?%@", action];
            if ([parameterString length] > 0) urlString = [urlString stringByAppendingFormat:@"&%@", parameterString];
        } else {
            urlString = [urlString stringByAppendingFormat:@"?%@", parameterString];
        }
    }
    return urlString;
}

- (id)initWithBucket:(NSString *)bucketName action:(NSString *)actionName parameters:(NSDictionary *)params accessKey:(NSString *)accessKey secretKey:(NSString *)secretKey {
    NSString *URLString = [BS3Request URLStringForBucket:bucketName action:actionName params:params];
    self = [super initWithURL:[NSURL URLWithString:URLString]];
    if (self) {
        self.accessKey = accessKey;
        self.secretKey = secretKey;
        resourcePath = @"/";
        if (bucketName && [bucketName length] > 0) {
            resourcePath = [resourcePath stringByAppendingFormat:@"%@/", bucketName];
        }
        if (actionName && [actionName length] > 0) {
            resourcePath = [resourcePath stringByAppendingFormat:@"%@", actionName];
        }
        [self setValue:[self dateHeader] forHTTPHeaderField:@"Date"];
        [self setValue:[self authorizationHeader] forHTTPHeaderField:@"Authorization"];
    }
    return self;
}

- (id)initWithBucket:(NSString *)bucketName accessKey:(NSString *)accessKey secretKey:(NSString *)secretKey {
    return [self initWithBucket:bucketName action:nil parameters:nil accessKey:accessKey secretKey:secretKey];
}

- (id)initWithAccessKey:(NSString *)accessKey secretKey:(NSString *)secretKey {
    return [self initWithBucket:nil action:nil parameters:nil accessKey:accessKey secretKey:secretKey];
}

- (NSString *)dateHeader {
    return [BS3Request dateHeaderForDate:[NSDate date]];
}

- (NSString *)stringToSign {
    NSString *result =
    [NSString stringWithFormat:@""
     @"%@\n" // HTTP Verb
     @"%@\n" // Content MD5
     @"%@\n" // Content type
     @"%@\n" // Date
     @"%@"   // Amazon Canonicalized Headers
     @"%@",  // Amazon Canonicalized Resource
     self.HTTPMethod,
     self.HTTPBody ? [BS3Request md5SignatureForData:self.HTTPBody] : @"",
     [self.allHTTPHeaderFields objectForKey:@"Content-Type"] ? [self.allHTTPHeaderFields objectForKey:@"Content-Type"] : @"",
     [self.allHTTPHeaderFields objectForKey:@"Date"],
     @"",
     resourcePath];
    return result;
}

- (NSString *)authorizationHeader {
    return [BS3Request authorizationHeaderForString:[self stringToSign] accessKey:self.accessKey secretKey:self.secretKey];
}

@end
