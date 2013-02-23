//
//  AMTNSURLConnectionMockTests.m
//  AdditionalMockingTools
//
//  Copyright (c) 2012 Nick Kremer. All rights reserved.
//

#import "AMTNSURLConnectionMockTests.h"
#import "AMTNSURLConnectionMock.h"
#import <objc/runtime.h>

@implementation AMTNSURLConnectionMockTests

static BOOL _done = NO;

- (void)setUp {
    _done = NO;
}

- (void)testMockingOneBlockCallback {
    NSHTTPURLResponse *testResponse = [[NSHTTPURLResponse alloc] initWithURL:[NSURL URLWithString:@"test"]
                                                                  statusCode:200 HTTPVersion:@"HTTP/1.1"
                                                                headerFields:nil];
    NSData *testData = [@"test" dataUsingEncoding:NSUTF8StringEncoding];
    
    AMTNSURLConnectionMock *mock = [AMTNSURLConnectionMock mock];
    [mock mockAsyncRquestCompletionBlockWithResponse:testResponse data:testData error:nil];
    
    [NSURLConnection sendAsynchronousRequest:nil queue:nil completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
        NSString *expectedData = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        
        STAssertEqualObjects([[response URL] absoluteString] , @"test", @"The response should be the mocked response");
        STAssertEqualObjects(expectedData, @"test", @"The data should be the mocked data");
        STAssertNil(error, @"The error should be the mocked error");
        _done = YES;
    }];
    
    STAssertTrue([self waitForCompletion:5.0], @"Failed to get any results in time");
}

- (void)testMockingMoreThanOneBlockCallback {
    NSHTTPURLResponse *testResponse = [[NSHTTPURLResponse alloc] initWithURL:[NSURL URLWithString:@"test"]
                                                                  statusCode:200 HTTPVersion:@"HTTP/1.1"
                                                                headerFields:nil];
    NSData *testData = [@"test" dataUsingEncoding:NSUTF8StringEncoding];
    
    NSHTTPURLResponse *testResponse2 = [[NSHTTPURLResponse alloc] initWithURL:[NSURL URLWithString:@"test2"]
                                                                  statusCode:200 HTTPVersion:@"HTTP/1.1"
                                                                headerFields:nil];
    NSData *testData2 = [@"test2" dataUsingEncoding:NSUTF8StringEncoding];
    NSError *testError2 = [NSError errorWithDomain:@"test2" code:1 userInfo:nil];
    
    AMTNSURLConnectionMock *mock = [AMTNSURLConnectionMock mock];
    [mock mockAsyncRquestCompletionBlockWithResponse:testResponse data:testData error:nil];
    [mock mockAsyncRquestCompletionBlockWithResponse:testResponse2 data:testData2 error:testError2];
    
    [NSURLConnection sendAsynchronousRequest:nil queue:nil completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
        NSString *expectedData = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        
        STAssertEqualObjects([[response URL] absoluteString] , @"test", @"The response should be the mocked response");
        STAssertEqualObjects(expectedData, @"test", @"The data should be the mocked data");
        STAssertNil(error, @"The error should be the mocked error");
        _done = YES;
    }];
    STAssertTrue([self waitForCompletion:5.0], @"Failed to get any results in time");
    
    _done = NO;
    [NSURLConnection sendAsynchronousRequest:nil queue:nil completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
        NSString *expectedData = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        
        STAssertEqualObjects([[response URL] absoluteString] , @"test2", @"The response should be the mocked response");
        STAssertEqualObjects(expectedData, @"test2", @"The data should be the mocked data");
        STAssertEqualObjects(@"test2", error.domain, @"The error should be the mocked error");
        _done = YES;
    }];
    STAssertTrue([self waitForCompletion:5.0], @"Failed to get any results in time");
}

- (void)testMockingSynchronousMethod {
    NSHTTPURLResponse *testResponse = [[NSHTTPURLResponse alloc] initWithURL:[NSURL URLWithString:@"test"]
                                                                  statusCode:200 HTTPVersion:@"HTTP/1.1"
                                                                headerFields:nil];
    NSData *testData = [@"test" dataUsingEncoding:NSUTF8StringEncoding];
    
    AMTNSURLConnectionMock *mock = [AMTNSURLConnectionMock mock];
    [mock mockSendSynchronousRequestWithOutParameterResponse:testResponse error:nil andReturningData:testData];
    
    NSHTTPURLResponse *verificationResponse;
    NSError *verificationError;
    NSData *verificationData = [NSURLConnection sendSynchronousRequest:nil returningResponse:&verificationResponse error:&verificationError];
    NSString *expectedData = [[NSString alloc] initWithData:verificationData encoding:NSUTF8StringEncoding];
        
    STAssertEqualObjects([[verificationResponse URL] absoluteString] , @"test", @"The response should be the mocked response");
    STAssertEqualObjects(expectedData, @"test", @"The data should be the mocked data");
    STAssertNil(verificationError, @"The error should be the mocked error");
    
}

- (void)testGettingTheRequestFromASycnrhonousCall {
    NSHTTPURLResponse *testResponse = [[NSHTTPURLResponse alloc] initWithURL:[NSURL URLWithString:@"test"]
                                                                  statusCode:200 HTTPVersion:@"HTTP/1.1"
                                                                headerFields:nil];
    NSData *testData = [@"test" dataUsingEncoding:NSUTF8StringEncoding];
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:@"test"]];
    
    AMTNSURLConnectionMock *mock = [AMTNSURLConnectionMock mock];
    [mock mockSendSynchronousRequestWithOutParameterResponse:testResponse error:nil andReturningData:testData];
    
    NSHTTPURLResponse *verificationResponse;
    NSError *verificationError;
    NSData *verificationData = [NSURLConnection sendSynchronousRequest:request returningResponse:&verificationResponse error:&verificationError];
    NSString *expectedData = [[NSString alloc] initWithData:verificationData encoding:NSUTF8StringEncoding];
    
    STAssertEqualObjects([[verificationResponse URL] absoluteString] , @"test", @"The response should be the mocked response");
    STAssertEqualObjects(expectedData, @"test", @"The data should be the mocked data");
    STAssertNil(verificationError, @"The error should be the mocked error");
    STAssertEqualObjects([[[mock requestForMockInvocationNumber:0] URL] absoluteString], @"test", nil);
}

- (void)testGettingTheRequestFromAnAsynchronousCall {
    NSHTTPURLResponse *testResponse = [[NSHTTPURLResponse alloc] initWithURL:[NSURL URLWithString:@"test"]
                                                                  statusCode:200 HTTPVersion:@"HTTP/1.1"
                                                                headerFields:nil];
    NSData *testData = [@"test" dataUsingEncoding:NSUTF8StringEncoding];
    
    AMTNSURLConnectionMock *mock = [AMTNSURLConnectionMock mock];
    [mock mockAsyncRquestCompletionBlockWithResponse:testResponse data:testData error:nil];
    
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:@"test"]];
    [NSURLConnection sendAsynchronousRequest:request queue:nil completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
        NSString *expectedData = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        
        STAssertEqualObjects([[response URL] absoluteString] , @"test", @"The response should be the mocked response");
        STAssertEqualObjects(expectedData, @"test", @"The data should be the mocked data");
        STAssertNil(error, @"The error should be the mocked error");
        _done = YES;
    }];
    STAssertTrue([self waitForCompletion:5.0], @"Failed to get any results in time");
    STAssertEqualObjects([[[mock requestForMockInvocationNumber:0] URL] absoluteString], @"test", nil);
}

- (void)testToMakeSureAllAsyncParamsCanBeNil {   
    AMTNSURLConnectionMock *mock = [AMTNSURLConnectionMock mock];
    [mock mockAsyncRquestCompletionBlockWithResponse:nil data:nil error:nil];
    
    [NSURLConnection sendAsynchronousRequest:nil queue:nil completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
        
        STAssertNil([[response URL] absoluteString] , @"The response should be the mocked response");
        STAssertNil(data, @"The data should be the mocked data");
        STAssertNil(error, @"The error should be the mocked error");
        _done = YES;
    }];
    
    STAssertTrue([self waitForCompletion:5.0], @"Failed to get any results in time");
    STAssertNil([mock requestForMockInvocationNumber:0], @"The request should be the passed in request");
}

- (void)testToMakeSureAllSyncParamsCanBeNil {
    AMTNSURLConnectionMock *mock = [AMTNSURLConnectionMock mock];
    [mock mockSendSynchronousRequestWithOutParameterResponse:nil error:nil andReturningData:nil];
    
    NSHTTPURLResponse *verificationResponse;
    NSError *verificationError;
    [NSURLConnection sendSynchronousRequest:nil returningResponse:&verificationResponse error:&verificationError];
    
    STAssertNil(verificationResponse, @"The response should be the mocked response");
    STAssertNil(verificationError, @"The error should be the mocked error");
    STAssertNil([mock requestForMockInvocationNumber:0], @"The request should be the passed in request");
}

- (void)testToMakeSureDataReturnedFromSyncCallCanBeNil {
    NSHTTPURLResponse *testResponse = [[NSHTTPURLResponse alloc] initWithURL:[NSURL URLWithString:@"test"]
                                                                  statusCode:200 HTTPVersion:@"HTTP/1.1"
                                                                headerFields:nil];
    
    AMTNSURLConnectionMock *mock = [AMTNSURLConnectionMock mock];
    [mock mockSendSynchronousRequestWithOutParameterResponse:testResponse error:nil andReturningData:nil];
    
    NSHTTPURLResponse *verificationResponse;
    NSError *verificationError;
    NSData *verificationData = [NSURLConnection sendSynchronousRequest:nil returningResponse:&verificationResponse error:&verificationError];
    
    STAssertEqualObjects([[verificationResponse URL] absoluteString] , @"test", @"The response should be the mocked response");
    STAssertNil(verificationData, @"The data should be the mocked data");
    STAssertNil(verificationError, @"The error should be the mocked error");

}

- (void)testThatRemovingMockingRestoresOriginalSyncMethod {

    // Save original implementation for verification purposes
    IMP originalImp = method_getImplementation(class_getClassMethod([NSURLConnection class], @selector(sendSynchronousRequest:returningResponse:error:)));
    
    // Setup the mock
    AMTNSURLConnectionMock *mock = [AMTNSURLConnectionMock mock];
    [mock mockSendSynchronousRequestWithOutParameterResponse:nil error:nil andReturningData:nil];
    
    // verify the implementation has been swapped out
    IMP currentImp = method_getImplementation(class_getClassMethod([NSURLConnection class], @selector(sendSynchronousRequest:returningResponse:error:)));
    STAssertTrue(currentImp != originalImp, @"The mocked implementation should not be the same as the original");
    
    [mock removeMocking];

    // Verify the original implementation is back to normal
    currentImp = method_getImplementation(class_getClassMethod([NSURLConnection class], @selector(sendSynchronousRequest:returningResponse:error:)));
    STAssertEquals(originalImp, currentImp, nil);

    // Additionally verify that the data coming back is nil as expected from the normal method call with a nil request
    NSHTTPURLResponse *response;
    NSError *error;
    NSData *verificationData = [NSURLConnection sendSynchronousRequest:nil returningResponse:&response error:&error];
    STAssertNil(verificationData, @"The data should be nil if the original method is restored.");
    
}

- (void)testThatRemovingMockingRestoresOriginalAsyncMethod {
    
    // Save original implementation for verification purposes
    IMP originalImp = method_getImplementation(class_getClassMethod([NSURLConnection class], @selector(sendAsynchronousRequest:queue:completionHandler:)));
    
    // Setup the mock
    AMTNSURLConnectionMock *mock = [AMTNSURLConnectionMock mock];
    [mock mockAsyncRquestCompletionBlockWithResponse:nil data:nil error:nil];
    
    // verify the implementation has been swapped out
    IMP currentImp = method_getImplementation(class_getClassMethod([NSURLConnection class],  @selector(sendAsynchronousRequest:queue:completionHandler:)));
    STAssertTrue(currentImp != originalImp, @"The mocked implementation should not be the same as the original");
    
    [mock removeMocking];
    
    // Verify the original implementation is back to normal
    currentImp = method_getImplementation(class_getClassMethod([NSURLConnection class],  @selector(sendAsynchronousRequest:queue:completionHandler:)));
    STAssertEquals(originalImp, currentImp, nil);
    
    // Additionally verify that the data coming back is nil as expected from the normal method call with a nil request
    [NSURLConnection sendAsynchronousRequest:nil queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
        STAssertNil(data, @"The data should be nil if the original method is restored.");
        _done = YES;
    }];

    STAssertTrue([self waitForCompletion:5.0], @"Failed to get any results in time");
    
}

- (void)testToMakeSureMockingIsRemovedInDealloc {
    
    NSHTTPURLResponse *response;
    NSError *error;
    NSData *verificationData = [NSURLConnection sendSynchronousRequest:nil returningResponse:&response error:&error];
    STAssertNil(verificationData, nil);
    
    // need the autorelease pool because mock: will return an autoreleased instance of AMTClassMock.
    @autoreleasepool {
        NSData *testData = [@"test" dataUsingEncoding:NSUTF8StringEncoding];
        
        AMTNSURLConnectionMock *mock = [AMTNSURLConnectionMock mock];
        [mock mockSendSynchronousRequestWithOutParameterResponse:nil error:nil andReturningData:testData];
    
        //mock a second call since we COULD be calling to it again if the mocking failed to be removed...
        [mock mockSendSynchronousRequestWithOutParameterResponse:nil error:nil andReturningData:testData];
    
        NSHTTPURLResponse *verificationResponse;
        NSError *verificationError;
        verificationData = [NSURLConnection sendSynchronousRequest:nil returningResponse:&verificationResponse error:&verificationError];
        NSString *expectedData = [[NSString alloc] initWithData:verificationData encoding:NSUTF8StringEncoding];
        
        STAssertEqualObjects(expectedData, @"test", @"The mocked data should have been returned");
        mock = nil;
    }
    
    verificationData = [NSURLConnection sendSynchronousRequest:nil returningResponse:&response error:&error];
    STAssertNil(verificationData, @"The data should be nil if the original method is restored.");
}

- (BOOL)waitForCompletion:(NSTimeInterval)timeoutSecs {
    NSDate *timeoutDate = [NSDate dateWithTimeIntervalSinceNow:timeoutSecs];
    if (_done) {
        return _done;
    }
    
    do {
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:timeoutDate];
        if([timeoutDate timeIntervalSinceNow] < 0.0)
            break;
    } while (!_done);
    
    return _done;
}

@end
