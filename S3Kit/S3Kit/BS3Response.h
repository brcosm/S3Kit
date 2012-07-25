//
//  BS3Response.h
//  BS3Request
//
//  Created by Brandon Smith on 7/15/12.
//  Copyright (c) 2012 TokenGnome. All rights reserved.
//

#import <Foundation/Foundation.h>

@class BS3Parser;

@interface BS3Response : NSHTTPURLResponse

@property (nonatomic, readonly) NSData *data;
@property (nonatomic, readonly) NSDictionary *dataDictionary;
@property (nonatomic, readonly) NSError *error;
@property (nonatomic, readonly) NSString *type;
@property (nonatomic, strong) BS3Parser *parser;

- (id)initWithHTTPResponse:(NSHTTPURLResponse *)response data:(NSData *)data error:(NSError *)error;

@end