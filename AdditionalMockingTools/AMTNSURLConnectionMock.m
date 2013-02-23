//
//  AMTNSURLConnectionMock.m
//  AdditionalMockingTools
//
//  Copyright (c) 2012 Nick Kremer. All rights reserved.
//

#import "AMTNSURLConnectionMock.h"
#import "AMTNSURLConnectionMockCore.h"
#import <objc/runtime.h>

static __strong NSMutableArray *_cores;
static Method _originalAsyncMethod;
static Method _originalSyncMethod;
static int _invocationCount = 0;

@implementation AMTNSURLConnectionMock

+ (AMTNSURLConnectionMockCore *) coreForInvocationNumber:(int)invocationNumber {
    return [_cores objectAtIndex:invocationNumber];
}

+ (AMTNSURLConnectionMock *)mock {
    return [[AMTNSURLConnectionMock alloc] init];
}

+ (id)getValueWithNilCheck:(id)value {
    if([value isKindOfClass:[NSNull class]]) {
        value = nil;
    }
    return value;
}

- (id)nilCheck:(id)value {
    if(value == nil) {
        value = [NSNull null];
    }
    return value;
}

- (id)init {
    if(self = [super init]) {
        if(!_cores) {
            _cores = [[NSMutableArray alloc] init];
        }
    }
    return self;
}

- (void)mockAsyncRquestCompletionBlockWithResponse:(NSHTTPURLResponse *)response data:(NSData *)data error:(NSError *)error {
    AMTNSURLConnectionMockCore *core = [[AMTNSURLConnectionMockCore alloc] init];
    [_cores addObject:core];
    
    core.response = [self nilCheck:response];
    core.data = [self nilCheck:data];
    core.error = [self nilCheck:error];
    
    if(_originalAsyncMethod == nil) {
        _originalAsyncMethod = class_getClassMethod([NSURLConnection class], @selector(sendAsynchronousRequest:queue:completionHandler:));
        
        Method mockAsyncMethod = class_getInstanceMethod([self class], @selector(mockAsyncWithRequest:queue:handler:));
        method_exchangeImplementations(_originalAsyncMethod, mockAsyncMethod);
    }
}

- (void)mockSendSynchronousRequestWithOutParameterResponse:(NSHTTPURLResponse*)response error:(NSError *)error andReturningData:(NSData *)data {
    AMTNSURLConnectionMockCore *core = [[AMTNSURLConnectionMockCore alloc] init];
    [_cores addObject:core];
    
    core.response = [self nilCheck:response];
    core.data = [self nilCheck:data];
    core.error = [self nilCheck:error];
    
    if(_originalSyncMethod == nil) {
        _originalSyncMethod = class_getClassMethod([NSURLConnection class], @selector(sendSynchronousRequest:returningResponse:error:));
        Method mockSyncMethod = class_getInstanceMethod([self class], @selector(mockSyncWithRequest:reponse:error:));
        method_exchangeImplementations(_originalSyncMethod, mockSyncMethod);
    }
}

- (void)removeMocking {
    if(_originalAsyncMethod) {
        Method mockAsyncMethod = class_getInstanceMethod([self class], @selector(mockAsyncWithRequest:queue:handler:));
        method_exchangeImplementations(_originalAsyncMethod, mockAsyncMethod);
        _originalAsyncMethod = nil;
    }
    if(_originalSyncMethod ) {
        Method mockSyncMethod = class_getInstanceMethod([self class], @selector(mockSyncWithRequest:reponse:error:));
        method_exchangeImplementations(_originalSyncMethod, mockSyncMethod);
        _originalSyncMethod = nil;
    }
    _invocationCount = 0;
    for(AMTNSURLConnectionMockCore *core in _cores) {
        [core reset];
    }
    [_cores removeAllObjects];
}

- (NSURLRequest *)requestForMockInvocationNumber:(int)invocationNumber {
    AMTNSURLConnectionMockCore *core = [AMTNSURLConnectionMock coreForInvocationNumber:invocationNumber];
    return (NSURLRequest *) core.request;
}

- (void)dealloc {
    [self removeMocking];
    _cores = nil;
}

#pragma mark - Mock Methods
- (void)mockAsyncWithRequest:(id)request queue:(id)queue handler:(void (^)(NSURLResponse *, NSData *, NSError *))handler {
    AMTNSURLConnectionMockCore *core = [AMTNSURLConnectionMock coreForInvocationNumber:_invocationCount];
    _invocationCount++;
    
    core.request = request;
    handler([AMTNSURLConnectionMock getValueWithNilCheck:core.response], [AMTNSURLConnectionMock getValueWithNilCheck:core.data], [AMTNSURLConnectionMock getValueWithNilCheck:core.error]);
}

- (NSData *)mockSyncWithRequest:(NSURLRequest *)request reponse:(NSURLResponse **)response error:(NSError **)error {
    AMTNSURLConnectionMockCore *core = [AMTNSURLConnectionMock coreForInvocationNumber:_invocationCount];
    _invocationCount++;
    
    core.request = request;
    *response = [AMTNSURLConnectionMock getValueWithNilCheck:core.response];
    *error = [AMTNSURLConnectionMock getValueWithNilCheck:core.error];
    
    return [AMTNSURLConnectionMock getValueWithNilCheck:core.data];
}
@end
