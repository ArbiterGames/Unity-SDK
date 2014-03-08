//
//  Arbiter.m
//  Arbiter
//
//  Created by Andy Zinsser on 12/5/13.
//  Copyright (c) 2013 Arbiter. All rights reserved.
//

#import <GameKit/GameKit.h>
#import "Arbiter.h"

// Production URLS
NSString * const APIUserInitializeURL = @"https://www.arbiter.me/api/v1/user/initialize";
NSString * const APIWalletURL = @"https://www.arbiter.me/api/v1/wallet/";
NSString * const APIUserLoginURL = @"https://www.arbiter.me/api/v1/user/login";
NSString * const APILinkWithGameCenterURL = @"https://www.arbiter.me/api/v1/user/link-with-game-center";
NSString * const APIUserDetailsURL = @"https://www.arbiter.me/api/v1/user/";

// Local URLS
/*
NSString * const APIUserInitializeURL = @"http://10.1.60.1:5000/api/v1/user/initialize";
NSString * const APIWalletURL = @"http://10.1.60.1:5000/api/v1/wallet/";
NSString * const APIUserLoginURL = @"http://10.1.60.1:5000/api/v1/user/login";
NSString * const APILinkWithGameCenterURL = @"http://10.1.60.1:5000/api/v1/user/link-with-game-center";
NSString * const APIUserDetailsURL = @"http://10.1.60.1:5000/api/v1/user/";
*/

#define SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(v)  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedAscending)


@implementation Arbiter


#pragma mark Arbiter Methods

/** ttt from other repo... integrate or delete each one of these!


- (void)withdrawWithSettings:(NSDictionary *)settings callback:(void (^)(NSString *))handler
{
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [manager POST:[NSString stringWithFormat:@"%@%@", APIWalletURL, self.session.userId]
       parameters:settings
          success:^(AFHTTPRequestOperation *operation, id responseObject)
     {
         NSDictionary *jsonDict = (NSDictionary *) responseObject;
         BOOL success = [[jsonDict objectForKey:@"success"] boolValue];

         if (success) {
             self.wallet = [[ArbiterWallet alloc] initWithDetails:[jsonDict objectForKey:@"wallet"]];
             _completionHandler = [handler copy];
             _completionHandler(@"true");
             _completionHandler = nil;
         } else {
             NSString *verificationURL = [jsonDict objectForKey:@"verification_url"];
             ArbiterVerificationWebView *view = [[ArbiterVerificationWebView alloc] initWithVerificationURL:verificationURL callback:handler];
             view = nil;
         }
     }
          failure:^(AFHTTPRequestOperation *operation, NSError *error)
     {
         NSLog(@"Withdraw error: %@", error);
     }];
}

- (void)claimAccountWithCredentials:(NSDictionary *)credentials callback:(void (^)(NSString *))handler
{
    _completionHandler = [handler copy];

    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [manager GET:[NSString stringWithFormat:@"%@%@", APIUserDetailsURL, self.session.userId]
      parameters:nil
         success:^(AFHTTPRequestOperation *operation, id responseObject)
     {
         NSDictionary *jsonDict = (NSDictionary *) responseObject;
         NSDictionary *user = [jsonDict objectForKey:@"user"];
         NSString *redemptionURL = [user objectForKey:@"account_redemption_url"];
         if ([redemptionURL isEqual:@"User already redeemed their account"]) {
             NSLog(@"Alreday claimed");
             _completionHandler(@"true");
             _completionHandler(nil);
         } else {
             AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
             [manager POST:redemptionURL
                parameters:credentials
                   success:^(AFHTTPRequestOperation *operation, id responseObject)
              {
                  NSDictionary *jsonDict = (NSDictionary *) responseObject;
                  BOOL success = [[jsonDict objectForKey:@"success"] boolValue];
                  if (success) {
                      _completionHandler(@"true");
                      _completionHandler = nil;
                  } else {
                      NSArray *errors = [jsonDict objectForKey:@"errors"];
                      NSString *error = [errors objectAtIndex:0];
                      _completionHandler(error);
                      _completionHandler = nil;
                  }
              }
                   failure:^(AFHTTPRequestOperation *operation, NSError *error)
              {
                  NSLog(@"Error making claim request: %@", error);
              }];
         }
     }
         failure:^(AFHTTPRequestOperation *operation, NSError *error)
     {
         NSLog(@"Error making redemption url request: %@", error);
     }];
}

- (void)loginWithCredentials:(NSDictionary *)credentials callback:(void (^)(NSString *))handler
{
    [self logout];
    _completionHandler = [handler copy];
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [manager POST:APIUserLoginURL
       parameters:credentials
          success:^(AFHTTPRequestOperation *operation, id responseObject)
     {
         NSDictionary *jsonDict = (NSDictionary *) responseObject;
         NSDictionary *user = [jsonDict objectForKey:@"user"];
         self.session.userId = [user objectForKey:@"uid"];
         self.session.username = [user objectForKey:@"username"];
         [self getWalletDetailsWithCallback:handler];
     }
          failure:^(AFHTTPRequestOperation *operation, NSError *error)
     {
         NSLog(@"Error making redemption url request: %@", error);
     }];
}

- (void)logout
{
    NSHTTPCookie *cookie;
    for (cookie in [[NSHTTPCookieStorage sharedHTTPCookieStorage] cookies])
    {
        if ([cookie.domain  isEqual: @"www.arbiter.me"]) {
            [[NSHTTPCookieStorage sharedHTTPCookieStorage] deleteCookie:cookie];
        }
    }
}

*/


- (id)init:(void(^)(NSDictionary *))handler
{
    self = [super init];
    if ( self ) {
        
        _responseDataRegistry = [[NSMutableDictionary alloc] init];
        _connectionHandlerRegistry = [[NSMutableDictionary alloc] init];
        
        void (^connectionHandler)(NSDictionary *) = [^(NSDictionary *responseDict) {
                NSDictionary *userDict = [responseDict objectForKey:@"user"];
                self.userId = [userDict objectForKey:@"id"];
                self.wallet = [responseDict objectForKey:@"wallet"]; // NOTE: it's ok if this is nil
                handler(responseDict);
            } copy];
        [_connectionHandlerRegistry setObject:connectionHandler forKey:APIUserInitializeURL];
        
//       TODO - delete
//        _connectionHandler = [^(NSDictionary *responseDict) {
//            NSDictionary *userDict = [responseDict objectForKey:@"user"];
//            self.userId = [userDict objectForKey:@"id"];
//            self.wallet = [responseDict objectForKey:@"wallet"]; // NOTE: it's ok if this is nil
//            handler(responseDict);
//        } copy];
        
        NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:APIUserInitializeURL]];
        [NSURLConnection connectionWithRequest:request delegate:self];
    }
    return self;
}


- (void)loginWithGameCenterPlayer:(void(^)(NSDictionary *))handler
{
    //
    // Note/TODO: This function assumes the player used Unity to authenticate. Would be better to handle this all native...
    //

    void (^connectionHandler)(NSDictionary *) = [^(NSDictionary *responseDict) {
        handler(responseDict);
    } copy];

    NSDictionary *response;
    
    [_connectionHandlerRegistry setObject:connectionHandler forKey:APILinkWithGameCenterURL];

    if( !SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO( @"7.0" )) {
        response = @{
            @"success": @"false",
            @"errors": @[@"Linking a Game Center account requires iOS >=7.0"]
        };
        handler(response);
        return;
    }

    GKLocalPlayer *localPlayer = [GKLocalPlayer localPlayer];
    if( !localPlayer.isAuthenticated ) {
        response = @{
            @"success": @"false",
            @"errors": @[@"local player is not authenticated"]
        };
        handler(response);
    } else {
        [localPlayer generateIdentityVerificationSignatureWithCompletionHandler:^(NSURL *publicKeyUrl, NSData *signature, NSData *salt, uint64_t timestamp, NSError *error) {
            if (error) {
                NSLog(@"ERROR: %@", error);
                connectionHandler( @{
                    @"success": @"false",
                    @"errors": @[error]
                });
//                connectionHandler = nil;
            }
            else {
                NSDictionary *paramsDict = @{
                    @"publicKeyUrl":[publicKeyUrl absoluteString],
                    @"timestamp":[NSString stringWithFormat:@"%llu", timestamp],
                    @"signature":[signature base64EncodedStringWithOptions:0],
                    @"salt":[salt base64EncodedStringWithOptions:0],
                    @"playerID":localPlayer.playerID,
                    @"bundleID":[[NSBundle mainBundle] bundleIdentifier]
                };

                NSError *error;
                NSData *paramsData = [NSJSONSerialization dataWithJSONObject:paramsDict
                                                                     options:0
                                                                       error:&error];
                if( !paramsData ) {
                    NSLog(@"ERROR: %@", error);
                    connectionHandler( @{
                        @"success": @"false",
                        @"errors": @[error]
                    });
//                    connectionHandler = nil;
                } else {
                    NSString *paramsStr = [[NSString alloc] initWithData:paramsData encoding:NSUTF8StringEncoding];
                    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:APILinkWithGameCenterURL]
                                                                           cachePolicy:NSURLRequestUseProtocolCachePolicy
                                                                       timeoutInterval:60.0];
                    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
                    [request setHTTPMethod:@"POST"];
                    [request setHTTPBody:[paramsStr dataUsingEncoding:NSUTF8StringEncoding]];

                    [NSURLConnection connectionWithRequest:request delegate:self];
                }
            }
        }];
    }
}

- (void)verifyUser:(void(^)(NSDictionary *))handler
{
    void (^connectionHandler)(NSDictionary *) = [^(NSDictionary *responseDict) {
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

    NSString *userIdPlusVerify = [NSString stringWithFormat:@"%@/verify", self.userId];
    NSString *verifyUrl = [APIUserDetailsURL stringByAppendingString:userIdPlusVerify];
    [_connectionHandlerRegistry setObject:connectionHandler forKey:verifyUrl];
    
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:verifyUrl]];
    [NSURLConnection connectionWithRequest:request delegate:self];
}

- (void)getWallet:(void(^)(NSDictionary *))handler
{
    void (^connectionHandler)(NSDictionary *) = [^(NSDictionary *responseDict) {
        // TODO: put any update / polling patterns here
        NSLog(@"saving wallet");
        self.wallet = [responseDict objectForKey:@"wallet"];
        handler(responseDict);
    } copy];

    NSString *walletUrl = [APIWalletURL stringByAppendingString:self.userId];
    [_connectionHandlerRegistry setObject:connectionHandler forKey:walletUrl];
    
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
    [_responseDataRegistry setObject:[[NSMutableData alloc] init] forKey:[[connection currentRequest] URL]];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    NSLog(@"aa: connection didReceiveData");
    [[_responseDataRegistry objectForKey: [[connection currentRequest] URL]] appendData:data];
}

- (NSCachedURLResponse *)connection:(NSURLConnection *)connection
                  willCacheResponse:(NSCachedURLResponse*)cachedResponse {
    NSLog(@"aa: connection cachedResponse");
    return nil;
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    NSLog(@"aa: connectionDidFinishLoading: %@", [[connection currentRequest] URL]);
    NSString *connectionURL = [NSString stringWithFormat:@"%@", [[connection currentRequest] URL]];
    NSError *error = nil;
    NSData *responseData = [_responseDataRegistry objectForKey:[[connection currentRequest] URL]];
    NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:responseData options:NSJSONReadingMutableLeaves error:&error];
    
    if( error ) {
        NSLog( @"Error: %@", error );
        dict = @{@"success": @"false", @"errors":@[@"Received null response from connection."]};
    } else {
        NSLog( @"%@", dict );
    }
    
    void (^handler)(id) = [_connectionHandlerRegistry objectForKey:connectionURL];
    handler(dict);
    
//    [_responseDataRegistry removeObjectForKey:connectionURL];
//    [_connectionHandlerRegistry removeObjectForKey:connectionURL];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    NSLog(@"aa: connection didFailWithError");
    NSLog(@"%@", error);
    NSDictionary *dict = [[NSDictionary alloc] initWithObjectsAndKeys:@[[error localizedDescription]], @"errors", @"false", @"success", nil];
    NSString *connectionURL = [NSString stringWithFormat:@"%@", [[connection currentRequest] URL]];

    void (^handler)(id) = [_connectionHandlerRegistry objectForKey:connectionURL];
    handler(dict);
    
    [_responseDataRegistry removeObjectForKey:connectionURL];
    [_connectionHandlerRegistry removeObjectForKey:connectionURL];
}

#pragma mark UIAlertView Delegate Methods

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    _connectionHandler = [^(NSDictionary *responseDict) {
        if ([[responseDict objectForKey:@"success"] boolValue] == true) {
            NSLog(@"saving wallet");
            self.wallet = [responseDict objectForKey:@"wallet"];
        }
        _completionHandler(responseDict);
        _completionHandler = nil;
    } copy];

    if (buttonIndex == 0) {
        NSLog(@"User has hit the cancel button.");
        NSDictionary *dict = @{@"success": @"false", @"errors":@[@"User has canceled verification."]};
        _connectionHandler(dict);
        _connectionHandler = nil;
    } else if (buttonIndex == 1) {
        NSDictionary *postDict = [[NSDictionary alloc] initWithObjectsAndKeys:@"true", @"agreed_to_terms",
                                                                              @"true", @"confirmed_age", nil];
        NSError *error;
        NSData *postData = [NSJSONSerialization dataWithJSONObject:postDict options:NSJSONWritingPrettyPrinted error:&error];

        NSMutableString *verificationUrl = [NSMutableString stringWithString: APIUserDetailsURL];
        [verificationUrl appendString: self.userId];
        [verificationUrl appendString: @"/verify"];

        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:verificationUrl]];
        [request setHTTPMethod:@"POST"];
        [request setValue:@"application/json; charset=UTF-8" forHTTPHeaderField:@"Content-Type"];
        [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
        [request setHTTPBody:postData];
        [NSURLConnection connectionWithRequest:request delegate:self];
    }
}

@end