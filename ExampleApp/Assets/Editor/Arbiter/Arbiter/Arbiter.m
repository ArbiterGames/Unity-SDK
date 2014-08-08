//
//  Arbiter.m
//  Arbiter
//
//  Copyright (c) 2014 Arbiter. All rights reserved.
//


#import <GameKit/GameKit.h>
#import <CoreLocation/CoreLocation.h>
#import "ArbiterConstants.h"
#import "Arbiter.h"
#import "ArbiterPaymentView.h"
#import "ArbiterWithdrawView.h"
#import "ArbiterAlertWindow.h"
#import "STPView.h"


#define PAYMENT_VIEW_TAG 666
#define WITHDRAW_VIEW_TAG 766
#define LOGIN_ALERT_TAG 329
#define INVALID_LOGIN_ALERT_TAG 330
#define WALLET_ALERT_TAG 331
#define VERIFICATION_ALERT_TAG 332
#define ENABLE_LOCATION_ALERT_TAG 333
#define PREVIOUS_TOURNAMENTS_ALERT_TAG 336
#define VIEW_INCOMPLETE_TOURNAMENTS_ALERT_TAG 337
#define TOURNAMENT_DETAILS_ALERT_TAG 338

#define SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(v)  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedAscending)


@implementation Arbiter


#pragma mark User Methods

- (id)init:(void(^)(NSDictionary *))handler apiKey:(NSString*)apiKey accessToken:(NSString*)accessToken
{
    self = [super init];
    
    if ( self ) {
        self.apiKey = apiKey;
        self.accessToken = accessToken;
        self.alertWindow = [[ArbiterAlertWindow alloc] initWithGameWindow:[[UIApplication sharedApplication] keyWindow]];
        
        _alertViewHandlerRegistry = [[NSMutableDictionary alloc] init];
        _responseDataRegistry = [[NSMutableDictionary alloc] init];
        _connectionHandlerRegistry = [[NSMutableDictionary alloc] init];

        [self getGameSettings];
    }
    
    handler(@{@"success": @"true"});
    return self;
}

- (void)loginAsAnonymous:(void(^)(NSDictionary *))handler
{
    void (^connectionHandler)(NSDictionary *) = [^(NSDictionary *responseDict) {
        self.wallet = [NSMutableDictionary dictionaryWithDictionary:[responseDict objectForKey:@"wallet"]];
        self.user = [NSMutableDictionary dictionaryWithDictionary:[responseDict objectForKey:@"user"]];
        handler(responseDict);
    } copy];
    
    [self httpGet:APIUserInitializeURL handler:connectionHandler];
}

- (void)loginWithGameCenterPlayer:(void(^)(NSDictionary *))handler
{
    void (^connectionHandler)(NSDictionary *) = [^(NSDictionary *responseDict) {
        self.wallet = [NSMutableDictionary dictionaryWithDictionary:[responseDict objectForKey:@"wallet"]];
        self.user = [NSMutableDictionary dictionaryWithDictionary:[responseDict objectForKey:@"user"]];
        handler(responseDict);
    } copy];

    NSDictionary *response;

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
                    @"game_center_username": localPlayer.alias,
                    @"bundleID":[[NSBundle mainBundle] bundleIdentifier]
                };

                [self httpPost:APILinkWithGameCenterURL params:paramsDict handler:connectionHandler];
            }
        }];
    }
}

- (void)login:(void(^)(NSDictionary *))handler
{
    UIAlertView *loginAlert = [[UIAlertView alloc] initWithTitle: @"Login to Arbiter"
                                            message: nil
                                           delegate: self
                                  cancelButtonTitle:@"Cancel"
                                  otherButtonTitles:@"Login", nil];
    [loginAlert setAlertViewStyle:UIAlertViewStyleLoginAndPasswordInput];
    [loginAlert setTag:LOGIN_ALERT_TAG];
    [loginAlert show];
    
    UIAlertView *invalidLoginAlert = [[UIAlertView alloc] initWithTitle:@"Unable to login"
                                                   message:@"The email or password was incorrect."
                                                  delegate:self
                                         cancelButtonTitle:@"OK"
                                         otherButtonTitles:nil];
    [invalidLoginAlert setTag:INVALID_LOGIN_ALERT_TAG];
    
    
    void (^connectionHandler)(NSDictionary *) = [^(NSDictionary *responseDict) {
        if ( [[responseDict objectForKey:@"success"] boolValue] == true ) {
            self.wallet = [NSMutableDictionary dictionaryWithDictionary:[responseDict objectForKey:@"wallet"]];
            self.user = [NSMutableDictionary dictionaryWithDictionary:[responseDict objectForKey:@"user"]];
            handler(responseDict);
        } else {
            [invalidLoginAlert show];
        }
    } copy];
    
    void (^loginAlertHandler)(NSDictionary *) = [^(NSDictionary *loginCredentials) {
        if ( [loginCredentials objectForKey:@"errors"] ) {
            handler(@{@"success": @"false", @"errors":[loginCredentials objectForKey:@"errors"]});
        } else {
            [self httpPost:APIUserLoginURL params:loginCredentials handler:connectionHandler];
        }
    } copy];
    
    void (^invalidLoginAlertHandler)(NSDictionary *) = [^(NSDictionary *emptyDict) {
        [loginAlert show];
    } copy];
    
    [_alertViewHandlerRegistry setObject:loginAlertHandler forKey:@"loginHandler"];
    [_alertViewHandlerRegistry setObject:invalidLoginAlertHandler forKey:@"invalidLoginHandler"];
}

- (void)logout:(void(^)(NSDictionary *))handler
{
    void (^connectionHandler)(NSDictionary *) = [^(NSDictionary *responseDict) {
        self.user = nil;
        self.wallet = nil;
        handler(responseDict);
    } copy];

    [self httpPost:APIUserLogoutURL params:nil handler:connectionHandler];
}

- (void)verifyUser:(void(^)(NSDictionary *))handler
{
    void (^locationCallback)(NSDictionary *) = ^(NSDictionary *geoCodeResponse) {
        if ( [[geoCodeResponse objectForKey:@"success"] boolValue] == true ) {
            NSString *postalCode = [geoCodeResponse objectForKey:@"postalCode"];
            [self.user setObject:postalCode forKey:@"postal_code"];
            
            if ( [[self.user objectForKey:@"agreed_to_terms"] boolValue] == true && [[self.user objectForKey:@"location_approved"] boolValue] == true ) {
                handler(@{@"user": self.user,
                          @"success": @"true"});
            } else if ( [[self.user objectForKey:@"agreed_to_terms"] boolValue] == false && [[self.user objectForKey:@"location_approved"] boolValue] == false ) {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle: @"Terms and Conditions"
                                                                message: @"By clicking confirm below, you are confirming that you are at least 18 years old and agree to the terms and conditions at https://www.arbiter.me/terms"
                                                               delegate: self
                                                      cancelButtonTitle:@"Cancel"
                                                      otherButtonTitles:@"Agree", nil];
                [_alertViewHandlerRegistry setObject:handler forKey:@"agreedToTermsHandler"];
                [alert setTag:VERIFICATION_ALERT_TAG];
                [alert show];
            } else if ( [[self.user objectForKey:@"agreed_to_terms"] boolValue] == true && [[self.user objectForKey:@"location_approved"] boolValue] == false ) {
                NSDictionary *postParams = @{@"postal_code": [self.user objectForKey:@"postal_code"]};
                NSMutableString *verificationUrl = [NSMutableString stringWithString: APIUserDetailsURL];
                [verificationUrl appendString: [self.user objectForKey:@"id"]];
                [verificationUrl appendString: @"/verify"];
                [self httpPost:verificationUrl params:postParams handler:handler];
            }
        } else {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle: @"Enable Location Services"
                                                            message: @"Before continuing, please enable location services in your phone\'s settings. This is required so we can make sure betting in games is legal in your location.\n\n-Thanks."
                                                           delegate: self
                                                  cancelButtonTitle:@"Close"
                                                  otherButtonTitles:@"Try again", nil];
            [_alertViewHandlerRegistry setObject:handler forKey:@"enableLocationServices"];
            [alert setTag:ENABLE_LOCATION_ALERT_TAG];
            [alert show];
        }
    };
    
    if ([self.user objectForKey:@"postal_code"] == (id)[NSNull null] ) {
        [self getDevicePostalCode:locationCallback];
    } else {
        locationCallback(@{@"success": @"true",
                           @"postalCode": [self.user objectForKey:@"postal_code"]});
    }
}

- (void)getDevicePostalCode:(void(^)(NSDictionary *))handler
{
    if (nil == locationManager)
        locationManager = [[CLLocationManager alloc] init];
    
    locationManager.delegate = self;
    locationManager.desiredAccuracy = kCLLocationAccuracyKilometer;
    locationManager.distanceFilter = 500;
    [locationManager startUpdatingLocation];
    [self->locationManager startUpdatingLocation];
    
    CLLocation *location = [locationManager location];
    CLGeocoder *geocoder = [[CLGeocoder alloc] init];
    
    [geocoder reverseGeocodeLocation:location completionHandler:^(NSArray *placemarks, NSError *error) {
        NSMutableDictionary *response = [[NSMutableDictionary alloc] initWithDictionary:@{@"success": @false}];
        
        if ( error ) {
            handler(response);
        } else {
            CLPlacemark *placemark = [placemarks objectAtIndex:0];
            [response setValue:@"true" forKey:@"success"];
            [response setValue:placemark.postalCode forKey:@"postalCode"];
            handler(response);
        }
    }];
}


#pragma mark Wallet Methods

- (void)getWallet:(void(^)(NSDictionary *))handler
{
    void (^connectionHandler)(NSDictionary *) = [^(NSDictionary *responseDict) {
        self.wallet = [NSMutableDictionary dictionaryWithDictionary:[responseDict objectForKey:@"wallet"]];
        handler(responseDict);
    } copy];
    
    if ( self.user ) {
        NSString *walletUrl = [APIWalletURL stringByAppendingString:[self.user objectForKey:@"id"]];
        [self httpGet:walletUrl handler:connectionHandler];
    } else {
        handler(@{@"success": @"false",
                  @"errors": @[@"No user is currently logged in. Use the Login, LoginAsAnonymous, or LoginWithGameCenterPlayer, to get an Arbiter User."]
                 });
    }
}

- (void)showWalletPanel:(void(^)(void))handler
{
    [self getWallet:^(NSDictionary *responseDict) {

        void (^closeWalletHandler)(void) = [^(void) {
            handler();
        } copy];
        
        void (^populateThenShowAlert)(void) = [^(void) {
            NSString *title = [NSString stringWithFormat: @"Balance: %@ credits", [self.wallet objectForKey:@"balance"]];
            NSString *message = [NSString stringWithFormat: @"Pending: %@ credits\nLogged in as: %@", [self.wallet objectForKey:@"pending_balance"], [self.user objectForKey:@"username"]];
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title message:message delegate:self cancelButtonTitle:@"Close" otherButtonTitles:@"Refresh", @"Deposit", @"Withdraw", nil];
            [alert setTag:WALLET_ALERT_TAG];
            [_alertViewHandlerRegistry setObject:closeWalletHandler forKey:@"closeWalletHandler"];
            [alert show];
        } copy];
        
        if ( [[self.user objectForKey:@"agreed_to_terms"] boolValue] == false ) {
            [self verifyUser:^(NSDictionary *dict) {
                populateThenShowAlert();
            }];
        } else {
            populateThenShowAlert();
        }
    }];
}

- (void)showDepositPanel
{
    ArbiterPaymentView *paymentView;
    void (^paymentCallback)(void) = [^(void) {
        [self.alertWindow hide];
    } copy];
    
    paymentView = [[ArbiterPaymentView alloc] initWithCallback:paymentCallback
                                            arbiterInstance:self];
    [paymentView setTag:PAYMENT_VIEW_TAG];
    [self.alertWindow show:paymentView];
}

- (void)showWithdrawPanel
{
    ArbiterWithdrawView *withdrawView;
    void (^withdrawCallback)(void) = [^(void) {
        UIView *withdrawView = [[self getTopApplicationWindow] viewWithTag:WITHDRAW_VIEW_TAG];
        [withdrawView removeFromSuperview];
    } copy];
    
    withdrawView = [[ArbiterWithdrawView alloc] initWithCallback:withdrawCallback
                                                      arbiterInstance:self];
    [withdrawView setTag:WITHDRAW_VIEW_TAG];
    [[self getTopApplicationWindow].rootViewController.view addSubview:withdrawView];
    }

- (void)showWithdrawError:(NSString *)error
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Unsuccessful Withdraw" message:error delegate:self cancelButtonTitle:@"Back" otherButtonTitles:nil];
    [alert show];
}

#pragma mark Tournament Methods

/**
    Requests a new Tournament for this user from Arbiter
 */
- (void)requestTournament:(void(^)(NSDictionary *))handler buyIn:(NSString*)buyIn filters:(NSString*)filters
{
    NSDictionary *paramsDict = @{@"buy_in":buyIn, @"filters":filters};
    
    void (^connectionHandler)(NSDictionary *) = [^(NSDictionary *responseDict) {
        handler(responseDict);
    } copy];
    
    if ( [[self.user objectForKey:@"agreed_to_terms"] boolValue] == false ) {
        [self verifyUser:^(NSDictionary *dict) {
            if ( [[dict objectForKey:@"success"] boolValue] == true ) {
                [self httpPost:APITournamentCreateURL params:paramsDict handler:connectionHandler];
            }
        }];
    } else {
        [self httpPost:APITournamentCreateURL params:paramsDict handler:connectionHandler];
    }
}

- (void)getTournament:(void(^)(NSDictionary*))handler tournamentId:(NSString *)tournamentId
{
    void (^connectionHandler)(NSDictionary *) = [^(NSDictionary *responseDict) {
        NSLog(@"++ Arbiter.me getTournament.responseDict: %@", responseDict);
        NSDictionary *tournament = [responseDict objectForKey:@"tournament"];
        handler(tournament);
    } copy];
    
    [self httpGet:[NSString stringWithFormat:@"%@%@", APITournamentBaseURL, tournamentId] handler:connectionHandler];
}

/**
    Makes the request to Arbiter to a paginated set of tournaments for this user
 */
- (void)getTournaments:(void(^)(NSDictionary*))handler page:(NSString *)page
{
    void (^connectionHandler)(NSDictionary *) = [^(NSDictionary *responseDict) {
        NSDictionary *paginationInfo = [responseDict objectForKey:@"tournaments"];
        self.previousPageTournamentsUrl = [NSString stringWithFormat:@"%@", [paginationInfo objectForKey:@"previous"]];
        self.nextPageTournamentsUrl = [NSString stringWithFormat:@"%@", [paginationInfo objectForKey:@"next"]];
        handler(responseDict);
    } copy];

    NSString *tournamentsUrl;
    if ( [page isEqualToString:@"next"] ) {
        tournamentsUrl = self.nextPageTournamentsUrl;
    } else if ( [page isEqualToString:@"previous"]) {
        tournamentsUrl = self.previousPageTournamentsUrl;
    } else {
        tournamentsUrl = APIRequestTournamentURL;
    }

    [self httpGet:tournamentsUrl handler:connectionHandler];
}


/**
    Calls getTournaments, then parses the results and displays the tournaments in an alertView
 */
- (void)viewPreviousTournaments:(void(^)(void))handler page:(NSString *)page
{
    void (^connectionHandler)(NSDictionary *) = [^(NSDictionary (*responseDict)) {
        NSDictionary *tournamentSerializer = [responseDict objectForKey:@"tournaments"];
        NSArray *tournaments = [tournamentSerializer objectForKey:@"results"];
        NSMutableString *message = [NSMutableString string];
        
        if ( [tournaments count] > 0 ) {
            for (int i = 0; i < [tournaments count]; i++) {
                NSString *createdOn = [[tournaments objectAtIndex:i] objectForKey:@"created_on"];
                NSTimeInterval seconds = [createdOn doubleValue] / 1000;
                NSDate *unFormattedDate = [NSDate dateWithTimeIntervalSince1970:seconds];
                NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
                [dateFormatter setDateFormat:@"EEE, MMM d"];
                NSString *tournamentString = [NSString stringWithFormat:@"%@ \nBet Size: %@ credits \nYour Score: %@ \nOpponent Score: %@\n\n",
                    [dateFormatter stringFromDate:unFormattedDate],
                    [[tournaments objectAtIndex:i] objectForKey:@"buy_in"],
                    [self getPlayerScoreFromTournament:[tournaments objectAtIndex:i]],
                    [self getOpponentScoreFromTournament:[tournaments objectAtIndex:i]]];
                [message appendString:tournamentString];
            }
        } else {
            [message appendString:@"No previous games"];
        }

        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Previous Games" message:message delegate:self cancelButtonTitle:@"Close" otherButtonTitles:nil];

        if ( [tournamentSerializer objectForKey:@"previous"] != (id)[NSNull null] ) {
            [alert addButtonWithTitle:@"Prev"];
        }
        if ( [tournamentSerializer objectForKey:@"next"] != (id)[NSNull null] ) {
            [alert addButtonWithTitle:@"Next"];
        }

        [_alertViewHandlerRegistry setObject:handler forKey:@"closePreviousGamesHandler"];
        [alert setTag:PREVIOUS_TOURNAMENTS_ALERT_TAG];
        [alert show];
    } copy];

    [self getTournaments:connectionHandler page:page];
}


/**
    Gets the latest incomplete tournaments from Arbiter. Paginated by 1 comp per page
 */
- (void)getIncompleteTournaments:(void(^)(NSDictionary*))handler page:(NSString *)page
{
    void (^connectionHandler)(NSDictionary *) = [^(NSDictionary *responseDict) {
        NSDictionary *paginationInfo = [responseDict objectForKey:@"tournaments"];
        self.previousPageIncompleteTournamentsUrl = [NSString stringWithFormat:@"%@", [paginationInfo objectForKey:@"previous"]];
        self.nextPageIncompleteTournamentsUrl = [NSString stringWithFormat:@"%@", [paginationInfo objectForKey:@"next"]];
        handler(responseDict);
    } copy];


    NSString *tournamentsUrl;
    if ( [page isEqualToString:@"next"] ) {
        tournamentsUrl = self.nextPageIncompleteTournamentsUrl;
    } else if ( [page isEqualToString:@"previous"]) {
        tournamentsUrl = self.previousPageIncompleteTournamentsUrl;
    } else {
        tournamentsUrl = APIRequestTournamentURL;
    }

    [self httpGet:tournamentsUrl handler:connectionHandler];
}

/**
    Displays the current incomplete tournament in an alertView with buttons to finish the tournament
 */
- (void)viewIncompleteTournaments:(void(^)(NSString *))handler page:(NSString *)page
{
    void (^connectionHandler)(NSDictionary *) = [^(NSDictionary (*responseDict)) {
        NSDictionary *tournamentSerializer = [responseDict objectForKey:@"tournaments"];
        NSArray *tournaments = [tournamentSerializer objectForKey:@"results"];
        NSMutableString *message = [NSMutableString string];
        NSMutableString *yourScore = [NSMutableString string];

        if ( [tournaments count] > 0 ) {
            for (int i = 0; i < [tournaments count]; i++) {
                self.currentIncompleteTournamentId = [[tournaments objectAtIndex:i] objectForKey:@"id"];
                NSString *createdOn = [[tournaments objectAtIndex:i] objectForKey:@"created_on"];
                NSTimeInterval seconds = [createdOn doubleValue] / 1000;
                NSDate *unFormattedDate = [NSDate dateWithTimeIntervalSince1970:seconds];
                NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
                [dateFormatter setDateFormat:@"EEE, MMM d"];
                NSString *tournamentString = [NSString stringWithFormat:@"%@ \nBet Size: %@ credits \nYour Score: %@ \nOpponent Score: %@\n\n",
                                               [dateFormatter stringFromDate:unFormattedDate],
                                               [[tournaments objectAtIndex:i] objectForKey:@"buy_in"],
                                               [self getPlayerScoreFromTournament:[tournaments objectAtIndex:i]],
                                               [self getOpponentScoreFromTournament:[tournaments objectAtIndex:i]]];
                [message appendString:tournamentString];
                [yourScore appendString:[self getPlayerScoreFromTournament:[tournaments objectAtIndex:i]]];
            }
        } else {
            [message appendString:@"No incomplete games"];
        }

        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Incomplete Games" message:message delegate:self cancelButtonTitle:@"Close" otherButtonTitles:nil];

        if ( [yourScore isEqualToString:@"..."]) {
            [alert addButtonWithTitle:@"Play"];
        }

        if ( [tournamentSerializer objectForKey:@"previous"] != (id)[NSNull null] ) {
            [alert addButtonWithTitle:@"Prev"];
        }
        if ( [tournamentSerializer objectForKey:@"next"] != (id)[NSNull null] ) {
            [alert addButtonWithTitle:@"Next"];
        }

        [_alertViewHandlerRegistry setObject:handler forKey:@"closeIncompleteGamesHandler"];
        [alert setTag:VIEW_INCOMPLETE_TOURNAMENTS_ALERT_TAG];
        [alert show];
    } copy];

    [self getIncompleteTournaments:connectionHandler page:page];
}

- (void)reportScore:(void(^)(NSDictionary *))handler tournamentId:(NSString*)tournamentId score:(NSString*)score
{
    NSDictionary *paramsDict = @{@"score": score};
    
    void (^connectionHandler)(NSDictionary *) = [^(NSDictionary *responseDict) {
        handler(responseDict);
    } copy];

    NSString *requestUrl = [APITournamentBaseURL stringByAppendingString: [tournamentId stringByAppendingString: [APIReportScoreURLPart2 stringByAppendingString:[self.user objectForKey:@"id"]]]];

    [self httpPost:requestUrl params:paramsDict handler:connectionHandler];
}

- (void)showTournamentDetailsPanel:(void(^)(void))handler tournamentId:(NSString *)tournamentId
{
    void (^getTournamentHandler)(NSDictionary *tournament) = [^(NSDictionary *tournament) {
        void (^closeTournamentDetailsHandler)(void) = [^(void) {
            handler();
        } copy];
    
        NSString *title;
        NSMutableString *message = [[NSMutableString alloc] init];
        NSString *status = [tournament objectForKey:@"status"];
        NSString *createdOn = [tournament objectForKey:@"created_on"];
        NSTimeInterval seconds = [createdOn doubleValue] / 1000;
        NSDate *unFormattedDate = [NSDate dateWithTimeIntervalSince1970:seconds];
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"EEE, MMM d"];
        
        if ( [status isEqualToString:@"initializing"] || [status isEqualToString:@"inprogress"] ) {
            title = @"Waiting for opponent";
            [message appendString:[NSString stringWithFormat:@"Your opponent has not finished their game. Check back later for results.\n\n Your score: %@\nBuy-in: %@\nPayout: %@",
                                   [self getPlayerScoreFromTournament:tournament],
                                   [tournament objectForKey:@"buy_in"],
                                   [tournament objectForKey:@"payout"]]];
        } else {
            if ( [[tournament objectForKey:@"winners"] containsObject:[self.user objectForKey:@"id"]] ) {
                title = [NSString stringWithFormat:@"You won %@ credits!", [tournament objectForKey:@"payout"]];
            } else {
                title = @"You have been defeated";
            }
            [message appendString:[NSString stringWithFormat:@"Your score: %@\nOpponent score: %@\nDate: %@\nBuy-in: %@\nPayout: %@",
                                   [self getPlayerScoreFromTournament:tournament],
                                   [self getOpponentScoreFromTournament:tournament],
                                   [dateFormatter stringFromDate:unFormattedDate],
                                   [tournament objectForKey:@"buy_in"],
                                   [tournament objectForKey:@"payout"]]];
        }
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title
                                                        message:message
                                                       delegate:self
                                              cancelButtonTitle:@"Close"
                                              otherButtonTitles:nil];

        [alert setTag:TOURNAMENT_DETAILS_ALERT_TAG];
        [alert show];
        [_alertViewHandlerRegistry setObject:closeTournamentDetailsHandler forKey:@"closeTournamentDetailsHandler"];
    } copy];
    
    [self getTournament:getTournamentHandler tournamentId:tournamentId];
}


#pragma mark NSURLConnection Delegate Methods

- (void)httpGet:(NSString*)url handler:(void(^)(NSDictionary*))handler
{
    NSLog( @"ArbiterSDK GET %@", url );
    
    NSMutableURLRequest *request = [NSMutableURLRequest
        requestWithURL:[NSURL URLWithString:url]
        cachePolicy:NSURLRequestUseProtocolCachePolicy
        timeoutInterval:60.0];
    
    NSString *tokenValue;
    if ( [self.user objectForKey:@"token"] != (id)[NSNull null] && [self.user objectForKey:@"token"] != nil  ) {
        tokenValue = [NSString stringWithFormat:@"Token %@::%@", [self.user objectForKey:@"token"], self.apiKey];
    } else {
        tokenValue = [NSString stringWithFormat:@"Token %@", self.accessToken];
    }
          
    [request setValue:tokenValue forHTTPHeaderField:@"Authorization"];
    NSString *key = [url stringByAppendingString:@":GET"];
    [_connectionHandlerRegistry setObject:handler forKey:key];
    [NSURLConnection connectionWithRequest:request delegate:self];
}

-(void)httpPost:(NSString*)url params:(NSDictionary*)params handler:(void(^)(NSDictionary*))handler
{
    NSLog( @"ArbiterSDK POST %@", url );
    NSError *error = nil;
    NSData *paramsData;
    NSString *paramsStr;
    NSString *tokenValue;
    
    if ( [self.user objectForKey:@"token"] != NULL ) {
        tokenValue = [NSString stringWithFormat:@"Token %@::%@", [self.user objectForKey:@"token"], self.apiKey];
    } else {
        tokenValue = [NSString stringWithFormat:@"Token %@::%@", self.accessToken, self.apiKey];
    }
    
    if( params == nil ) {
        params = @{};
    }
    paramsData = [NSJSONSerialization dataWithJSONObject:params
                                                 options:0
                                                   error:&error];
    paramsStr = [[NSString alloc] initWithData:paramsData encoding:NSUTF8StringEncoding];
    
    if( error != nil ) {
        NSLog(@"ERROR: %@", error);
        handler( @{
            @"success": @"false",
            @"errors": @[error]
        });
    } else {
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:url]
                                                               cachePolicy:NSURLRequestUseProtocolCachePolicy
                                                           timeoutInterval:60.0];
        [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
        [request setValue:tokenValue forHTTPHeaderField:@"Authorization"];
        [request setHTTPMethod:@"POST"];
        [request setHTTPBody:[paramsStr dataUsingEncoding:NSUTF8StringEncoding]];

        [_connectionHandlerRegistry setObject:handler forKey:[url stringByAppendingString:@":POST"]];
        [NSURLConnection connectionWithRequest:request delegate:self];
    }
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    NSString *key = [NSString stringWithFormat:@"%@:%@", [[connection currentRequest] URL], [[connection currentRequest] HTTPMethod]];
    [_responseDataRegistry setObject:[[NSMutableData alloc] init] forKey:key];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    NSString *key = [NSString stringWithFormat:@"%@:%@", [[connection currentRequest] URL], [[connection currentRequest] HTTPMethod]];
    [[_responseDataRegistry objectForKey:key] appendData:data];
}

- (NSCachedURLResponse *)connection:(NSURLConnection *)connection
                  willCacheResponse:(NSCachedURLResponse*)cachedResponse {
    return nil;
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    NSLog(@"Response from %@", [[connection currentRequest] URL]);
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
    NSLog(@"%@", error);
    NSDictionary *dict = [[NSDictionary alloc] initWithObjectsAndKeys:@[[error localizedDescription]], @"errors", @"false", @"success", nil];
    NSString *key = [NSString stringWithFormat:@"%@:%@", [[connection currentRequest] URL], [[connection currentRequest] HTTPMethod]];

    void (^handler)(id) = [_connectionHandlerRegistry objectForKey:key];
    handler(dict);
}

#pragma mark UIAlertView Delegate Methods

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {

    NSString *buttonTitle = [alertView buttonTitleAtIndex:buttonIndex];

    if ( alertView.tag == LOGIN_ALERT_TAG ) {
        void (^handler)(NSDictionary *) = [_alertViewHandlerRegistry objectForKey:@"loginHandler"];
        if ( buttonIndex == 0 ) {
            NSArray *errors  = [NSArray arrayWithObjects:@"User canceled the login.", nil];
            handler(@{@"errors": errors});
        } else if ( buttonIndex == 1 ) {
            handler(@{@"email": [alertView textFieldAtIndex:0].text, @"password": [alertView textFieldAtIndex:1].text});
        }
    } else if ( alertView.tag == INVALID_LOGIN_ALERT_TAG ) {
        void (^handler)(NSDictionary *) = [_alertViewHandlerRegistry objectForKey:@"invalidLoginHandler"];
        handler(@{});
    } else if ( alertView.tag == WALLET_ALERT_TAG ) {
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

    } else if ( alertView.tag == VERIFICATION_ALERT_TAG ) {
        void (^connectionHandler)(NSDictionary *) = [^(NSDictionary *responseDict) {
            if ([[responseDict objectForKey:@"success"] boolValue] == true) {
                self.wallet = [NSMutableDictionary dictionaryWithDictionary:[responseDict objectForKey:@"wallet"]];
                self.user = [NSMutableDictionary dictionaryWithDictionary:[responseDict objectForKey:@"user"]];
                void (^handler)(NSDictionary *) = [_alertViewHandlerRegistry objectForKey:@"agreedToTermsHandler"];
                handler(responseDict);
            }
        } copy];

        if (buttonIndex == 0) {
            NSDictionary *dict = @{@"success": @"false", @"errors":@[@"User has canceled verification."]};
            connectionHandler(dict);
        } else if (buttonIndex == 1) {
            NSDictionary *postParams = @{@"postal_code": [self.user objectForKey:@"postal_code"]};
            NSMutableString *verificationUrl = [NSMutableString stringWithString: APIUserDetailsURL];
            [verificationUrl appendString: [self.user objectForKey:@"id"]];
            [verificationUrl appendString: @"/verify"];
            [self httpPost:verificationUrl params:postParams handler:connectionHandler];
        }

    } else if ( alertView.tag == ENABLE_LOCATION_ALERT_TAG) {
        if (buttonIndex == 1) {
            void (^handler)(NSDictionary *) = [_alertViewHandlerRegistry objectForKey:@"enableLocationServices"];
            [self verifyUser:^(NSDictionary *dict) {
                handler(dict);
            }];
        }
    } else if ( alertView.tag == PREVIOUS_TOURNAMENTS_ALERT_TAG ) {
        void (^handler)(void) = [_alertViewHandlerRegistry objectForKey:@"closePreviousGamesHandler"];

        if ( [buttonTitle isEqualToString:@"Next"] ) {
            [self viewPreviousTournaments:handler page:@"next"];
        } else if ( [buttonTitle isEqualToString:@"Prev"] ) {
            [self viewPreviousTournaments:handler page:@"previous"];
        } else {
            handler();
        }

    } else if ( alertView.tag == VIEW_INCOMPLETE_TOURNAMENTS_ALERT_TAG ) {
        void (^handler)(NSString *) = [_alertViewHandlerRegistry objectForKey:@"closeIncompleteGamesHandler"];
        if ( [buttonTitle isEqualToString:@"Next"] ) {
            [self viewIncompleteTournaments:handler page:@"next"];
        } else if ( [buttonTitle isEqualToString:@"Prev"] ) {
            [self viewIncompleteTournaments:handler page:@"previous"];
        } else if ( [buttonTitle isEqualToString:@"Play"] ) {
            handler(self.currentIncompleteTournamentId);
        }else {
            handler(@"");
        }

    } else if ( alertView.tag == TOURNAMENT_DETAILS_ALERT_TAG ) {
        void (^handler)(void) = [_alertViewHandlerRegistry objectForKey:@"closeTournamentDetailsHandler"];
        handler();
        
    // Default to the main wallet screen
    } else {
        [self showWalletPanel:[_alertViewHandlerRegistry objectForKey:@"closeWalletHandler"]];
    }

}

# pragma mark CLLocation Delegate Methods

/**
 Handler once location coordinates are returned from a location request.
 Stops updating location after the first coordinates are returned on all device location requests.
 */
- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
    currentLocation = [locations objectAtIndex:0];
    [locationManager stopUpdatingLocation];
    [self->locationManager stopUpdatingLocation];
}

# pragma mark Utility Helpers

- (void)removeSubviewsFromSuperViewWithTag:(int)tag
{
    for (UIView *view in [[self getTopApplicationWindow].rootViewController.view subviews]) {
        if (view.tag == tag) {
            [view removeFromSuperview];
        }
    }
}

-(void)getGameSettings
{
    void (^connectionHandler)(NSDictionary *) = [^(NSDictionary *responseDict) {
        self.game = responseDict;
    } copy];
    NSString *gameSettingsUrl = [NSString stringWithFormat:@"%@%@", GameSettingsURL, self.apiKey];
    [self httpGet:gameSettingsUrl handler:connectionHandler];
}

- (NSString *)getPlayerScoreFromTournament: (NSDictionary *)tournament
{
    for ( NSDictionary *user in [tournament objectForKey:@"users"] ) {
        if ( [[user objectForKey:@"id"] isEqualToString:[self.user objectForKey:@"id"]] ) {
            if ( [user objectForKey:@"score"] != (id)[NSNull null] ) {
                return [user objectForKey:@"score"];
            }
        }
    }
    return @"...";
}

- (NSString *)getOpponentScoreFromTournament: (NSDictionary *)tournament
{
    for ( NSDictionary *user in [tournament objectForKey:@"users"] ) {
        if ( ![[user objectForKey:@"id"] isEqualToString:[self.user objectForKey:@"id"]] ) {
            if ( [user objectForKey:@"score"] != (id)[NSNull null] ) {
                return [user objectForKey:@"score"];
            }
        }
    }
    return @"...";
}

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

- (UIWindow*) getTopApplicationWindow
{
    UIApplication *clientApp = [UIApplication sharedApplication];
    NSArray *windows = [clientApp windows];
    UIWindow *topWindow = nil;
    
    if (windows && [windows count] > 0)
        topWindow = [[clientApp windows] objectAtIndex:0];
    
    return topWindow;
}

@end
