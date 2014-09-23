//
//  ArbiterLogQueue.h
//  Unity-iPhone
//
//  Created by Andy Zinsser on 9/23/14.
//
//

#import <Foundation/Foundation.h>

@interface ArbiterLogQueue : NSObject

+ (ArbiterLogQueue *)sharedManager;
- (void)addLog:(NSDictionary *)log;

@end
