//
//  GlobalData.m
//  Arbiter Example
//
//  Created by Andy Zinsser on 12/10/13.
//  Copyright (c) 2013 Arbiter. All rights reserved.
//

#import "GlobalData.h"

@implementation GlobalData

@synthesize arbiterUserId;
@synthesize arbiter;


#pragma mark Singleton Methods

+ (id)sharedInstance
{
    static GlobalData *sharedGlobalData = nil;
    @synchronized(self) {
        if (sharedGlobalData == nil) {
            sharedGlobalData = [[self alloc] init];
        }
    }
    return sharedGlobalData;
}

- (id)init
{
    if (self = [super init]) {
        // Set default values
        arbiterUserId = nil;
        arbiter = nil;
    }
    return self;
}

- (void)dealloc {
    
}

@end
