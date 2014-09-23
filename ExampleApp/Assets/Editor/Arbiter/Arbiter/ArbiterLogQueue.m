//
//  ArbiterLogQueue.m
//  Unity-iPhone
//
//  Created by Andy Zinsser on 9/23/14.
//
//

#import "ArbiterLogQueue.h"

@implementation ArbiterLogQueue
{
    NSMutableArray *logQueue;
}

static ArbiterLogQueue* instance;


+ (ArbiterLogQueue *)sharedManager
{
    static dispatch_once_t dispatchOnceToken;
    dispatch_once(&dispatchOnceToken, ^{
        instance = [[ArbiterLogQueue alloc] init];
    });
    return instance;
}

- (void)addLog:(NSDictionary *)log
{
    if ( logQueue == nil ) {
        logQueue = [[NSMutableArray alloc] init];
    }
    [logQueue addObject:log];
    NSLog(@"+++ logQueue: %@", logQueue);
    // TODO:
    // Test to make sure I can init this
    // Create the actual queue the log gets added to
    // make sure adding a log from 2 different spots in the code still adds to the same instance
    // whenever this is called, attempt sending the log off to the arbiter-log server
    // Start pulling in the various device data that we would want to collect
}


@end
