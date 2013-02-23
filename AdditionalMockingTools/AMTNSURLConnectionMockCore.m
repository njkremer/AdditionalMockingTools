//
//  AMTNSURLConnectionMockCore.m
//  AdditionalMockingTools
//
//  Copyright (c) 2012 Nick Kremer. All rights reserved.
//

#import "AMTNSURLConnectionMockCore.h"

@implementation AMTNSURLConnectionMockCore
- (void)reset {
    _response = nil;
    _data = nil;
    _error = nil;
    _request = nil;
}
@end
