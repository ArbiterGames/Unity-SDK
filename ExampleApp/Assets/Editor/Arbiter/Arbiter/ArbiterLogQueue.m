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


/**
    Example usage:
    #import "ArbiterLogQueue.h"
    [[ArbiterLogQueue sharedManager] reportLog:@{@"event": @"getGameSettings"}];
*/

+ (ArbiterLogQueue *)sharedManager
{
    static dispatch_once_t dispatchOnceToken;
    dispatch_once(&dispatchOnceToken, ^{
        instance = [[ArbiterLogQueue alloc] init];
    });
    return instance;
}

- (void)reportLog:(NSDictionary *)log
{
    if ( logQueue == nil ) {
        logQueue = [[NSMutableArray alloc] init];
    }
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
