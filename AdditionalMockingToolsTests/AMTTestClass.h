//
//  AMTTestClass.h
//  AdditionalMockingTools
//
//  Copyright (c) 2012 Nick Kremer. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AMTTestClass : NSObject
+ (NSString *)methodWithNoParams;
+ (NSString *)methodWithOneParam:(NSString *)one;
+ (NSString *)methodWithOneParam:(NSString *)one two:(NSString *)two;
+ (NSString *)methodWithOneParam:(NSString *)one two:(NSString *)two three:(NSString *)three;
+ (NSString *)methodWithOneParam:(NSString *)one two:(NSString *)two three:(NSString *)three four:(NSString *)four;
+ (NSString *)methodWithOnePrimitiveParam:(int)one;
+ (void)voidMethod;
+ (void)methodThatCallsMethodWithNoParamsNumberOfTimes:(int)times;
@end
