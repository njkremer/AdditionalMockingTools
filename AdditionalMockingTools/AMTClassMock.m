//
//  AMTClassMock.m
//  AdditionalMockingTools
//
//  Copyright (c) 2012 Nick Kremer. All rights reserved.
//

#import "AMTClassMock.h"
#import "AMTClassMockCore.h"
#import <objc/runtime.h>

static __strong NSMutableDictionary *_classCores;

@interface AMTClassMock()
@property (strong, nonatomic) NSString *currentMockingSelector;
@property (assign, nonatomic) BOOL currentMockingSelectorDoesNothing;
@end

@implementation AMTClassMock

#pragma mark - Class Methods
+ (id)mock:(Class)mockedClass {
    AMTClassMock *mock = [[AMTClassMock alloc] init];
    mock.mockedClass = mockedClass;
    
    AMTClassMockCore *core = [[AMTClassMockCore alloc] init];
    [_classCores setObject:core forKey:[mockedClass description]];
    return mock;
}

+ (AMTClassMockCore *) coreForClass:(Class)class {
    return [_classCores objectForKey:[class description]];
}

+ (id)mockValueForClass:(Class)class command:(SEL)cmd {
    NSString *cmdString = NSStringFromSelector(cmd);
    AMTClassMockCore *core = [AMTClassMock coreForClass:class];
    
    BOOL methodIsExpectedAndNotStubbed = [core.expectedMethods objectForKey:cmdString] != nil;
    if(methodIsExpectedAndNotStubbed) {
        NSNumber *verifiedCount = [core.verifiedMethods objectForKey:cmdString];
        verifiedCount = [NSNumber numberWithInt:[verifiedCount intValue] + 1];
        [core.verifiedMethods setObject:verifiedCount forKey:cmdString];
    }
    
    BOOL methodMockedIsSupposedToDoNothing = [core.doNothingMethods containsObject:cmdString] || methodIsExpectedAndNotStubbed;
    if(methodMockedIsSupposedToDoNothing) {
        return nil;
    }
    
    id value = [core.returnValues objectForKey:cmdString];
    if([value isKindOfClass:[NSNull class]]) {
        value = nil;
    }
    return value;
}

#pragma mark - Instance Methods
- (id)init {
    if(self = [super init]) {
        if(!_classCores) {
            _classCores = [[NSMutableDictionary alloc] init];   
        }
    }
    return self;
}

- (void)when:(id)method thenReturn:(id)value {
    AMTClassMockCore *core = [AMTClassMock coreForClass:self.mockedClass];
    [core.returnValues setObject:[self nilCheck:value] forKey:self.currentMockingSelector];
}

- (void)whenSelector:(SEL)selector thenReturn:(id)value {
    [self setupMocking:selector];
    [self when:nil thenReturn:value];
}

// TODO
- (void)whenSelector:(SEL)selector thenRunCallbackBlockWithParameters:(NSArray *)blockParameters {
    // Check each of the parameters of the selector method to see if it's of type block via [myBlock isKindOfClass:NSClassFromString(@"NSBlock")]
    // then execute the block parameter with the array of parameters, not sure how to know how to choose the parameters out of the list, but I'll
    // figure something out.
}

- (AMTClassMock *)doNothingFor {
    self.currentMockingSelectorDoesNothing = YES;
    return self;
}

- (void)doNothingForSeletor:(SEL)selector {
    [self doNothingFor];
    [self setupMocking:selector];
    
}

- (void)expect:(id)method toBeExecutedNumberOfTimes:(int)times {
    AMTClassMockCore *core = [AMTClassMock coreForClass:self.mockedClass];
    [core.expectedMethods setObject:[NSNumber numberWithInt:times] forKey:self.currentMockingSelector];
}

- (void)expectSelector:(SEL)method toBeExecutedNumberOfTimes:(int)times {
    [self setupMocking:method];
    [self expect:nil toBeExecutedNumberOfTimes:times];
}

- (void)expect:(id)method {
    [self expect:method toBeExecutedNumberOfTimes:1];
}

- (void)expectSelector:(SEL)selector {
    [self expectSelector:selector toBeExecutedNumberOfTimes:1];
}

- (void)verify {
    AMTClassMockCore *core = [AMTClassMock coreForClass:self.mockedClass];
    for(NSString *selectorName in core.expectedMethods) {
        NSNumber *expectCount = [core.expectedMethods objectForKey:selectorName];
        NSNumber *verifiedCount = [core.verifiedMethods objectForKey:selectorName];
        
        if(verifiedCount == nil) {
            [NSException raise:@"VerifyFailedException" format:@"The method [%@ %@] was expected to be called %@ time(s) and was never called", [self.mockedClass description], selectorName, expectCount];
        }
        if([expectCount intValue] != [verifiedCount intValue]) {
            [NSException raise:@"VerifyFailedException" format:@"The method [%@ %@] was expected to be called %@ time(s) and was called exactly %@ time(s)", [self.mockedClass description], selectorName, expectCount, verifiedCount];
        }
    }
}


- (void)removeMocking {
    AMTClassMockCore *core = [AMTClassMock coreForClass:self.mockedClass];
    
    for(NSString *selectorName in core.orignalMethods) {
        
        // Get the original method back
        NSValue *boxedOriginalMethod = [core.orignalMethods objectForKey:selectorName];
        Method originalMethod;
        [boxedOriginalMethod getValue:&originalMethod];
        
        // Get the original implementation back
        NSValue *boxedOriginalImp = [core.orignalImplementations objectForKey:selectorName];
        IMP originalImp;
        [boxedOriginalImp getValue:&originalImp];
        
        // put back the original implementation for the method
        method_setImplementation(originalMethod, originalImp);
    }
    
    [core reset];
    [_classCores removeObjectForKey:[self.mockedClass description]];
}

- (void)setupMocking:(SEL)methodSelector {
    NSMethodSignature *signature = [self.mockedClass methodSignatureForSelector:methodSelector];
    
    self.currentMockingSelector = NSStringFromSelector(methodSelector);
    
    AMTClassMockCore *core = [AMTClassMock coreForClass:self.mockedClass];
    
    // Get the original method and save it off
    Method originalMethod = class_getClassMethod(self.mockedClass, methodSelector);
    NSValue *boxedMethod = [NSValue value:&originalMethod withObjCType:@encode(Method)];
    [core.orignalMethods setObject:boxedMethod forKey:self.currentMockingSelector];
    
    // Get the original implementation and save it off
    IMP originalImp = method_getImplementation(originalMethod);
    NSValue *boxedImp = [NSValue value:&originalImp withObjCType:@encode(IMP)];
    [core.orignalImplementations setObject:boxedImp forKey:self.currentMockingSelector];
    
    // Get the mock method & implementation
    Method mockMethod = [self getMockMethod:[signature numberOfArguments] - 2];
    IMP mockImp = method_getImplementation(mockMethod);
    
    // set the original method's implementation to be the mock implementation
    method_setImplementation(originalMethod, mockImp);
    
    // handle doNothingFor method calls
    if(self.currentMockingSelectorDoesNothing) {
        AMTClassMockCore *core = [AMTClassMock coreForClass:self.mockedClass];
        [core.doNothingMethods addObject:self.currentMockingSelector];
        self.currentMockingSelectorDoesNothing = NO;
    }
}

- (Method)getMockMethod:(int)numberOfArguments {
    Method mockMethod;
    switch (numberOfArguments) {
        case 0:
            mockMethod = class_getInstanceMethod([self class], @selector(mockMethod)); break;
        case 1:
            mockMethod = class_getInstanceMethod([self class], @selector(mockMethodOne:)); break;
        case 2:
            mockMethod = class_getInstanceMethod([self class], @selector(mockMethodOne:two:)); break;
        case 3:
            mockMethod = class_getInstanceMethod([self class], @selector(mockMethodOne:two:)); break;
        case 4:
            mockMethod = class_getInstanceMethod([self class], @selector(mockMethodOne:two:)); break;
        default:
            [NSException raise:@"InvalidArgumentNumberException" format:@"AMTClassMock can only mock methods which take up to 4 parameters currently."];
    }
    return mockMethod;
}

- (id)mockMethod {
    return [AMTClassMock mockValueForClass:[self class] command:_cmd];
}

- (id)mockMethodOne:(void *)one {
    return [AMTClassMock mockValueForClass:[self class] command:_cmd];
}

- (id)mockMethodOne:(void *)one two:(void *)two {
    return [AMTClassMock mockValueForClass:[self class] command:_cmd];
}

- (id)mockMethodOne:(void *)one two:(void *)two three:(void *)three {
    return [AMTClassMock mockValueForClass:[self class] command:_cmd];
}

- (id)mockMethodOne:(void *)one two:(void *)two three:(void *)three four:(void *)four {
    return [AMTClassMock mockValueForClass:[self class] command:_cmd];
}

- (id)nilCheck:(id)value {
    if(value == nil) {
        value = [NSNull null];
    }
    return value;
}

- (void)dealloc {
    [self removeMocking];
    _mockedClass = nil;
    _currentMockingSelector = nil;
    _currentMockingSelectorDoesNothing = NO;
    
    BOOL noMoreClassesAreBeingMocked = [_classCores count] == 0;
    if(noMoreClassesAreBeingMocked) {
        _classCores = nil;
    }
}

#pragma mark - Method Forwarding
- (void)forwardInvocation:(NSInvocation *)anInvocation {
    SEL methodSelector = anInvocation.selector;
    [self setupMocking:methodSelector];
    [anInvocation invokeWithTarget:nil];
}

-(NSMethodSignature *)methodSignatureForSelector:(SEL)aSelector {
    return [self.mockedClass methodSignatureForSelector:aSelector];
}
@end
