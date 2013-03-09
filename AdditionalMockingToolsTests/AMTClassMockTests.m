//
//  AdditionalMockingToolsTests.m
//  AdditionalMockingToolsTests
//
//  Copyright (c) 2012 Nick Kremer. All rights reserved.
//

#import "AMTClassMockTests.h"
#import "AdditionalMockingTools.h"
#import "AMTTestClass.h"
#import "AMTSecondTestClass.h"

@implementation AMTClassMockTests

- (void)setUp {
    [super setUp];
    
    // Set-up code here.
}

- (void)tearDown {
    // Tear-down code here.
    
    [super tearDown];
}

- (void)testMockingAClassMethodWithNoParameters {
    STAssertEqualObjects([AMTTestClass methodWithNoParams], @"okay", nil);
    
    id mock = [AMTClassMock mock:[AMTTestClass class]];
    [mock when:[mock methodWithNoParams] thenReturn:@"not okay"];
    
    STAssertEqualObjects([AMTTestClass methodWithNoParams], @"not okay", nil);
}

- (void)testMockingAClassMethodWithOneParameter {
    STAssertEqualObjects([AMTTestClass methodWithOneParam:@"test"], @"one", nil);
    
    id mock = [AMTClassMock mock:[AMTTestClass class]];
    [mock when:[mock methodWithOneParam:@"test"] thenReturn:@"not okay"];
    
    STAssertEqualObjects([AMTTestClass methodWithOneParam:@"test"], @"not okay", nil);
}

- (void)testMockingAClassMethodWithTwoParameter {
    STAssertEqualObjects([AMTTestClass methodWithOneParam:@"test" two:@"test"], @"two", nil);
    
    id mock = [AMTClassMock mock:[AMTTestClass class]];
    [mock when:[mock methodWithOneParam:@"test" two:@"two"] thenReturn:@"not okay"];
    
    STAssertEqualObjects([AMTTestClass methodWithOneParam:@"test" two:@"test"], @"not okay", nil);
}
- (void)testMockingAClassMethodWithThreeParameter {
    STAssertEqualObjects([AMTTestClass methodWithOneParam:@"test" two:@"test" three:@"test"], @"three", nil);
    
    id mock = [AMTClassMock mock:[AMTTestClass class]];
    [mock when:[mock methodWithOneParam:@"test" two:@"two" three:@"three"] thenReturn:@"not okay"];
    
    STAssertEqualObjects([AMTTestClass methodWithOneParam:@"test" two:@"test" three:@"test"], @"not okay", nil);
}
- (void)testMockingAClassMethodWithFourParameter {
    STAssertEqualObjects([AMTTestClass methodWithOneParam:@"test" two:@"test" three:@"test" four:@"test"], @"four", nil);
    
    id mock = [AMTClassMock mock:[AMTTestClass class]];
    [mock when:[mock methodWithOneParam:@"test" two:@"two" three:@"three" four:@"three"] thenReturn:@"not okay"];
    
    STAssertEqualObjects([AMTTestClass methodWithOneParam:@"test" two:@"test" three:@"test" four:@"test"], @"not okay", nil);
}

- (void)testMockingAClassWithPrimitiveParameters {
    STAssertEqualObjects([AMTTestClass methodWithOnePrimitiveParam:1], @"one primitive", nil);
    
    id mock = [AMTClassMock mock:[AMTTestClass class]];
    [mock when:[mock methodWithOnePrimitiveParam:5] thenReturn:@"not okay"];
    
    STAssertEqualObjects([AMTTestClass methodWithOnePrimitiveParam:5], @"not okay", nil);
}

- (void)testMockingUsingSelector {
    STAssertEqualObjects([AMTTestClass methodWithNoParams], @"okay", nil);
    
    id mock = [AMTClassMock mock:[AMTTestClass class]];
    [mock whenSelector:@selector(methodWithNoParams) thenReturn:@"not okay"];
    
    STAssertEqualObjects([AMTTestClass methodWithNoParams], @"not okay", nil);
}

- (void)testMockingUsingSelectorWithAParameter {
    STAssertEqualObjects([AMTTestClass methodWithOneParam:@"test"], @"one", nil);
    
    id mock = [AMTClassMock mock:[AMTTestClass class]];
    [mock whenSelector:@selector(methodWithOneParam:) thenReturn:@"not okay"];
    
    STAssertEqualObjects([AMTTestClass methodWithOneParam:@"test"], @"not okay", nil);
}

- (void)testMockingAClassWithAVoidMethod {
    id mock = [AMTClassMock mock:[AMTTestClass class]];
    [(id)[mock doNothingFor] voidMethod];
    
    // if no exception is raised, then the test should pass
    [AMTTestClass voidMethod];
}

- (void)testMockingAClassWithAVoidMethodUsingSelector {
    id mock = [AMTClassMock mock:[AMTTestClass class]];
    [mock doNothingForSeletor:@selector(voidMethod)];
    
    // if no exception is raised, then the test should pass
    [AMTTestClass voidMethod];
}

- (void)testToMakeSureTheOriginalMethodAndImplementationArePutBackWhenMockingIsRemoved {
    
    STAssertEqualObjects([AMTTestClass methodWithNoParams], @"okay", nil);

    id mock = [AMTClassMock mock:[AMTTestClass class]];
    [mock when:[mock methodWithNoParams] thenReturn:@"not okay"];

    STAssertEqualObjects([AMTTestClass methodWithNoParams], @"not okay", nil);
    
    [mock removeMocking];
    
    STAssertEqualObjects([AMTTestClass methodWithNoParams], @"okay", nil);

}

- (void)testToMakeSureTheOriginalMethodAndImplementationArePutBackOnDealloc {
    
    STAssertEqualObjects([AMTTestClass methodWithNoParams], @"okay", nil);
    
    // need the autorelease pool because mock: will return an autoreleased instance of AMTClassMock.
    @autoreleasepool {
        id mock = [AMTClassMock mock:[AMTTestClass class]];
        [mock when:[mock methodWithNoParams] thenReturn:@"not okay"];
        
        STAssertEqualObjects([AMTTestClass methodWithNoParams], @"not okay", nil);
        mock = nil;
    }
    
    STAssertEqualObjects([AMTTestClass methodWithNoParams], @"okay", nil);
}

- (void)testMockingTwoClasses {
    STAssertEqualObjects([AMTTestClass methodWithNoParams], @"okay", nil);
    STAssertEqualObjects([AMTSecondTestClass methodWithNoParams], @"second class okay", nil);
    
    id mockOne = [AMTClassMock mock:[AMTTestClass class]];
    [mockOne when:[mockOne methodWithNoParams] thenReturn: @"not okay"];
    
    id mockTwo = [AMTClassMock mock:[AMTSecondTestClass class]];
    [mockTwo when:[mockTwo methodWithNoParams] thenReturn: @"second class not okay"];
    
    STAssertEqualObjects([AMTTestClass methodWithNoParams], @"not okay", nil);
    STAssertEqualObjects([AMTSecondTestClass methodWithNoParams], @"second class not okay", nil);
}

- (void)testRemovingTheMockingFromOneClassDoesntAffectTheOther {
    STAssertEqualObjects([AMTTestClass methodWithNoParams], @"okay", nil);
    STAssertEqualObjects([AMTSecondTestClass methodWithNoParams], @"second class okay", nil);
    
    id mockOne = [AMTClassMock mock:[AMTTestClass class]];
    [mockOne when:[mockOne methodWithNoParams] thenReturn: @"not okay"];
    
    id mockTwo = [AMTClassMock mock:[AMTSecondTestClass class]];
    [mockTwo when:[mockTwo methodWithNoParams] thenReturn: @"second class not okay"];
    
    STAssertEqualObjects([AMTTestClass methodWithNoParams], @"not okay", nil);
    STAssertEqualObjects([AMTSecondTestClass methodWithNoParams], @"second class not okay", nil);
    
    [mockOne removeMocking];
    
    STAssertEqualObjects([AMTTestClass methodWithNoParams], @"okay", nil);
    STAssertEqualObjects([AMTSecondTestClass methodWithNoParams], @"second class not okay", nil);
}

- (void)testVerifingAMethodIsCalledOneTime {
    id mock = [AMTClassMock mock:[AMTTestClass class]];
    [mock expect:[mock methodWithNoParams]];
    
    [AMTTestClass methodThatCallsMethodWithNoParamsNumberOfTimes:1];
    
    // if no exception is thrown then the test will pass
    [mock verify];
}

- (void)testVerifingAMethodIsCalledMoreThanOneTime {
    id mock = [AMTClassMock mock:[AMTTestClass class]];
    [mock expect:[mock methodWithNoParams] toBeExecutedNumberOfTimes:3];
    
    [AMTTestClass methodThatCallsMethodWithNoParamsNumberOfTimes:3];
    
    // if no exception is thrown then the test will pass
    [mock verify];
}

- (void)testVerifingAMethodIsCalledOneTimeUsingSelector {
    id mock = [AMTClassMock mock:[AMTTestClass class]];
    [mock expectSelector:@selector(methodWithNoParams)];
    
    [AMTTestClass methodThatCallsMethodWithNoParamsNumberOfTimes:1];
    
    // if no exception is thrown then the test will pass
    [mock verify];
}

- (void)testVerifyFailsATestIfMethodIsNeverCalled {
    id mock = [AMTClassMock mock:[AMTTestClass class]];
    [mock expect:[mock methodWithNoParams]];
    
    STAssertThrows([mock verify], @"The verify method should throw an exception");
}

- (void)testVerifyFailsATestIfMethodIsCalledTheWrongNumberOfTimes {
    id mock = [AMTClassMock mock:[AMTTestClass class]];
    [mock expect:[mock methodWithNoParams] toBeExecutedNumberOfTimes:2];
    
    [AMTTestClass methodThatCallsMethodWithNoParamsNumberOfTimes:3];
    
    STAssertThrows([mock verify], @"The verify method should throw an exception");
}

- (void)testBothStubbingAndVerifyingAMethod {
    id mock = [AMTClassMock mock:[AMTTestClass class]];
    [mock when:[mock methodWithNoParams] thenReturn:@"not okay"];
    
    STAssertEqualObjects([AMTTestClass methodWithNoParams], @"not okay", nil);
    
    [mock expect:[mock methodWithNoParams]];
    
    STAssertEqualObjects([AMTTestClass methodWithNoParams], @"not okay", nil);
    
    [mock verify];
}

- (void)testVerifyMockingIsRemovedAfterResettingWhenbothStubbingAndVerifingAMethod {
    STAssertEqualObjects([AMTTestClass methodWithNoParams], @"okay", nil);
    
    id mock = [AMTClassMock mock:[AMTTestClass class]];
    [mock when:[mock methodWithNoParams] thenReturn:@"not okay"];
    [mock expect:[mock methodWithNoParams]];
    
        
    STAssertEqualObjects([AMTTestClass methodWithNoParams], @"not okay", nil);
    
    [mock removeMocking];
    
    STAssertEqualObjects([AMTTestClass methodWithNoParams], @"okay", nil);
    
}

@end
