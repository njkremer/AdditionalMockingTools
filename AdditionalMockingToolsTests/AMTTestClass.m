//
//  AMTTestClass.m
//  AdditionalMockingTools
//
//  Copyright (c) 2012 Nick Kremer. All rights reserved.
//

#import "AMTTestClass.h"

@implementation AMTTestClass
+ (NSString *)methodWithNoParams {
    return @"okay";
}

+ (NSString *)methodWithOneParam:(NSString *)one {
    return @"one";
}

+ (NSString *)methodWithOneParam:(NSString *)one two:(NSString *)two {
    return @"two";
}

+ (NSString *)methodWithOneParam:(NSString *)one two:(NSString *)two three:(NSString *)three {
    return @"three";
}

+ (NSString *)methodWithOneParam:(NSString *)one two:(NSString *)two three:(NSString *)three four:(NSString *)four {
    return @"four";
}

+ (NSString *)methodWithOnePrimitiveParam:(int)one {
    return @"one primitive";
}

+ (void)voidMethod {
    [NSException raise:@"MethodShouldntBeCalledException" format:@"This exception shouldn't fire since the mock version should be called"];
}

+ (void)methodThatCallsMethodWithNoParamsNumberOfTimes:(int)times {
    for(int i = 0; i < times; i++) {
        [self methodWithNoParams];
    }
}

@end
