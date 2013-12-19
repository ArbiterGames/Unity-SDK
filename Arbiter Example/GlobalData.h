//
//  GlobalData.h
//  Arbiter Example
//
//  Created by Andy Zinsser on 12/10/13.
//  Copyright (c) 2013 Arbiter. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Arbiter/Arbiter.h>
#import <GameKit/GameKit.h>

@interface GlobalData : NSObject

@property (strong, nonatomic) Arbiter *arbiter;
@property (strong, nonatomic) GKLocalPlayer *localPlayer;

+ (id)sharedInstance;

@end
