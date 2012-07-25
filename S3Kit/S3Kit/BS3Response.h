//
//  BS3Response.h
//  BS3Request
//
//  Created by Brandon Smith on 7/15/12.
//  Copyright (c) 2012 TokenGnome. All rights reserved.
//

#import <Foundation/Foundation.h>

@class BS3Parser;

@interface BS3Response : NSObject

@property (nonatomic, strong) NSHTTPURLResponse *httpResponse;
@property (nonatomic, readonly) NSDictionary *responseDictionary;
@property (nonatomic, strong) NSError *responseError;
@property (nonatomic, readonly) NSString *responseType;
@property (nonatomic, strong) BS3Parser *parser;

- (id)initWithHTTPResponse:(NSHTTPURLResponse *)httpResponse data:(NSData *)responseData error:(NSError *)error;

@end