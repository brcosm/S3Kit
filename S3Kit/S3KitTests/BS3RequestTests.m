//
//  BS3RequestTests.m
//  BS3RequestTests
//
//  Created by Brandon Smith on 7/15/12.
//  Copyright (c) 2012 TokenGnome. All rights reserved.
//

#import "BS3RequestTests.h"
#import "BS3Request.h"

@implementation BS3RequestTests {
    NSDateFormatter *dateFormat;
    NSDate *testDate;
    
    NSString *testAccessKey;
    NSString *testSecretKey;
    
    BS3Request *operationRequest;
    BS3Request *bucketRequest;
    BS3Request *bucketRequestWithParams;
    BS3Request *bucketRequestWithMultipleParams;
}

- (void)setUp {
    [super setUp];
        
    testAccessKey = @"ABC123";
    testSecretKey = @"DEF456";
    testDate = [NSDate dateWithTimeIntervalSince1970:0];
    
    dateFormat = [[NSDateFormatter alloc] init];
    dateFormat.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US"];
    dateFormat.timeZone = [NSTimeZone timeZoneWithAbbreviation:@"GMT"];
    dateFormat.dateFormat = @"EEE',' dd MMM yyyy HH':'mm':'ss '+0000'";
    
    operationRequest = [[BS3Request alloc] initWithBucket:nil action:nil parameters:nil accessKey:testAccessKey secretKey:testSecretKey];
    bucketRequest = [[BS3Request alloc] initWithBucket:@"testBucket" action:nil parameters:nil accessKey:testAccessKey secretKey:testSecretKey];
    NSDictionary *params = [NSDictionary dictionaryWithObject:@"/" forKey:@"delimiter"];
    bucketRequestWithParams = [[BS3Request alloc] initWithBucket:@"testBucket" action:nil parameters:params accessKey:testAccessKey secretKey:testSecretKey];
    params = [NSDictionary dictionaryWithObjectsAndKeys:@"/", @"delimiter", @"img/", @"prefix", nil];
    bucketRequestWithMultipleParams = [[BS3Request alloc] initWithBucket:@"testBucket" action:nil parameters:params accessKey:testAccessKey secretKey:testSecretKey];
}

- (void)tearDown {
    operationRequest = nil;
    bucketRequest = nil;
    bucketRequestWithParams = nil;
    bucketRequestWithMultipleParams = nil;
    [super tearDown];
}

- (void)checkDateHeader:(NSString *)dateString {
    STAssertNotNil(dateString, @"the request should have a Date header field");
    
    NSDate *date = [dateFormat dateFromString:dateString];
    STAssertNotNil(date, @"the request's date header should be a valid rfc datestring");
    STAssertTrue([date timeIntervalSinceNow] < 10, @"the requests's date header should be recent");
}

#pragma mark - Request on the S3 Operation

- (void)testRequestOnOperationInitialization {
    STAssertNotNil(operationRequest, @"the should be a non-nil BS3Request instance");
    STAssertEqualObjects(@"https://s3.amazonaws.com/", operationRequest.URL.absoluteString, @"the request should be a generic request on the S3Operation");
    [self checkDateHeader:[operationRequest valueForHTTPHeaderField:@"Date"]];
}

- (void)testRequestOnOperationStringToSign {
    [operationRequest setValue:[dateFormat stringFromDate:testDate] forHTTPHeaderField:@"Date"];
    NSString *stringToSign = [operationRequest stringToSign];
    NSString *testStringToSign = @"GET\n\n\nThu, 01 Jan 1970 00:00:00 +0000\n/";
    STAssertEqualObjects(stringToSign, testStringToSign, @"the string to sign should match the expected format");
}

- (void)testRequestOnOperationGeneratesAValidAuthenticationToken {
    [operationRequest setValue:[dateFormat stringFromDate:testDate] forHTTPHeaderField:@"Date"];
    NSString *testAuthorizationHeader = @"AWS ABC123:XcdfQ+3R5pLHy+OY4clD2gTq6dc=";
    STAssertEqualObjects([operationRequest authorizationHeader], testAuthorizationHeader, @"the authorization header should match the expected format");
}

#pragma mark - Request on a Bucket

- (void)testRequestOnBucketInitialization {
    STAssertNotNil(bucketRequest, @"the should be a non-nil BS3Request instance");
    STAssertEqualObjects(@"https://testBucket.s3.amazonaws.com/", bucketRequest.URL.absoluteString, @"the request should be a generic request on the S3Operation");
    [self checkDateHeader:[operationRequest valueForHTTPHeaderField:@"Date"]];
}

- (void)testRequestOnBucketWithParamsInitialization {
    STAssertNotNil(bucketRequest, @"the should be a non-nil BS3Request instance");
    STAssertEqualObjects(@"https://testBucket.s3.amazonaws.com/?delimiter=/", bucketRequestWithParams.URL.absoluteString, @"the request should be a generic request on the S3Operation");
    [self checkDateHeader:[operationRequest valueForHTTPHeaderField:@"Date"]];
}

- (void)testRequestOnBucketWithMultipleParamsInitialization {
    STAssertNotNil(bucketRequest, @"the should be a non-nil BS3Request instance");
    STAssertEqualObjects(@"https://testBucket.s3.amazonaws.com/?delimiter=/&prefix=img/", bucketRequestWithMultipleParams.URL.absoluteString, @"the request should be a generic request on the S3Operation");
    [self checkDateHeader:[operationRequest valueForHTTPHeaderField:@"Date"]];
}

- (void)testRequestOnBucketStringToSign {
    [bucketRequest setValue:[dateFormat stringFromDate:testDate] forHTTPHeaderField:@"Date"];
    NSString *stringToSign = [bucketRequest stringToSign];
    NSString *testStringToSign = @"GET\n\n\nThu, 01 Jan 1970 00:00:00 +0000\n/testBucket/";
    STAssertEqualObjects(stringToSign, testStringToSign, @"the string to sign should match the expected format");
}

- (void)testRequestOnBucketGeneratesAValidAuthenticationToken {
    [bucketRequest setValue:[dateFormat stringFromDate:testDate] forHTTPHeaderField:@"Date"];
    NSString *testAuthorizationHeader = @"AWS ABC123:Ni5sbHE2vkbO8snTWgV42TIJD2o=";
    STAssertEqualObjects([bucketRequest authorizationHeader], testAuthorizationHeader, @"the authorization header should match the expected format");
}


@end
