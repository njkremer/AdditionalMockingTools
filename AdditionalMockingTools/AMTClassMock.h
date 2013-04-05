//
//  AMTClassMock.h
//  AdditionalMockingTools
//
//  Copyright (c) 2012 Nick Kremer. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AMTClassMock : NSObject
@property (strong, nonatomic) Class mockedClass;

+ (id)mock:(Class)mockedClass;

- (void)when:(id)method thenReturn:(id)value;
- (void)whenSelector:(SEL)selector thenReturn:(id)value;

- (id)doNothingFor;
- (void)doNothingForSeletor:(SEL)selector;

- (void)expect:(id)method toBeExecutedNumberOfTimes:(int)times;
- (void)expectSelector:(SEL)method toBeExecutedNumberOfTimes:(int)times;

- (void)expect:(id)method;
- (void)expectSelector:(SEL)selector;

- (void)verify;

- (void)removeMocking;
@end
