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
#import "ArbiterWalletDashboardView.h"
#import "ArbiterTournamentResultsView.h"
#import "ArbiterPreviousTournamentsView.h"
#import "ArbiterWalkThrough.h"
#import "ArbiterLogQueue.h"

#define LOGIN_ALERT_TAG 329
#define INVALID_LOGIN_ALERT_TAG 330
#define WALLET_ALERT_TAG 331
#define VERIFICATION_ALERT_TAG 332
#define ENABLE_LOCATION_ALERT_TAG 333
#define SHOW_INCOMPLETE_TOURNAMENTS_ALERT_TAG 337
#define TOURNAMENT_DETAILS_ALERT_TAG 338
#define NO_ACTION_ALERT_TAG 339


@implementation Arbiter
{
    NSMutableDictionary *_alertViewHandlerRegistry;
    NSMutableDictionary *_connectionHandlerRegistry;
    NSMutableDictionary *_responseDataRegistry;
    CLLocationManager *locationManager;
    CLLocation *currentLocation;
}


#pragma mark User Methods

- (void)setUser:(NSMutableDictionary*)user
{
    self._user = user;
    ClientCallbackUserUpdated();
}

- (NSMutableDictionary *)user
{
    return self._user;
}

- (void)getCachedUser:(void(^)(NSDictionary *))handler
{
    handler(self.user);   
}

- (id)init:(void(^)(NSDictionary *))handler apiKey:(NSString*)apiKey accessToken:(NSString*)accessToken
{
    self = [super init];
    
    if ( self ) {
        self.apiKey = apiKey;
        self.accessToken = accessToken;
        self.locationVerificationAttempts = 0;
        self.panelWindow = [[ArbiterPanelWindow alloc] initWithGameWindow:[[UIApplication sharedApplication] keyWindow]];
        
        _alertViewHandlerRegistry = [[NSMutableDictionary alloc] init];
        _responseDataRegistry = [[NSMutableDictionary alloc] init];
        _connectionHandlerRegistry = [[NSMutableDictionary alloc] init];
        
        self.requestQueue = [[NSMutableDictionary alloc] init];
        self.spinnerView = [[UIActivityIndicatorView alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
        self.spinnerView.activityIndicatorViewStyle = UIActivityIndicatorViewStyleWhiteLarge;
        self.spinnerView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.5f];

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
    
    [self httpGet:APIUserInitializeURL isBlocking:NO handler:connectionHandler];
}

- (void)loginWithGameCenterPlayer:(void(^)(NSDictionary *))handler
{
    GKLocalPlayer *localPlayer = [GKLocalPlayer localPlayer];
    if( !localPlayer.isAuthenticated ) {
        handler(@{@"success": @"false",
                  @"errors": @[@"local player is not authenticated"]});
        return;
    }
    
    if ( [localPlayer respondsToSelector:@selector(generateIdentityVerificationSignatureWithCompletionHandler:)] ) {
        void (^connectionHandler)(NSDictionary *) = [^(NSDictionary *responseDict) {
            self.wallet = [NSMutableDictionary dictionaryWithDictionary:[responseDict objectForKey:@"wallet"]];
            self.user = [NSMutableDictionary dictionaryWithDictionary:[responseDict objectForKey:@"user"]];
            handler(responseDict);
        } copy];
        [localPlayer generateIdentityVerificationSignatureWithCompletionHandler:^(NSURL *publicKeyUrl, NSData *signature, NSData *salt, uint64_t timestamp, NSError *error) {
            if (error) {
                connectionHandler( @{@"success": @"false",
                                     @"errors": @[[error localizedDescription]]});
            } else {
                NSDictionary *paramsDict = @{@"publicKeyUrl":[publicKeyUrl absoluteString],
                                             @"timestamp":[NSString stringWithFormat:@"%llu", timestamp],
                                             @"signature":[signature base64EncodedStringWithOptions:0],
                                             @"salt":[salt base64EncodedStringWithOptions:0],
                                             @"playerID":localPlayer.playerID,
                                             @"game_center_username": localPlayer.alias,
                                             @"bundleID":[[NSBundle mainBundle] bundleIdentifier]};
                [self httpPost:APILinkWithGameCenterURL params:paramsDict isBlocking:NO handler:connectionHandler];
            }
        }];
    } else {
        handler(@{@"success": @"false",
                  @"errors": @[@"Linking a Game Center account requires iOS >= 7.0"]});
    };
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
            [self httpPost:APIUserLoginURL params:loginCredentials isBlocking:NO handler:connectionHandler];
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

    [self httpPost:APIUserLogoutURL params:nil isBlocking:NO handler:connectionHandler];
}

- (bool)isUserAuthenticated
{
    return self.user != nil && [self.user objectForKey:@"id"] != nil;
}

- (void)verifyUser:(void(^)(NSDictionary *))handler
{
    void (^locationCallback)(NSDictionary *) = ^(NSDictionary *geoCodeResponse) {
        if ( [[geoCodeResponse objectForKey:@"success"] boolValue] == true ) {
            NSString *postalCode = [geoCodeResponse objectForKey:@"postalCode"];
            [self.user setObject:postalCode forKey:@"postal_code"];
            
            if ([self isUserVerified]) {
                handler(@{@"user": self.user,
                          @"success": @"true"});
            } else if ( [[self.user objectForKey:@"agreed_to_terms"] boolValue] == false && [[self.user objectForKey:@"location_approved"] boolValue] == false ) {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle: @"Terms and Conditions"
                                                                message: @"By clicking Agree below, you are confirming that you are at least 18 years old and agree to the terms of service."
                                                               delegate: self
                                                      cancelButtonTitle:@"Agree"
                                                      otherButtonTitles:@"View terms", @"Cancel", nil];
                [_alertViewHandlerRegistry setObject:handler forKey:@"agreedToTermsHandler"];
                [alert setTag:VERIFICATION_ALERT_TAG];
                [alert show];
            } else if ( [[self.user objectForKey:@"agreed_to_terms"] boolValue] == true && [[self.user objectForKey:@"location_approved"] boolValue] == false ) {
                NSDictionary *postParams = @{@"postal_code": [self.user objectForKey:@"postal_code"]};
                NSMutableString *verificationUrl = [NSMutableString stringWithString: APIUserDetailsURL];
                [verificationUrl appendString: [self.user objectForKey:@"id"]];
                [verificationUrl appendString: @"/verify"];
                [self httpPost:verificationUrl params:postParams isBlocking:NO handler:handler];
            }
        } else {
            if ( self.user == nil ) {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Arbiter Error"
                                                                message:@"No user is currently logged in. Use one of the Arbiter Authentication methods (LoginAsAnonymous, LoginWithGameCenter, or Login) to initalize a user before calling VerifyUser."
                                                               delegate:self
                                                      cancelButtonTitle:@"Close"
                                                      otherButtonTitles:nil];
                [alert setTag:NO_ACTION_ALERT_TAG];
                [alert show];
            } else {
                if ( self.locationVerificationAttempts < 4 ) {
                    [NSThread sleepForTimeInterval:2 * self.locationVerificationAttempts];
                    self.locationVerificationAttempts++;
                    [self verifyUser:handler];
                } else {
                    if ( [_alertViewHandlerRegistry objectForKey:@"enableLocationServices"] == nil ) {
                        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Tournaments are Disabled"
                                                                        message:@"Make sure Location Services are enabled in your phone\'s settings to play in cash tournaments."
                                                                       delegate:self
                                                              cancelButtonTitle:@"Keep disabled"
                                                              otherButtonTitles:@"Check again", nil];
                        [_alertViewHandlerRegistry setObject:handler forKey:@"enableLocationServices"];
                        [alert setTag:ENABLE_LOCATION_ALERT_TAG];
                        [alert show];
                    }
                }
            }
        }
    };
    
    if ([self.user objectForKey:@"postal_code"] == (id)[NSNull null] ) {
        [self getDevicePostalCode:locationCallback];
    } else {
        if (self.user == nil) {
            NSLog(@"Arbiter Error: No user is currently logged in. Use one of the Authentication methods (LoginAsAnonymous, LoginWithGameCenter, or Login) to initalize a user before calling VerifyUser.");
            locationCallback(@{@"success": @"false"});
        } else {
            locationCallback(@{@"success": @"true",
                               @"postalCode": [self.user objectForKey:@"postal_code"]});
        }
    }
}

- (bool)isUserVerified
{
    if (self.user != nil && [[self.user objectForKey:@"agreed_to_terms"] boolValue] == true && [[self.user objectForKey:@"location_approved"] boolValue] == true ) {
        return true;
    } else {
        return false;
    }
}

- (void)getDevicePostalCode:(void(^)(NSDictionary *))handler
{
    if (nil == locationManager)
        locationManager = [[CLLocationManager alloc] init];
    
    
    locationManager.delegate = self;
    locationManager.desiredAccuracy = kCLLocationAccuracyKilometer;
    locationManager.distanceFilter = 500;
    
    if ( [locationManager respondsToSelector:@selector(requestWhenInUseAuthorization)] ) {
        [locationManager requestWhenInUseAuthorization];
    }
    
    [locationManager startUpdatingLocation];
    
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

- (void)setWallet:(NSMutableDictionary*)wallet
{
    self._wallet = wallet;
    if(self.walletObserver != nil) {
        [self.walletObserver onWalletUpdated:wallet];
    }
    ClientCallbackWalletUpdated();
}

- (NSMutableDictionary *)wallet
{
    return self._wallet;
}

- (void)getCachedWallet:(void(^)(NSDictionary *))handler
{
    handler(self.wallet);   
}

- (void)addWalletObserver:(id<ArbiterWalletObserver>)observer
{
    self.walletObserver = observer;
}

- (void)fetchWallet:(void(^)(NSDictionary *))handler isBlocking:(BOOL)isBlocking
{
    void (^connectionHandler)(NSDictionary *) = [^(NSDictionary *responseDict) {
        self.wallet = [NSMutableDictionary dictionaryWithDictionary:[responseDict objectForKey:@"wallet"]];
        handler(responseDict);
    } copy];
    
    if ( self.user ) {
        NSString *walletUrl = [APIWalletURL stringByAppendingString:[self.user objectForKey:@"id"]];
        [self httpGet:walletUrl isBlocking:isBlocking handler:connectionHandler];
    } else {
        handler(@{@"success": @"false",
                  @"errors": @[@"No user is currently logged in. Use the Login, LoginAsAnonymous, or LoginWithGameCenter, to get an Arbiter User."]
                 });
    }
}


- (void)showWalletPanel:(void(^)(void))handler
{
    if ( [self isUserAuthenticated] ) {
        void (^populateThenShowPanel)(void) = [^(void) {
            ArbiterWalletDashboardView *walletDashboard = [[ArbiterWalletDashboardView alloc] init:self];
            walletDashboard.callback = handler;
            [self addWalletObserver:walletDashboard];
            [self.panelWindow show:walletDashboard];
        } copy];
        if ( [[self.user objectForKey:@"agreed_to_terms"] boolValue] == false ) {
            void (^verifyCallback)(NSDictionary *) = [^(NSDictionary *dict) {
                populateThenShowPanel();
            } copy];
            [self verifyUser:verifyCallback];
        } else {
            populateThenShowPanel();
        }
    } else {
        NSLog(@"Arbiter Error: No user is currently logged in. Use one of the Authentication methods (LoginAsAnonymous, LoginWithGameCenter, or Login) to initalize a user before calling ShowWalletPanel.");
    }

}

- (void)sendPromoCredits:(void (^)(NSDictionary *))handler amount:(NSString *)amount
{
    [self httpPostAsDeveloper:APISendPromoCreditsURL
            params:@{@"amount": amount, @"to": [self.user objectForKey:@"id"]}
           handler:handler];
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
        void (^verifyCallback)(NSDictionary *) = [^(NSDictionary *dict) {
            if ( [[dict objectForKey:@"success"] boolValue] == true ) {
                [self httpPost:APITournamentCreateURL params:paramsDict isBlocking:NO handler:connectionHandler];
            }
        } copy];
        [self verifyUser:verifyCallback];
    } else {
        [self httpPost:APITournamentCreateURL params:paramsDict isBlocking:NO handler:connectionHandler];
    }
}

- (void)fetchTournament:(void(^)(NSDictionary*))handler tournamentId:(NSString *)tournamentId isBlocking:(BOOL)isBlocking
{
    void (^connectionHandler)(NSDictionary *) = [^(NSDictionary *responseDict) {
        NSDictionary *tournament = [responseDict objectForKey:@"tournament"];
        handler(tournament);
    } copy];
    
    [self httpGet:[NSString stringWithFormat:@"%@%@", APITournamentBaseURL, tournamentId] isBlocking:isBlocking handler:connectionHandler];
}

/**
    Makes the request to Arbiter to a paginated set of tournaments for this user
 */
- (void)fetchTournaments:(void(^)(NSDictionary*))handler page:(NSString *)page isBlocking:(BOOL)isBlocking excludeViewed:(BOOL)excludeViewed
{
    void (^connectionHandler)(NSDictionary *) = [^(NSDictionary *responseDict) {
        NSDictionary *paginationInfo = [responseDict objectForKey:@"tournaments"];
        self.previousPageTournamentsUrl = [NSString stringWithFormat:@"%@", [paginationInfo objectForKey:@"previous"]];
        self.nextPageTournamentsUrl = [NSString stringWithFormat:@"%@", [paginationInfo objectForKey:@"next"]];
        self.previousTournamentsCount = [[paginationInfo objectForKey:@"count"] intValue];
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
    if ( excludeViewed ) {
        tournamentsUrl = [NSString stringWithFormat:@"%@?excludeViewed=true", tournamentsUrl];
    }

    [self httpGet:tournamentsUrl isBlocking:isBlocking handler:connectionHandler];
}



/**
    Calls getTournaments, then parses the results and displays the tournaments in an alertView
 */
- (void)showPreviousTournaments:(void(^)(void))handler page:(NSString *)page excludeViewed:(BOOL)excludeViewed
{
    ArbiterPreviousTournamentsView *view = [[ArbiterPreviousTournamentsView alloc] init:self excludeViewed:excludeViewed];
    view.callback = handler;
    [self.panelWindow show:view];
}


/**
    Gets the latest incomplete tournaments from Arbiter. Paginated by 1 comp per page
 */
- (void)fetchIncompleteTournaments:(void(^)(NSDictionary*))handler page:(NSString *)page isBlocking:(BOOL)isBlocking
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

    [self httpGet:tournamentsUrl isBlocking:isBlocking handler:connectionHandler];
}

/**
    Displays the current incomplete tournament in an alertView with buttons to finish the tournament
 */
- (void)showIncompleteTournaments:(void(^)(NSString *))handler page:(NSString *)page
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
                NSString *tournamentString = [NSString stringWithFormat:@"%@ \nEntry fee: %@ credits \nYour Score: %@ \nOpponent Score: %@\n\n",
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
        [alert setTag:SHOW_INCOMPLETE_TOURNAMENTS_ALERT_TAG];
        [alert show];
    } copy];

    [self fetchIncompleteTournaments:connectionHandler page:page isBlocking:YES];
}

- (void)reportScore:(void(^)(NSDictionary *))handler tournamentId:(NSString*)tournamentId score:(NSString*)score
{
    NSDictionary *paramsDict = @{@"score": score};
    void (^connectionHandler)(NSDictionary *) = [^(NSDictionary *responseDict) {
        handler(responseDict);
    } copy];
    NSString *requestUrl = [APITournamentBaseURL stringByAppendingString: [tournamentId stringByAppendingString: [APIReportScoreURLPart2 stringByAppendingString:[self.user objectForKey:@"id"]]]];
    [self httpPost:requestUrl params:paramsDict isBlocking:NO handler:connectionHandler];
}

- (void)markViewedTournament:(void(^)(void))handler tournamentIds:(NSMutableArray*)tournamentIds
{
    [self httpPost:APITournamentMarkAsViewed params:@{@"tournaments": tournamentIds} isBlocking:NO handler:[handler copy]];
}

- (void)showWalkThrough:(void (^)(void))handler walkThroughId:(NSString *)walkThroughId
{
    ArbiterWalkThrough *view = [[ArbiterWalkThrough alloc] initWithWalkThroughId:walkThroughId arbiterInstance:self];
    view.callback = handler;
    [self.panelWindow show:view];
}

- (void)showTournamentDetailsPanel:(void(^)(void))handler tournamentId:(NSString *)tournamentId
{
    [self fetchTournament:[^(NSDictionary *tournament) {
        ArbiterTournamentResultsView *resultsView = [[ArbiterTournamentResultsView alloc] initWithTournament:tournament arbiterInstance:self];
        resultsView.callback = handler;
        [self.panelWindow show:resultsView];
    } copy]
             tournamentId:tournamentId
               isBlocking:YES];
}


#pragma mark NSURLConnection Delegate Methods

- (void)httpGet:(NSString*)url isBlocking:(BOOL)isBlocking handler:(void(^)(NSDictionary*))handler
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
    if ( isBlocking ) {
        [self addRequestToQueue:key];
    }
    [NSURLConnection connectionWithRequest:request delegate:self];
}

-(void)httpPost:(NSString*)url params:(NSDictionary*)params isBlocking:(BOOL)isBlocking handler:(void(^)(NSDictionary*))handler
{
    NSLog( @"ArbiterSDK POST %@", url );
    NSError *error = nil;
    NSData *paramsData;
    NSString *paramsStr;
    NSString *tokenValue;
    NSString *key = [url stringByAppendingString:@":POST"];
    
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
        
        if ( isBlocking ) {
            [self addRequestToQueue:key];
        }
        [_connectionHandlerRegistry setObject:handler forKey:key];
        [NSURLConnection connectionWithRequest:request delegate:self];
    }
}

-(void)httpPostAsDeveloper:(NSString *)url params:(NSDictionary *)params handler:(void (^)(NSDictionary *))handler
{
    NSLog( @"ArbiterSDK POST %@", url );
    NSError *error = nil;
    NSData *paramsData;
    NSString *paramsStr;
    NSString *tokenValue = [NSString stringWithFormat:@"Token %@::%@", self.accessToken, self.apiKey];
    
    if( params == nil ) {
        params = @{};
    }
    paramsData = [NSJSONSerialization dataWithJSONObject:params
                                                 options:0
                                                   error:&error];
    paramsStr = [[NSString alloc] initWithData:paramsData encoding:NSUTF8StringEncoding];
    
    if( error != nil ) {
        NSLog(@"ERROR: %@", error);
        handler( @{@"success": @"false",
                   @"errors": @[error]});
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

- (void)addRequestToQueue:(NSString *)key
{
    if ( [self.requestQueue objectForKey:key] ) {
        [self.requestQueue setObject:@([[self.requestQueue objectForKey:key] intValue] + 1) forKey:key];
    } else {
        [self.requestQueue setObject:@1 forKey:key];
    }
    if ( [self.requestQueue count] > 0 ) {
        UIView *keyRVCV = [[UIApplication sharedApplication] keyWindow].rootViewController.view;
        [self.spinnerView setFrame:keyRVCV.bounds];
        [keyRVCV addSubview:self.spinnerView];
        [self.spinnerView startAnimating];
    }
}

- (void)removeRequestFromQueue:(NSString *)key
{
    [self.requestQueue setObject:@([[self.requestQueue objectForKey:key] intValue] - 1) forKey:key];
    
    if ( [[self.requestQueue objectForKey:key] intValue] <= 0 ) {
        [self.requestQueue removeObjectForKey:key];
    }
    if ( [self.requestQueue count] == 0 ) {
        [self.spinnerView stopAnimating];
        [self.spinnerView removeFromSuperview];
    } else {
        NSLog(@"Open requests still out: %@", self.requestQueue);
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
    if ( [self.requestQueue objectForKey:key] != nil ) {
        [self removeRequestFromQueue:key];
    }
    handler(dict);
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    NSLog(@"connection error:%@", error);
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
    } else if ( alertView.tag == VERIFICATION_ALERT_TAG ) {
        void (^connectionHandler)(NSDictionary *) = [^(NSDictionary *responseDict) {
            if ([[responseDict objectForKey:@"success"] boolValue] == true) {
                self.wallet = [NSMutableDictionary dictionaryWithDictionary:[responseDict objectForKey:@"wallet"]];
                self.user = [NSMutableDictionary dictionaryWithDictionary:[responseDict objectForKey:@"user"]];
                void (^handler)(NSDictionary *) = [_alertViewHandlerRegistry objectForKey:@"agreedToTermsHandler"];
                handler(responseDict);
            }
        } copy];
        
        // Agree
        if ( buttonIndex == 0 ) {
            NSDictionary *postParams = @{@"postal_code": [self.user objectForKey:@"postal_code"]};
            NSMutableString *verificationUrl = [NSMutableString stringWithString: APIUserDetailsURL];
            [verificationUrl appendString: [self.user objectForKey:@"id"]];
            [verificationUrl appendString: @"/verify"];
            [self httpPost:verificationUrl params:postParams isBlocking:YES handler:connectionHandler];

        // View Terms
        } else if ( buttonIndex == 1 ) {
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://www.arbiter.me/terms/"]];
        }
        
        // Cancel
        if (buttonIndex == 2) {
            NSDictionary *dict = @{@"success": @"false", @"errors":@[@"User has canceled verification."]};
            connectionHandler(dict);
        }

    } else if ( alertView.tag == ENABLE_LOCATION_ALERT_TAG) {
        void (^handler)(NSDictionary *) = [_alertViewHandlerRegistry objectForKey:@"enableLocationServices"];
        [_alertViewHandlerRegistry removeObjectForKey:@"enableLocationServices"];
        if (buttonIndex == 1) {
            [self verifyUser:handler];
        }
    } else if ( alertView.tag == SHOW_INCOMPLETE_TOURNAMENTS_ALERT_TAG ) {
        void (^handler)(NSString *) = [_alertViewHandlerRegistry objectForKey:@"closeIncompleteGamesHandler"];
        if ( [buttonTitle isEqualToString:@"Next"] ) {
            [self showIncompleteTournaments:handler page:@"next"];
        } else if ( [buttonTitle isEqualToString:@"Prev"] ) {
            [self showIncompleteTournaments:handler page:@"previous"];
        } else if ( [buttonTitle isEqualToString:@"Play"] ) {
            handler(self.currentIncompleteTournamentId);
        }else {
            handler(@"");
        }

    } else if ( alertView.tag == TOURNAMENT_DETAILS_ALERT_TAG ) {
        void (^handler)(void) = [_alertViewHandlerRegistry objectForKey:@"closeTournamentDetailsHandler"];
        handler();
    } else if ( alertView.tag == NO_ACTION_ALERT_TAG ) {
        // Don't do anything since no action is required
    }
    
    // Default to the main wallet screen
    else {
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
    [self httpGet:gameSettingsUrl isBlocking:NO handler:connectionHandler];
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

- (NSDictionary *)getCurrentUserFromTournament: (NSDictionary *)tournament
{
    for ( NSDictionary *user in [tournament objectForKey:@"users"] ) {
        if ( [[user objectForKey:@"id"] isEqualToString:[self.user objectForKey:@"id"]] ) {
            return user;
        }
    }
    return nil;
}

- (NSDictionary *)getOpponentFromTournament: (NSDictionary *)tournament
{
    NSDictionary *opponent = nil;
    for ( NSDictionary *user in [tournament objectForKey:@"users"] ) {
        if ( ![[user objectForKey:@"id"] isEqualToString:[self.user objectForKey:@"id"]] ) {
            opponent = user;
        }
    }
    return opponent;
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


#pragma mark Logging Methods

-(void) addLogs:(NSMutableDictionary*)data
{
    data[@"user"] = [self.user mutableCopy];
}

@end
