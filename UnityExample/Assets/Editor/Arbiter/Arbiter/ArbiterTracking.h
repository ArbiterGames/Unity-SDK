//
//  ArbiterTracking.h
//  Unity-iPhone
//
//  Created by Andy Zinsser on 10/27/14.
//
//

#import "Mixpanel.h"

@interface ArbiterTracking : Mixpanel

+ (ArbiterTracking *)arbiterInstanceWithToken:(NSString *)apiToken;
+ (ArbiterTracking *)arbiterInstance;

@end
