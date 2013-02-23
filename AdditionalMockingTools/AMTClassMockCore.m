//
//  AMTClassMockCore.m
//  AdditionalMockingTools
//
//  Copyright (c) 2012 Nick Kremer. All rights reserved.
//

#import "AMTClassMockCore.h"

@implementation AMTClassMockCore

- (id)init {
    if(self = [super init]) {
        _returnValues = [[NSMutableDictionary alloc] init];
        _orignalImplementations = [[NSMutableDictionary alloc] init];
        _orignalMethods = [[NSMutableDictionary alloc] init];
        _doNothingMethods = [[NSMutableArray alloc] init];
        _expectedMethods = [[NSMutableDictionary alloc] init];
        _verifiedMethods = [[NSMutableDictionary alloc] init];
    }
    return self;
}

- (void)reset {
    [_returnValues removeAllObjects];
    [_orignalMethods removeAllObjects];
    [_orignalImplementations removeAllObjects];
    [_doNothingMethods removeAllObjects];
    [_expectedMethods removeAllObjects];
    [_verifiedMethods removeAllObjects];
}

@end
