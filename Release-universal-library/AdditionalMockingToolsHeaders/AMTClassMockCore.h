//
//  AMTClassMockCore.h
//  AdditionalMockingTools
//
//  Copyright (c) 2012 Nick Kremer. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AMTClassMockCore : NSObject
@property (strong, nonatomic) NSMutableDictionary *returnValues;
@property (strong, nonatomic) NSMutableDictionary *orignalMethods;
@property (strong, nonatomic) NSMutableDictionary *orignalImplementations;
@property (strong, nonatomic) NSMutableArray *doNothingMethods;
@property (strong, nonatomic) NSMutableDictionary *expectedMethods;
@property (strong, nonatomic) NSMutableDictionary *verifiedMethods;

- (void)reset;
@end
