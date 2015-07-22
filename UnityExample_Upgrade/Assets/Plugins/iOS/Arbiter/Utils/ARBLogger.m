//
//  ARBLogger.m
//  Unity-iPhone
//
//  Created by Andy Zinsser on 9/23/14.
//
//

#import "ARBLogger.h"


@implementation ARBLogger
{
        NSMutableArray *logQueue;
}

static ARBLogger* instance;

/**
 Example usage:
 #import "ArbiterLogQueue.h"
 [[ARBLogger sharedManager] reportLog:[NSMutableDictionary]} arbiterState:arbiter];
 */

+ (ARBLogger *)sharedManager
{
    static dispatch_once_t dispatchOnceToken;
    dispatch_once(&dispatchOnceToken, ^{
        instance = [[ARBLogger alloc] init];
    });
    return instance;
}

- (void)reportLog:(NSMutableDictionary *)log arbiterState:(Arbiter *)arbiterState
{
    if ( logQueue == nil ) {
        logQueue = [[NSMutableArray alloc] init];
    }
    
    NSDictionary *device = @{@"name": [[UIDevice currentDevice] name],
                             @"version": [[UIDevice currentDevice] systemVersion],
                             @"model": [[UIDevice currentDevice] systemName]};
    [log setObject:device forKey:@"device"];
    
    if ( arbiterState.user != nil ) {
        [log setObject:arbiterState.user forKey:@"user"];
    }
    
    if ( arbiterState.game != nil ) {
        NSString *version = [[NSBundle mainBundle] objectForInfoDictionaryKey:(NSString *)kCFBundleVersionKey];
        NSDictionary *game = @{@"name": [arbiterState.game objectForKey:@"name"],
                               @"is_active": [arbiterState.game objectForKey:@"is_active"],
                               @"is_live": [arbiterState.game objectForKey:@"is_live"],
                               @"skill_predominance": [arbiterState.game objectForKey:@"skill_predominance"],
                               @"version": version};
        [log setObject:game forKey:@"game"];
    }

    
    [logQueue addObject:log];
    [self unloadQueueToServer];
}

- (void)unloadQueueToServer
{
    // TODO:
    // Check if there is a connection
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
    // No-op since we don't need any info back
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    // No-op since we don't need any info back
}

- (NSCachedURLResponse *)connection:(NSURLConnection *)connection
                  willCacheResponse:(NSCachedURLResponse*)cachedResponse {
    return nil;
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    // No-op since we don't need any info back
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    NSLog(@"connection error:%@", error);
}


@end