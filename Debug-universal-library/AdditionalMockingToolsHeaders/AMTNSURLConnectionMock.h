//
//  AMTNSURLConnectionMock.h
//  AdditionalMockingTools
//
//  Copyright (c) 2012 Nick Kremer. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AMTNSURLConnectionMock : NSObject
+ (AMTNSURLConnectionMock *)mock;
- (void)mockAsyncRquestCompletionBlockWithResponse:(NSHTTPURLResponse *)response data:(NSData *)data error:(NSError *)error;
- (void)mockSendSynchronousRequestWithOutParameterResponse:(NSHTTPURLResponse*)response error:(NSError *)error andReturningData:(NSData *)data;
- (void)removeMocking;
- (NSURLRequest *)requestForMockInvocationNumber:(int)invocationNumber;
@end
