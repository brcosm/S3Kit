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

- (id)initWithAccessKey:(NSString *)accessKey secretKey:(NSString *)secretKey;

- (id)initWithBucket:(NSString *)bucketName accessKey:(NSString *)accessKey secretKey:(NSString *)secretKey;

/**
 Initialize a new BS3Request object
 @param bucketName The name of the bucket to perform the request on or nil
 @param actionName The name of the action to perform @see http://docs.amazonwebservices.com/AmazonS3/latest/API/RESTBucketOps.html
 @param params The dictionary of special request parameters to use @see http://docs.amazonwebservices.com/AmazonS3/latest/API/RESTBucketGET.html#RESTBucketGET-requests-request-parameters
 @param accessKey The Amazon AWS access key to be used to sign the request
 @param secretKey The Amazon AWS secret key to be used to sign the request
 @return a newly initialized NSURLRequest subclass with a signed URL
 */
- (id)initWithBucket:(NSString *)bucketName action:(NSString *)actionName parameters:(NSDictionary *)params accessKey:(NSString *)accessKey secretKey:(NSString *)secretKey;

- (NSString *)dateHeader;

- (NSString *)stringToSign;

- (NSString *)authorizationHeader;

@end
