//
//  Arbiter.m
//  Arbiter
//
//  Created by Andy Zinsser on 12/5/13.
//  Copyright (c) 2013 Arbiter. All rights reserved.
//

#import "Arbiter.h"

// Production URLS
NSString * const APIUserInitializeURL = @"https://www.arbiter.me/api/v1/user/initialize";
NSString * const APIWalletURL = @"https://www.arbiter.me/api/v1/wallet/";
NSString * const APIUserLoginURL = @"https://www.arbiter.me/api/v1/user/login";
NSString * const APILinkWithGameCenterURL = @"https://www.arbiter.me/api/v1/user/link-with-game-center";
NSString * const APIUserDetailsURL = @"https://www.arbiter.me/api/v1/user/";

// Local URLS
//NSString * const APIUserInitializeURL = @"http://10.0.0.6:5000/api/v1/user/initialize";
//NSString * const APIWalletURL = @"http://10.0.0.6:5000/api/v1/wallet/";
//NSString * const APIUserLoginURL = @"http://10.0.0.6:5000/api/v1/user/login";
//NSString * const APILinkWithGameCenterURL = @"http://10.0.0.6:5000/api/v1/user/link-with-game-center";
//NSString * const APIUserDetailsURL = @"http://10.0.0.6:5000/api/v1/user/";


@implementation Arbiter


#pragma mark Arbiter Methods

- (id)init:(void(^)(NSDictionary *))handler
{
    self = [super init];
    if ( self ) {
        _connectionHandler = [^(NSDictionary *responseDict) {
            self.userId = [responseDict objectForKey:@"user_id"];
            handler(responseDict);
        } copy];

        NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:APIUserInitializeURL]];
        [NSURLConnection connectionWithRequest:request delegate:self];
    }
    return self;
}

- (void)verifyUser:(void(^)(NSDictionary *))handler
{
    _connectionHandler = [^(NSDictionary *responseDict) {
        self.verificationUrl = [responseDict objectForKey:@"verification_url"];

        if ([[responseDict objectForKey:@"success"] boolValue] == NO) {
            NSString *error = [responseDict objectForKey:@"errors"][0];
            if ([error isEqualToString:@"This user has not verified their age."]) {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle: @"You must be at least 18 years old to bet in this game."
                    message: @"By clicking confirm below, you are confirming that you are at least 18 years old and agree to the terms and conditions at https://www.arbiter.me/terms"
                    delegate: self
                    cancelButtonTitle:@"Cancel"
                    otherButtonTitles:@"Agree", nil];
                [alert show];

                _completionHandler = [handler copy];
            } else {
                // TODO: Pass in a zip code that fails
                //       check what the error message is
                //       display apology alert
                //       the confirm click should close the dialog and return to the game state
                NSLog(@"TODO: Handle apology message: %@", error);
                handler(responseDict);
            }
        } else {
            // The user has already agreed to the terms before
            handler(responseDict);
        }
    } copy];

    NSString *walletUrl = [APIWalletURL stringByAppendingString:self.userId];
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:walletUrl]];
    [NSURLConnection connectionWithRequest:request delegate:self];
}

- (void)getWallet:(void(^)(NSDictionary *))handler
{
    _connectionHandler = [^(NSDictionary *responseDict) {
        // TODO: put any update / polling patterns here
        NSLog(@"saving wallet");
        self.wallet = [responseDict objectForKey:@"wallet"];
        handler(responseDict);
    } copy];

    NSString *walletUrl = [APIWalletURL stringByAppendingString:self.userId];
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:walletUrl]];
    [NSURLConnection connectionWithRequest:request delegate:self];
}

- (void)copyDepositAddressToClipboard
{
    UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
    pasteboard.string = [self.wallet objectForKey:@"deposit_address"];
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Successfully Copied Address" message:@"Now use your preferred Bitcoin wallet to send some Bitcoin to that address. We suggest using Coinbase.com." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [alert show];
}


#pragma mark NSURLConnection Delegate Methods

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    NSLog(@"aa: connection didReceiveResponse");
    _responseData = [[NSMutableData alloc] init];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    NSLog(@"aa: connection didReceiveData");
    [_responseData appendData:data];
}

- (NSCachedURLResponse *)connection:(NSURLConnection *)connection
                  willCacheResponse:(NSCachedURLResponse*)cachedResponse {
    NSLog(@"aa: connection cachedResponse");
    return nil;
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    NSLog(@"aa: connectionDidFinishLoading");
    NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:_responseData options:NSJSONReadingMutableLeaves error:nil];
    NSLog(@"%@", dict);
    _connectionHandler(dict);
    _connectionHandler = nil;
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    NSLog(@"aa: connection didFailWithError");
    NSLog(@"%@", error);
    NSDictionary *dict = [[NSDictionary alloc] initWithObjectsAndKeys:error, @"error", nil];
    _connectionHandler(dict);
    _connectionHandler = nil;
}

#pragma mark UIAlertView Delegate Methods

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 1) {
        _connectionHandler = [^(NSDictionary *responseDict) {
            if ([[responseDict objectForKey:@"success"] boolValue] == true) {
                NSLog(@"saving wallet");
                self.wallet = [responseDict objectForKey:@"wallet"];
            }
            _completionHandler(responseDict);
            _completionHandler = nil;
        } copy];

        NSDictionary *postDict = [[NSDictionary alloc] initWithObjectsAndKeys:@"true", @"agreed_to_terms",
                                                                              @"true", @"confirmed_age", nil];
        NSError *error;
        NSData *postData = [NSJSONSerialization dataWithJSONObject:postDict options:NSJSONWritingPrettyPrinted error:&error];

        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:self.verificationUrl]];
        [request setHTTPMethod:@"POST"];
        [request setValue:@"application/json; charset=UTF-8" forHTTPHeaderField:@"Content-Type"];
        [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
        [request setHTTPBody:postData];
        [NSURLConnection connectionWithRequest:request delegate:self];
    }
}

@end