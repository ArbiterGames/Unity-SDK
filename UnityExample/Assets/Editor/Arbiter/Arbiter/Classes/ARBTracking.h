//
//  ARBTracking.h
//  Unity-iPhone
//
//  Created by Andy Zinsser on 10/27/14.
//
//

#import "Mixpanel.h"

@interface ARBTracking : Mixpanel

+ (ARBTracking *)arbiterInstanceWithToken:(NSString *)apiToken;
+ (ARBTracking *)arbiterInstance;

@end
