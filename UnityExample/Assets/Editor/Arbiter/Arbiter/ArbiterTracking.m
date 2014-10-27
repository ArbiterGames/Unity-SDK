//
//  ArbiterTracking.m
//  Unity-iPhone
//
//  Created by Andy Zinsser on 10/27/14.
//
//

#import "ArbiterTracking.h"

@implementation ArbiterTracking


static Mixpanel *arbiterInstance = nil;


+ (Mixpanel *)arbiterInstanceWithToken:(NSString *)apiToken
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        arbiterInstance = [[super alloc] initWithToken:apiToken launchOptions:nil andFlushInterval:60];
    });
    return arbiterInstance;
}

+ (Mixpanel *)arbiterInstance
{
    if (arbiterInstance == nil) {
        NSLog(@"%@ warning arbiterInstance called before arbiterInstanceWithToken:", self);
    }
    return arbiterInstance;
}


@end
