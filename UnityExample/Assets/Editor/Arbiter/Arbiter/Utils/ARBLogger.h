//
//  ARBLogger.h
//  Unity-iPhone
//
//  Created by Andy Zinsser on 9/23/14.
//
//

#import "Arbiter.h"

// Prevents errors from compilation ordering
@class Arbiter;

@interface ARBLogger : NSObject <NSURLConnectionDelegate>

+ (ARBLogger *)sharedManager;
- (void)reportLog:(NSMutableDictionary *)log arbiterState:(Arbiter *)arbiterState;

@end