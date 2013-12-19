//
//  GlobalData.m
//  Arbiter Example
//
//  Created by Andy Zinsser on 12/10/13.
//  Copyright (c) 2013 Arbiter. All rights reserved.
//

#import <GameKit/GameKit.h>
#import "GlobalData.h"

@implementation GlobalData

@synthesize arbiter;
@synthesize localPlayer;


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
        arbiter = nil;
        localPlayer = [GKLocalPlayer localPlayer];
    }
    return self;
}

@end
