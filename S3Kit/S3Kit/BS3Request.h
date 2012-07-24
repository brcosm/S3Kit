//
//  BS3Request.h
//  BS3Request
//
//  Created by Brandon Smith on 7/15/12.
//  Copyright (c) 2012 TokenGnome. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BS3Request : NSMutableURLRequest

@property (nonatomic, copy) NSString *accessKey;
@property (nonatomic, copy) NSString *secretKey;

- (id)initWithBucket:(NSString *)bucketName action:(NSString *)actionName parameters:(NSDictionary *)params accessKey:(NSString *)accessKey secretKey:(NSString *)secretKey;

- (NSString *)dateHeader;

- (NSString *)stringToSign;

- (NSString *)authorizationHeader;

@end
