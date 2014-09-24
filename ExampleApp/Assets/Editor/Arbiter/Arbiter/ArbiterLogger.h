//
//  ArbiterLogger.h
//  Unity-iPhone
//
//  Created by Andy Zinsser on 9/23/14.
//
//

#import "Arbiter.h"

// To prevent compil
@class Arbiter;

@interface ArbiterLogger : NSObject <NSURLConnectionDelegate>

+ (ArbiterLogger *)sharedManager;
- (void)reportLog:(NSMutableDictionary *)log arbiterState:(Arbiter *)arbiterState;

@end