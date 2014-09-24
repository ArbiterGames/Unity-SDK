//
//  ArbiterLogger.m
//  Unity-iPhone
//
//  Created by Andy Zinsser on 9/23/14.
//
//

#import "ArbiterLogger.h"


@implementation ArbiterLogger
{
        NSMutableArray *logQueue;
}

static ArbiterLogger* instance;

/**
 Example usage:
 #import "ArbiterLogQueue.h"
 [[ArbiterLogger sharedManager] reportLog:[NSMutableDictionary]} arbiterState:arbiter];
 */

+ (ArbiterLogger *)sharedManager
{
    static dispatch_once_t dispatchOnceToken;
    dispatch_once(&dispatchOnceToken, ^{
        instance = [[ArbiterLogger alloc] init];
    });
    return instance;
}

- (void)reportLog:(NSMutableDictionary *)log arbiterState:(Arbiter *)arbiterState
{
    if ( logQueue == nil ) {
        logQueue = [[NSMutableArray alloc] init];
    }
    
    // TODO:
    // Get all the info I need from the arbiter state
    NSLog(@"arbiterState: %@", arbiterState);
    
    // This is an example of adding to the log. Repeat this for all other default info we want to grab
    [log setObject:[[UIDevice currentDevice] name] forKey:@"device"];
    
    [logQueue addObject:log];
    [self unloadQueueToServer];
}

- (void)unloadQueueToServer
{
    // TODO:
    // Check if there is a connection
    // If so, loop through each log in the queue
    // Hook up to notification center to get notified when there is a connection
    
    NSArray *logCopy = [[NSArray alloc] initWithArray:logQueue copyItems:YES];
    int logIndex = 0;
    for ( NSDictionary *log in logCopy ) {
        NSError *error = nil;
        NSString *url = @"http://logs.arbiter.me/report";
        NSData *paramsData = [NSJSONSerialization dataWithJSONObject:@{@"data": log}
                                                             options:0
                                                               error:&error];
        NSString *paramsStr = [[NSString alloc] initWithData:paramsData encoding:NSUTF8StringEncoding];
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:url]
                                                               cachePolicy:NSURLRequestUseProtocolCachePolicy
                                                           timeoutInterval:60.0];
        [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
        [request setHTTPMethod:@"POST"];
        [request setHTTPBody:[paramsStr dataUsingEncoding:NSUTF8StringEncoding]];
        [NSURLConnection connectionWithRequest:request delegate:self];
        [logQueue removeObjectAtIndex:logIndex];
        logIndex++;
    }
}


# pragma mark NSURL Connection Delegate Methods

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    NSLog(@"didReceiveResponse");
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    NSLog(@"didReceiveData");
}

- (NSCachedURLResponse *)connection:(NSURLConnection *)connection
                  willCacheResponse:(NSCachedURLResponse*)cachedResponse {
    return nil;
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    NSLog(@"didFinishLoading");
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    NSLog(@"connection error:%@", error);
}


@end