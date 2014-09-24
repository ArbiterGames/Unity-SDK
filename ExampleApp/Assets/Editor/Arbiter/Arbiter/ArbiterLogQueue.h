//
//  ArbiterLogQueue.h
//  Unity-iPhone
//
//  Created by Andy Zinsser on 9/23/14.
//
//

#import <Foundation/Foundation.h>

@interface ArbiterLogQueue : NSObject <NSURLConnectionDelegate>

+ (ArbiterLogQueue *)sharedManager;
- (void)reportLog:(NSDictionary *)log;

@end
