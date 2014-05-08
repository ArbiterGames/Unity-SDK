//
//  Arbiter.m
//  Arbiter
//
//  Created by Andy Zinsser on 12/5/13.
//  Copyright (c) 2013 Arbiter. All rights reserved.
//

#import <GameKit/GameKit.h>
#import "Arbiter.h"


//#define PRE_URL @"https://www.arbiter.me/api/v1/"
#define PRE_URL @"http://10.1.60.1:5000/api/v1/"

NSString *const APIUserInitializeURL = PRE_URL @"user/initialize";
NSString *const APIWalletURL = PRE_URL @"wallet/";
NSString *const APIUserLoginURL = PRE_URL @"user/login";
NSString *const APILinkWithGameCenterURL = PRE_URL @"user/link-with-game-center";
NSString *const APIUserDetailsURL = PRE_URL @"user/";
NSString *const APIRequestCompetitionURL = PRE_URL @"competition/";
NSString *const APIReportScoreURLPart1 = PRE_URL @"competition/";
NSString *const APIReportScoreURLPart2 = @"/report-score/";

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

        _alertViewHandlerRegistry = [[NSMutableDictionary alloc] init];
        _responseDataRegistry = [[NSMutableDictionary alloc] init];
        _connectionHandlerRegistry = [[NSMutableDictionary alloc] init];
        NSString *key = [NSString stringWithFormat:@"%@:GET", APIUserInitializeURL];

        void (^connectionHandler)(NSDictionary *) = [^(NSDictionary *responseDict) {
            NSDictionary *userDict = [responseDict objectForKey:@"user"];
            self.userId = [userDict objectForKey:@"id"];
            self.wallet = [responseDict objectForKey:@"wallet"]; // NOTE: it's ok if this is nil
            handler(responseDict);
        } copy];
        [_connectionHandlerRegistry setObject:connectionHandler forKey:key];

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
    NSString *connectionKey = [NSString stringWithFormat:@"%@:POST", APILinkWithGameCenterURL];
    NSDictionary *response;

    [_connectionHandlerRegistry setObject:connectionHandler forKey:connectionKey];

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
                    @"errors": @[[error localizedDescription]]
                });
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
                [alert setTag:2];
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
    NSString *key = [NSString stringWithFormat:@"%@:POST", verifyUrl];
    [_connectionHandlerRegistry setObject:connectionHandler forKey:key];

    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:verifyUrl]];
    [request setHTTPMethod:@"POST"];
    [NSURLConnection connectionWithRequest:request delegate:self];
}

- (void)getWallet:(void(^)(NSDictionary *))handler
{
    void (^connectionHandler)(NSDictionary *) = [^(NSDictionary *responseDict) {
        self.wallet = [responseDict objectForKey:@"wallet"];
        handler(responseDict);
    } copy];

    NSString *walletUrl = [APIWalletURL stringByAppendingString:self.userId];
    NSString *key = [NSString stringWithFormat:@"%@:GET", walletUrl];
    [_connectionHandlerRegistry setObject:connectionHandler forKey:key];

    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:walletUrl]];
    [NSURLConnection connectionWithRequest:request delegate:self];
}


#pragma mark Wallet Display Methods

- (void)showWalletPanel:(void(^)(void))handler
{
    void (^connectionHandler)(void) = [^(void) {
        handler();
    } copy];

    [_alertViewHandlerRegistry setObject:connectionHandler forKey:@"closeWalletHandler"];

    NSString *message = [NSString stringWithFormat: @"Balance: %@ BTC", [self.wallet objectForKey:@"balance"]];
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Wallet" message:message delegate:self cancelButtonTitle:@"Close" otherButtonTitles:@"Refresh", @"Deposit", @"Withdraw", nil];
    [alert setTag:1];
    [alert show];
}

- (void)showDepositPanel
{
    NSString *message = [NSString stringWithFormat: @"%@", [self.wallet objectForKey:@"deposit_address"]];
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Deposit" message:message delegate:self cancelButtonTitle:@"Back" otherButtonTitles:@"Copy Address", nil];
    [alert setTag:4];
    [alert show];
}

- (void)showWithdrawPanel
{
    NSString *message = @"Where should we transfer your balance?";
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Withdraw" message:message delegate:self cancelButtonTitle:@"Back" otherButtonTitles:@"Withdraw", nil];
    [alert setAlertViewStyle:UIAlertViewStylePlainTextInput];

    UITextField *textField = [alert textFieldAtIndex:0];
    textField.placeholder = @"Enter a Bitcoin address";

    [alert setTag:5];
    [alert show];
}

- (void)showWithdrawError:(NSString *)error
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Unsuccessful Withdraw" message:error delegate:self cancelButtonTitle:@"Back" otherButtonTitles:nil];
    [alert show];
}

- (void)copyDepositAddressToClipboard
{
    UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
    pasteboard.string = [self.wallet objectForKey:@"deposit_address"];
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Successfully Copied Address" message:@"Now use your preferred Bitcoin wallet to send some Bitcoin to that address. We suggest using Coinbase.com." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [alert show];
}


#pragma mark Competition Methods

- (void)requestCompetition:(void(^)(NSDictionary *))handler gameName:(NSString*)gameName buyIn:(NSString*)buyIn filters:(NSString*)filters
{
    NSDictionary *paramsDict = @{
        @"game_name": gameName,
        @"buy_in":buyIn,
        @"filters":filters
    };

    void (^connectionHandler)(NSDictionary *) = [^(NSDictionary *responseDict) {
        handler(responseDict);
    } copy];

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
    } else {
        NSString *requestUrl = [APIRequestCompetitionURL stringByAppendingString:self.userId];
        NSString *key = [NSString stringWithFormat:@"%@:POST", requestUrl];
        [_connectionHandlerRegistry setObject:connectionHandler forKey:key];

        NSString *paramsStr = [[NSString alloc] initWithData:paramsData encoding:NSUTF8StringEncoding];
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:requestUrl]
                                                               cachePolicy:NSURLRequestUseProtocolCachePolicy
                                                           timeoutInterval:60.0];
        [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
        [request setHTTPMethod:@"POST"];
        [request setHTTPBody:[paramsStr dataUsingEncoding:NSUTF8StringEncoding]];

        [NSURLConnection connectionWithRequest:request delegate:self];
    }
}


/**
    Makes the request to Arbiter to a paginated set of competitions for this user
 */
- (void)getCompetitions:(void(^)(NSDictionary*))handler page:(NSString *)page
{
    void (^connectionHandler)(NSDictionary *) = [^(NSDictionary *responseDict) {
        NSDictionary *paginationInfo = [responseDict objectForKey:@"competitions"];
        self.previousPageCompetitionsUrl = [NSString stringWithFormat:@"%@", [paginationInfo objectForKey:@"previous"]];
        self.nextPageCompetitionsUrl = [NSString stringWithFormat:@"%@", [paginationInfo objectForKey:@"next"]];
        handler(responseDict);
    } copy];

    // tttd: Should make a helper function to make the post params data instead of copy-pasting it between each function
    NSDictionary *paramsDict = @{
                                 @"game_api_key": @"8b9cdc0af3984f008e92c3e05b22de51", // ttt Get this from a native SDK cached value!
//ttt if page is nil, this crashes!                                 @"page":page,
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
    } else {
        ////// ttt ATTEMPTS AT PASSING IN THE GAME_API_KEY AS HTTP BODY...
        /*
        NSString *requestUrl = [APIRequestCompetitionURL stringByAppendingString:self.userId];
        NSString *key = [NSString stringWithFormat:@"%@:GET", requestUrl];
        [_connectionHandlerRegistry setObject:connectionHandler forKey:key];

        NSString *paramsStr = [[NSString alloc] initWithData:paramsData encoding:NSUTF8StringEncoding];
        NSLog(@"ttt paramsStr=%@",paramsStr);
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:requestUrl]
                                                               cachePolicy:NSURLRequestUseProtocolCachePolicy
                                                           timeoutInterval:60.0];

        /* ttt attempt 1
        [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
        [request setHTTPMethod:@"GET"];
        [request setHTTPBody:[paramsStr dataUsingEncoding:NSUTF8StringEncoding]];
         */
        /* ttt attempt 2
        NSString *post = [NSString stringWithFormat:@"game_api_key=%@", @"asdf"];
        NSData *postData = [post dataUsingEncoding:NSASCIIStringEncoding];
        [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
        [request addValue:[NSString stringWithFormat:@"%d", 11] forHTTPHeaderField:@"Content-Length"];
        [request setHTTPBody:postData];
         */
        /* ttt attempt 3
        NSString *post = [NSString stringWithFormat:@"game_api_key=%@", @"asdf"];
        NSData *postData = [post dataUsingEncoding:NSASCIIStringEncoding];
        [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
        NSString *postLength = [NSString stringWithFormat:@"%d",[postData length]];
        [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
        [request setHTTPBody:postData];
        [request setHTTPMethod:@"PUT"];
         */
        /* ttt attemp 4
        NSString *post = [NSString stringWithFormat:@"{'game_api_key':'%@'", @"asdf"];
        NSData *postData = [post dataUsingEncoding:NSASCIIStringEncoding];
        [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
        NSString *postLength = [NSString stringWithFormat:@"%d",[postData length]];
        [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
        [request setHTTPBody:postData];
        [request setHTTPMethod:@"GET"];
         */
        ////// END OF BODY ATTEMPTS ////////////


        NSString *competitionsUrl;
        if ( [page isEqualToString:@"next"] ) {
            competitionsUrl = self.nextPageCompetitionsUrl;
        } else if ( [page isEqualToString:@"previous"]) {
            competitionsUrl = self.previousPageCompetitionsUrl;
        } else {
            competitionsUrl = [NSString stringWithFormat:@"%@%@?game_api_key=%@", APIRequestCompetitionURL, self.userId, @"8b9cdc0af3984f008e92c3e05b22de51"];
        }

        NSString *key = [NSString stringWithFormat:@"%@:GET", competitionsUrl];
        NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:competitionsUrl]];

        [_connectionHandlerRegistry setObject:connectionHandler forKey:key];
        [NSURLConnection connectionWithRequest:request delegate:self];
    }
}


/**
    Calls getCompetitions, then parses the results and displays the competitions in an alertView
 */
- (void)viewPreviousCompetitions:(void(^)(void))handler page:(NSString *)page
{
    void (^connectionHandler)(NSDictionary *) = [^(NSDictionary (*responseDict)) {
        NSDictionary *competitionSerializer = [responseDict objectForKey:@"competitions"];
        NSArray *competitions = [competitionSerializer objectForKey:@"results"];
        NSMutableString *message = [NSMutableString string];

        if ( [competitions count] > 0 ) {
            for (int i = 0; i < [competitions count]; i++) {
                NSString *createdOn = [[competitions objectAtIndex:i] objectForKey:@"created_on"];
                NSTimeInterval seconds = [createdOn doubleValue] / 1000;
                NSDate *unFormattedDate = [NSDate dateWithTimeIntervalSince1970:seconds];
                NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
                [dateFormatter setDateFormat:@"EEE, MMM d"];
                NSString *competitionString = [NSString stringWithFormat:@"%@ \nBet Size: %@BTC \nYour Score: %@ \nOpponent Score: %@\n\n",
                    [dateFormatter stringFromDate:unFormattedDate],
                    [[[competitions objectAtIndex:i] objectForKey:@"jackpot"] objectForKey:@"buy_in"],
                    [self getPlayerScoreFromCompetition:[competitions objectAtIndex:i]],
                    [self getOpponentScoreFromCompetition:[competitions objectAtIndex:i]]];
                [message appendString:competitionString];
            }
        } else {
            [message appendString:@"No previous games"];
        }

        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Previous Games" message:message delegate:self cancelButtonTitle:@"Close" otherButtonTitles:nil];

        if ( [competitionSerializer objectForKey:@"previous"] != (id)[NSNull null] ) {
            [alert addButtonWithTitle:@"Prev"];
        }
        if ( [competitionSerializer objectForKey:@"next"] != (id)[NSNull null] ) {
            [alert addButtonWithTitle:@"Next"];
        }

        [_alertViewHandlerRegistry setObject:handler forKey:@"closePreviousGamesHandler"];
        [alert setTag:10];
        [alert show];
    } copy];

    [self getCompetitions:connectionHandler page:page];
}


/**
    Gets the latest incomplete competitions from Arbiter. Paginated by 1 comp per page
 */
- (void)getIncompleteCompetitions:(void(^)(NSDictionary*))handler page:(NSString *)page
{
    void (^connectionHandler)(NSDictionary *) = [^(NSDictionary *responseDict) {
        NSDictionary *paginationInfo = [responseDict objectForKey:@"competitions"];

        self.previousPageIncompleteCompetitionsUrl = [NSString stringWithFormat:@"%@", [paginationInfo objectForKey:@"previous"]];
        self.nextPageIncompleteCompetitionsUrl = [NSString stringWithFormat:@"%@", [paginationInfo objectForKey:@"next"]];
        handler(responseDict);
    } copy];
    
    
    NSString *competitionsUrl;
    if ( [page isEqualToString:@"next"] ) {
        competitionsUrl = self.nextPageIncompleteCompetitionsUrl;
    } else if ( [page isEqualToString:@"previous"]) {
        competitionsUrl = self.previousPageIncompleteCompetitionsUrl;
    } else {
        competitionsUrl = [NSString stringWithFormat:@"%@%@?game_name=%@&page_size=1&exclude=complete", APIRequestCompetitionURL, self.userId, [self slugify:@"iOS SDK Example App"]];
    }
    
    NSString *key = [NSString stringWithFormat:@"%@:GET", competitionsUrl];
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:competitionsUrl]];
    
    [_connectionHandlerRegistry setObject:connectionHandler forKey:key];
    [NSURLConnection connectionWithRequest:request delegate:self];

}

/**
    Displays the current incomplete competition in an alertView with buttons to finish the competition
 */
- (void)viewIncompleteCompetitions:(void(^)(NSString *))handler page:(NSString *)page
{
    void (^connectionHandler)(NSDictionary *) = [^(NSDictionary (*responseDict)) {
        NSDictionary *competitionSerializer = [responseDict objectForKey:@"competitions"];
        NSArray *competitions = [competitionSerializer objectForKey:@"results"];
        NSMutableString *message = [NSMutableString string];
        NSMutableString *yourScore = [NSMutableString string];
        
        if ( [competitions count] > 0 ) {
            for (int i = 0; i < [competitions count]; i++) {
                self.currentIncompleteCompetitionId = [[competitions objectAtIndex:i] objectForKey:@"id"];
                NSString *createdOn = [[competitions objectAtIndex:i] objectForKey:@"created_on"];
                NSTimeInterval seconds = [createdOn doubleValue] / 1000;
                NSDate *unFormattedDate = [NSDate dateWithTimeIntervalSince1970:seconds];
                NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
                [dateFormatter setDateFormat:@"EEE, MMM d"];
                NSString *competitionString = [NSString stringWithFormat:@"%@ \nBet Size: %@BTC \nYour Score: %@ \nOpponent Score: %@\n\n",
                                               [dateFormatter stringFromDate:unFormattedDate],
                                               [[[competitions objectAtIndex:i] objectForKey:@"jackpot"] objectForKey:@"buy_in"],
                                               [self getPlayerScoreFromCompetition:[competitions objectAtIndex:i]],
                                               [self getOpponentScoreFromCompetition:[competitions objectAtIndex:i]]];
                [message appendString:competitionString];
                [yourScore appendString:[self getPlayerScoreFromCompetition:[competitions objectAtIndex:i]]];
            }
        } else {
            [message appendString:@"No incomplete games"];
        }
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Incomplete Games" message:message delegate:self cancelButtonTitle:@"Close" otherButtonTitles:nil];
        
        if ( [yourScore isEqualToString:@"n/a"]) {
            [alert addButtonWithTitle:@"Play"];
        }
        
        if ( [competitionSerializer objectForKey:@"previous"] != (id)[NSNull null] ) {
            [alert addButtonWithTitle:@"Prev"];
        }
        if ( [competitionSerializer objectForKey:@"next"] != (id)[NSNull null] ) {
            [alert addButtonWithTitle:@"Next"];
        }
        
        [_alertViewHandlerRegistry setObject:handler forKey:@"closeIncompleteGamesHandler"];
        [alert setTag:11];
        [alert show];
    } copy];
    
    [self getIncompleteCompetitions:connectionHandler page:page];
}

- (void)reportScore:(void(^)(NSDictionary *))handler competitionId:(NSString*)competitionId score:(NSString*)score
{
    NSDictionary *paramsDict = @{
        @"score": score
    };

    void (^connectionHandler)(NSDictionary *) = [^(NSDictionary *responseDict) {
        handler(responseDict);
    } copy];

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
    } else {
        NSString *requestUrl = [APIReportScoreURLPart1 stringByAppendingString: [competitionId stringByAppendingString: [APIReportScoreURLPart2 stringByAppendingString:self.userId]]];
        NSLog(@"TTT CALLING REPORT SCORE. url=%@", requestUrl);
        NSLog(APIReportScoreURLPart1);
        NSLog(competitionId);
        NSLog(APIReportScoreURLPart2);
        NSLog(self.userId);
        NSString *key = [NSString stringWithFormat:@"%@:POST", requestUrl];
        [_connectionHandlerRegistry setObject:connectionHandler forKey:key];

        NSString *paramsStr = [[NSString alloc] initWithData:paramsData encoding:NSUTF8StringEncoding];
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:requestUrl]
                                                               cachePolicy:NSURLRequestUseProtocolCachePolicy
                                                           timeoutInterval:60.0];
        [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
        [request setHTTPMethod:@"POST"];
        [request setHTTPBody:[paramsStr dataUsingEncoding:NSUTF8StringEncoding]];

        [NSURLConnection connectionWithRequest:request delegate:self];
    }
}


#pragma mark NSURLConnection Delegate Methods

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    NSLog(@"aa: connection didReceiveResponse");
    NSString *key = [NSString stringWithFormat:@"%@:%@", [[connection currentRequest] URL], [[connection currentRequest] HTTPMethod]];
    [_responseDataRegistry setObject:[[NSMutableData alloc] init] forKey:key];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    NSLog(@"aa: connection didReceiveData");
    NSString *key = [NSString stringWithFormat:@"%@:%@", [[connection currentRequest] URL], [[connection currentRequest] HTTPMethod]];
    [[_responseDataRegistry objectForKey:key] appendData:data];
}

- (NSCachedURLResponse *)connection:(NSURLConnection *)connection
                  willCacheResponse:(NSCachedURLResponse*)cachedResponse {
    NSLog(@"aa: connection cachedResponse");
    return nil;
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    NSLog(@"aa: connectionDidFinishLoading: %@", [[connection currentRequest] URL]);
    NSString *key = [NSString stringWithFormat:@"%@:%@", [[connection currentRequest] URL], [[connection currentRequest] HTTPMethod]];
    NSError *error = nil;
    NSData *responseData = [_responseDataRegistry objectForKey:key];
    NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:responseData options:NSJSONReadingMutableLeaves error:&error];

    if( error ) {
        NSLog( @"Error: %@", error );
        dict = @{@"success": @"false", @"errors":@[@"Received null response from connection."]};
    } else {
        NSLog( @"%@", dict );
    }

    void (^handler)(id) = [_connectionHandlerRegistry objectForKey:key];
    handler(dict);
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    NSLog(@"aa: connection didFailWithError");
    NSLog(@"%@", error);
    NSDictionary *dict = [[NSDictionary alloc] initWithObjectsAndKeys:@[[error localizedDescription]], @"errors", @"false", @"success", nil];
    NSString *key = [NSString stringWithFormat:@"%@:%@", [[connection currentRequest] URL], [[connection currentRequest] HTTPMethod]];

    void (^handler)(id) = [_connectionHandlerRegistry objectForKey:key];
    handler(dict);
}

#pragma mark UIAlertView Delegate Methods

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {

    NSString *buttonTitle = [alertView buttonTitleAtIndex:buttonIndex];

    // Wallet alertView
    if ( alertView.tag == 1 ) {
        if ( [buttonTitle isEqualToString:@"Refresh"] ) {
            void (^connectionHandler)(NSDictionary *) = [^(NSDictionary *responseDict) {
                [self showWalletPanel:[_alertViewHandlerRegistry objectForKey:@"closeWalletHandler"]];
            } copy];

            [self getWallet:connectionHandler];
        } else if ( [buttonTitle isEqualToString:@"Deposit"] ) {
            [self showDepositPanel];
        } else if ( [buttonTitle isEqualToString:@"Withdraw"] ) {
            [self showWithdrawPanel];
        } else {
            void (^handler)(void) = [_alertViewHandlerRegistry objectForKey:@"closeWalletHandler"];
            handler();
        }

    // Verification alertView
    } else if ( alertView.tag == 2 ) {
        void (^connectionHandler)(NSDictionary *) = [^(NSDictionary *responseDict) {
            if ([[responseDict objectForKey:@"success"] boolValue] == true) {
                self.wallet = [responseDict objectForKey:@"wallet"];
            }
            _completionHandler(responseDict);
            _completionHandler = nil;
        } copy];

        if (buttonIndex == 0) {
            NSDictionary *dict = @{@"success": @"false", @"errors":@[@"User has canceled verification."]};
            connectionHandler(dict);
        } else if (buttonIndex == 1) {
            NSDictionary *postDict = [[NSDictionary alloc] initWithObjectsAndKeys:@"true", @"agreed_to_terms", @"true", @"confirmed_age", nil];
            NSError *error;
            NSData *postData = [NSJSONSerialization dataWithJSONObject:postDict options:NSJSONWritingPrettyPrinted error:&error];

            NSMutableString *verificationUrl = [NSMutableString stringWithString: APIUserDetailsURL];
            [verificationUrl appendString: self.userId];
            [verificationUrl appendString: @"/verify"];

            NSString *key = [NSString stringWithFormat:@"%@:POST", verificationUrl];

            [_connectionHandlerRegistry setObject:connectionHandler forKey:key];

            NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:verificationUrl]];
            [request setHTTPMethod:@"POST"];
            [request setValue:@"application/json; charset=UTF-8" forHTTPHeaderField:@"Content-Type"];
            [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
            [request setHTTPBody:postData];
            [NSURLConnection connectionWithRequest:request delegate:self];
        }

    } else if ( alertView.tag == 4 ) {
        if ( [buttonTitle isEqualToString:@"Copy Address"] ) {
            [self copyDepositAddressToClipboard];
        } else if ( [buttonTitle isEqualToString:@"Back"] ) {
            [self showWalletPanel:[_alertViewHandlerRegistry objectForKey:@"closeWalletHandler"]];
        }

    // Withdraw
    } else if ( alertView.tag == 5 ) {
        if ( [buttonTitle isEqualToString:@"Withdraw"]) {

            void (^connectionHandler)(NSDictionary *) = [^(NSDictionary *responseDict) {
                BOOL success = [[responseDict objectForKey:@"success"] boolValue];
                if ( success ) {
                    self.wallet = [responseDict objectForKey:@"wallet"];
                    [self showWalletPanel:[_alertViewHandlerRegistry objectForKey:@"closeWalletHandler"]];

                } else {
                    NSMutableString *error = [NSMutableString string];
                    for (NSString *element in [responseDict objectForKey:@"errors"]) {
                        [error appendString:[NSString stringWithFormat:@"%@. ", element]];
                    }
                    [self showWithdrawError:error];
                }
            } copy];

            UITextField *address = [alertView textFieldAtIndex:0];
            NSString *walletUrl = [NSString stringWithFormat:@"%@%@", APIWalletURL, self.userId];
            NSDictionary *postDict = [[NSDictionary alloc] initWithObjectsAndKeys:address.text, @"address", [self.wallet objectForKey:@"balance"], @"amount", nil];
            NSError *error;
            NSData *postData = [NSJSONSerialization dataWithJSONObject:postDict options:NSJSONWritingPrettyPrinted error:&error];
            NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:walletUrl]];

            [request setHTTPMethod:@"POST"];
            [request setValue:@"application/json; charset=UTF-8" forHTTPHeaderField:@"Content-Type"];
            [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
            [request setHTTPBody:postData];
            [_connectionHandlerRegistry setObject:connectionHandler forKey:[NSString stringWithFormat:@"%@:POST", walletUrl]];
            [NSURLConnection connectionWithRequest:request delegate:self];

        } else if ( [buttonTitle isEqualToString:@"Back"] ) {
            [self showWalletPanel:[_alertViewHandlerRegistry objectForKey:@"closeWalletHandler"]];
        }

    // Previous competitions
    } else if ( alertView.tag == 10 ) {
        void (^handler)(void) = [_alertViewHandlerRegistry objectForKey:@"closePreviousGamesHandler"];

        if ( [buttonTitle isEqualToString:@"Next"] ) {
            [self viewPreviousCompetitions:handler page:@"next"];
        } else if ( [buttonTitle isEqualToString:@"Prev"] ) {
            [self viewPreviousCompetitions:handler page:@"previous"];
        } else {
            handler();
        }
        
    // Incomplete competitions
    } else if ( alertView.tag == 11 ) {
        void (^handler)(NSString *) = [_alertViewHandlerRegistry objectForKey:@"closeIncompleteGamesHandler"];
        if ( [buttonTitle isEqualToString:@"Next"] ) {
            [self viewIncompleteCompetitions:handler page:@"next"];
        } else if ( [buttonTitle isEqualToString:@"Prev"] ) {
            [self viewIncompleteCompetitions:handler page:@"previous"];
        } else if ( [buttonTitle isEqualToString:@"Play"] ) {
            handler(self.currentIncompleteCompetitionId);
        }else {
            handler(@"");
        }

    // Default to the main wallet screen
    } else {
        [self showWalletPanel:[_alertViewHandlerRegistry objectForKey:@"closeWalletHandler"]];
    }

}

# pragma mark Utility Helpers

- (NSString *)getPlayerScoreFromCompetition: (NSDictionary *)competition
{
    for ( NSDictionary *player in [competition objectForKey:@"players"] ) {
        NSDictionary *playerUser = [player objectForKey:@"user"];
        if ( [[playerUser objectForKey:@"id"] isEqualToString:self.userId] ) {
            if ( [player objectForKey:@"score"] == (id)[NSNull null] ) {
                return @"n/a";
            } else {
                return [player objectForKey:@"score"];
            }
        }
    }
}

- (NSString *)getOpponentScoreFromCompetition: (NSDictionary *)competition
{
    for ( NSDictionary *player in [competition objectForKey:@"players"] ) {
        NSDictionary *playerUser = [player objectForKey:@"user"];
        if ( ![[playerUser objectForKey:@"id"] isEqualToString:self.userId] ) {
            if ( [player objectForKey:@"score"] == (id)[NSNull null] ) {
                return @"n/a";
            } else {
                return [player objectForKey:@"score"];
            }
        }
        return @"n/a";
    }}

/*
 Makes slugifies strings into safe urls.
 Modified from https://gist.github.com/AzizLight/5926772
 */
- (NSString *)slugify:(NSString *)originalString
{
    NSString *separator = @"-";
    NSMutableString *slugalizedString = [NSMutableString string];
    NSRange replaceRange = NSMakeRange(0, originalString.length);

    // Remove all non ASCII characters
    NSError *nonASCIICharsRegexError = nil;
    NSRegularExpression *nonASCIICharsRegex = [NSRegularExpression regularExpressionWithPattern:@"[^\\x00-\\x7F]+"
                                                                                        options:nil
                                                                                          error:&nonASCIICharsRegexError];

    slugalizedString = [[nonASCIICharsRegex stringByReplacingMatchesInString:originalString
                                                                     options:0
                                                                       range:replaceRange
                                                                withTemplate:@""] mutableCopy];

    // Turn non-slug characters into separators
    NSError *nonSlugCharactersError = nil;
    NSRegularExpression *nonSlugCharactersRegex = [NSRegularExpression regularExpressionWithPattern:@"[^a-z0-9\\-_\\+]+"
                                                                                            options:NSRegularExpressionCaseInsensitive
                                                                                              error:&nonSlugCharactersError];
    slugalizedString = [[nonSlugCharactersRegex stringByReplacingMatchesInString:slugalizedString
                                                                         options:0
                                                                           range:replaceRange
                                                                    withTemplate:separator] mutableCopy];

    // Remove leading/trailing separator
    slugalizedString = [[slugalizedString stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"-"]] mutableCopy];

    return slugalizedString;
}

@end
