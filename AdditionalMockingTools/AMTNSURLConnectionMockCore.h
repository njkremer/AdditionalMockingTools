//
//  AMTNSURLConnectionMockCore.h
//  AdditionalMockingTools
//
//  Copyright (c) 2012 Nick Kremer. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AMTNSURLConnectionMockCore : NSObject
@property (strong, nonatomic) NSHTTPURLResponse *response;
@property (strong, nonatomic) NSData *data;
@property (strong, nonatomic) NSError *error;
@property (strong, nonatomic) NSURLRequest *request;

- (void)reset;
@end
