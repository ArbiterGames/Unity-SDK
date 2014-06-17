//
//  Arbiter.m
//  Arbiter
//
//  Copyright (c) 2014 Arbiter. All rights reserved.
//


#import <GameKit/GameKit.h>
#import <CoreLocation/CoreLocation.h>
#import "Arbiter.h"


#define PRE_URL @"https://www.arbiter.me/api/v1/"

NSString *const APIUserInitializeURL = PRE_URL @"user/initialize";
NSString *const APIWalletURL = PRE_URL @"wallet/";
NSString *const APIUserLoginURL = PRE_URL @"user/login";
NSString *const APIUserLogoutURL = PRE_URL @"user/logout";
NSString *const APILinkWithGameCenterURL = PRE_URL @"user/link-with-game-center";
NSString *const APIUserDetailsURL = PRE_URL @"user/";
NSString *const APITournamentCreateURL = PRE_URL @"tournament/create";
NSString *const APIRequestTournamentURL = PRE_URL @"tournament/";
NSString *const APIReportScoreURLPart1 = PRE_URL @"tournament/";
NSString *const APIReportScoreURLPart2 = @"/report-score/";

#define SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(v)  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedAscending)


@implementation Arbiter


#pragma mark User Methods


- (id)init:(void(^)(NSDictionary *))handler apiKey:(NSString*)apiKey
{
    self = [super init];
    self.apiKey = apiKey;
    
    if ( self ) {
        _alertViewHandlerRegistry = [[NSMutableDictionary alloc] init];
        _responseDataRegistry = [[NSMutableDictionary alloc] init];
        _connectionHandlerRegistry = [[NSMutableDictionary alloc] init];

        void (^connectionHandler)(NSDictionary *) = [^(NSDictionary *responseDict) {
            self.wallet = [NSMutableDictionary dictionaryWithDictionary:[responseDict objectForKey:@"wallet"]];
            self.user = [NSMutableDictionary dictionaryWithDictionary:[responseDict objectForKey:@"user"]];
            handler(responseDict);
        } copy];

        [self httpGet:APIUserInitializeURL handler:connectionHandler];
    }
    return self;
}


- (void)loginWithGameCenterPlayer:(void(^)(NSDictionary *))handler
{
    //
    // NOTE: This function assumes the player used something else (like Unity) to authenticate.
    //

    void (^connectionHandler)(NSDictionary *) = [^(NSDictionary *responseDict) {
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
                    @"bundleID":[[NSBundle mainBundle] bundleIdentifier]
                };

                [self httpPost:APILinkWithGameCenterURL params:paramsDict handler:connectionHandler];
            }
        }];
    }
}

- (void)verifyUser:(void(^)(NSDictionary *))handler
{
    void (^locationCallback)(NSString *) = ^(NSString *postalCode) {
        [self.user setValue:postalCode forKey:@"postal_code"];
        
        if ( [[self.user objectForKey:@"is_verified"] boolValue] == true ) {
            handler(self.user);
        } else {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle: @"Terms and Conditions"
                                                            message: @"By clicking confirm below, you are confirming that you are at least 18 years old and agree to the terms and conditions at https://www.arbiter.me/terms"
                                                           delegate: self
                                                  cancelButtonTitle:@"Cancel"
                                                  otherButtonTitles:@"Agree", nil];
            [_alertViewHandlerRegistry setObject:handler forKey:@"agreedToTermsHandler"];
            [alert setTag:2];
            [alert show];
        }
    };
    [self getDevicePostalCode:locationCallback];

    // TODO:
    // On the server:
    //  check the postalCode to the game based on the gameApiKey
    // Notify the user whether or not they will be able to be here
    // Then get 'play fake game' button working
    
}

- (void)getDevicePostalCode:(void(^)(NSString *))handler
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
        if ( error ) {
            handler([NSString stringWithFormat: @"Geocode failed with error: %@", error]);
        }
        CLPlacemark *placemark = [placemarks objectAtIndex:0];
        handler(placemark.postalCode);
    }];
}


- (void)logout:(void(^)(NSDictionary *))handler
{
    // Actually make the /logout call to the server
    void (^connectionHandler)(NSDictionary *) = [^(NSDictionary *responseDict) {
        self.user = nil;
        self.wallet = nil;
        handler(responseDict);
    } copy];
    
    [self httpPost:APIUserLogoutURL params:nil handler:connectionHandler];
}

- (void)getWallet:(void(^)(NSDictionary *))handler
{
    void (^connectionHandler)(NSDictionary *) = [^(NSDictionary *responseDict) {
//        self.wallet = [responseDict objectForKey:@"wallet"];
        self.wallet = [NSMutableDictionary dictionaryWithDictionary:[responseDict objectForKey:@"wallet"]];
        handler(responseDict);
    } copy];
    
    if ( self.user ) {
        NSString *walletUrl = [APIWalletURL stringByAppendingString:[self.user objectForKey:@"id"]];
        [self httpGet:walletUrl handler:connectionHandler];
    } else {
        handler( @{@"success": @"false",
                   @"errors": @[@"No user is currently logged in. Use the Init, Login or LoginWithGameCenterPlayer, to get an Arbiter User."]
                 });
    }
}


#pragma mark Wallet Methods

- (void)showWalletPanel:(void(^)(void))handler
{
    void (^connectionHandler)(void) = [^(void) {
        handler();
    } copy];

    [_alertViewHandlerRegistry setObject:connectionHandler forKey:@"closeWalletHandler"];

    NSString *title = [NSString stringWithFormat: @"Balance: %@ credits", [self.wallet objectForKey:@"balance"]];
    NSString *message = [NSString stringWithFormat: @"Pending: %@ credits\nLocation: %@", [self.wallet objectForKey:@"pending_balance"], [self.user objectForKey:@"postal_code"]];
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title message:message delegate:self cancelButtonTitle:@"Close" otherButtonTitles:@"Refresh", @"Deposit", @"Withdraw", nil];
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


#pragma mark Tournament Methods

/**
    Requests a new Tournament for this user from Arbiter
 */
- (void)requestTournament:(void(^)(NSDictionary *))handler buyIn:(NSString*)buyIn filters:(NSString*)filters
{
    NSDictionary *paramsDict = @{
        @"buy_in":buyIn,
        @"filters":filters
    };

    void (^connectionHandler)(NSDictionary *) = [^(NSDictionary *responseDict) {
        handler(responseDict);
    } copy];

    [self httpPost:APITournamentCreateURL params:paramsDict handler:connectionHandler];
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
        tournamentsUrl = [NSString stringWithFormat:@"%@%@?game_api_key=%@", APIRequestTournamentURL, [self.user objectForKey:@"id"], self.apiKey];
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
                NSString *tournamentString = [NSString stringWithFormat:@"%@ \nBet Size: %@Credits \nYour Score: %@ \nOpponent Score: %@\n\n",
                    [dateFormatter stringFromDate:unFormattedDate],
                    [[[tournaments objectAtIndex:i] objectForKey:@"jackpot"] objectForKey:@"buy_in"],
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
        [alert setTag:10];
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
        tournamentsUrl = [NSString stringWithFormat:@"%@%@?page_size=1&exclude=complete", APIRequestTournamentURL, [self.user objectForKey:@"id"]];
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
                NSString *tournamentString = [NSString stringWithFormat:@"%@ \nBet Size: %@Credits \nYour Score: %@ \nOpponent Score: %@\n\n",
                                               [dateFormatter stringFromDate:unFormattedDate],
                                               [[[tournaments objectAtIndex:i] objectForKey:@"jackpot"] objectForKey:@"buy_in"],
                                               [self getPlayerScoreFromTournament:[tournaments objectAtIndex:i]],
                                               [self getOpponentScoreFromTournament:[tournaments objectAtIndex:i]]];
                [message appendString:tournamentString];
                [yourScore appendString:[self getPlayerScoreFromTournament:[tournaments objectAtIndex:i]]];
            }
        } else {
            [message appendString:@"No incomplete games"];
        }

        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Incomplete Games" message:message delegate:self cancelButtonTitle:@"Close" otherButtonTitles:nil];

        if ( [yourScore isEqualToString:@"n/a"]) {
            [alert addButtonWithTitle:@"Play"];
        }

        if ( [tournamentSerializer objectForKey:@"previous"] != (id)[NSNull null] ) {
            [alert addButtonWithTitle:@"Prev"];
        }
        if ( [tournamentSerializer objectForKey:@"next"] != (id)[NSNull null] ) {
            [alert addButtonWithTitle:@"Next"];
        }

        [_alertViewHandlerRegistry setObject:handler forKey:@"closeIncompleteGamesHandler"];
        [alert setTag:11];
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

    NSString *requestUrl = [APIReportScoreURLPart1 stringByAppendingString: [tournamentId stringByAppendingString: [APIReportScoreURLPart2 stringByAppendingString:[self.user objectForKey:@"id"]]]];

    [self httpPost:requestUrl params:paramsDict handler:connectionHandler];
}


#pragma mark NSURLConnection Delegate Methods

- (void)httpGet:(NSString*)url handler:(void(^)(NSDictionary*))handler {
    NSLog( @"ArbiterSDK GET %@", url );
    NSMutableURLRequest *request = [NSMutableURLRequest
        requestWithURL:[NSURL URLWithString:url]
        cachePolicy:NSURLRequestUseProtocolCachePolicy
        timeoutInterval:60.0];
    NSString *tokenValue = [NSString stringWithFormat:@"Token %@::%@", [self.user objectForKey:@"token"], self.apiKey];
    [request setValue:tokenValue forHTTPHeaderField:@"Authorization"];
    NSString *key = [url stringByAppendingString:@":GET"];
    [_connectionHandlerRegistry setObject:handler forKey:key];
    [NSURLConnection connectionWithRequest:request delegate:self];
}

-(void)httpPost:(NSString*)url params:(NSDictionary*)params handler:(void(^)(NSDictionary*))handler {
    NSLog( @"ArbiterSDK POST %@", url );
    NSError *error = nil;
    NSData *paramsData;
    NSString *tokenValue = [NSString stringWithFormat:@"Token %@::%@", [self.user objectForKey:@"token"], self.apiKey];
    
    if( params == nil ) {
        params = @{};
    }
    paramsData = [NSJSONSerialization dataWithJSONObject:params
                                                 options:0
                                                   error:&error];
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
        [request setValue:[NSString stringWithFormat:tokenValue] forHTTPHeaderField:@"Authorization"];
        [request setHTTPMethod:@"POST"];
        if( paramsData != nil ) {
            NSString *paramsStr = [[NSString alloc] initWithData:paramsData encoding:NSUTF8StringEncoding];
            [request setHTTPBody:[paramsStr dataUsingEncoding:NSUTF8StringEncoding]];
        }

        NSLog(@"apiKey: %@", self.apiKey);
        NSLog(@"token: %@", [self.user objectForKey:@"token"]);
        NSLog(@"Token value: %@", tokenValue);

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
                self.wallet = [NSMutableDictionary dictionaryWithDictionary:[responseDict objectForKey:@"wallet"]];
                self.user = [NSMutableDictionary dictionaryWithDictionary:[responseDict objectForKey:@"user"]];
                void (^handler)(NSDictionary *) = [_alertViewHandlerRegistry objectForKey:@"agreedToTermsHandler"];
                handler(self.user);
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
                    self.wallet = [NSMutableDictionary dictionaryWithDictionary:[responseDict objectForKey:@"wallet"]];
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
            NSString *walletUrl = [NSString stringWithFormat:@"%@%@", APIWalletURL, [self.user objectForKey:@"id"]];
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

    // Previous tournaments
    } else if ( alertView.tag == 10 ) {
        void (^handler)(void) = [_alertViewHandlerRegistry objectForKey:@"closePreviousGamesHandler"];

        if ( [buttonTitle isEqualToString:@"Next"] ) {
            [self viewPreviousTournaments:handler page:@"next"];
        } else if ( [buttonTitle isEqualToString:@"Prev"] ) {
            [self viewPreviousTournaments:handler page:@"previous"];
        } else {
            handler();
        }

    // Incomplete tournaments
    } else if ( alertView.tag == 11 ) {
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

- (NSString *)getPlayerScoreFromTournament: (NSDictionary *)tournament
{
    // TODO: Might need to add score to the users arrary returned with the tournament
    for ( NSDictionary *player in [tournament objectForKey:@"users"] ) {
        NSDictionary *playerUser = [player objectForKey:@"user"];
        if ( [[playerUser objectForKey:@"id"] isEqualToString:[self.user objectForKey:@"id"]] ) {
            if ( [player objectForKey:@"score"] == (id)[NSNull null] ) {
                return @"n/a";
            } else {
                return [player objectForKey:@"score"];
            }
        }
    }
}

- (NSString *)getOpponentScoreFromTournament: (NSDictionary *)tournament
{
    for ( NSDictionary *player in [tournament objectForKey:@"users"] ) {
        NSDictionary *playerUser = [player objectForKey:@"user"];
        if ( ![[playerUser objectForKey:@"id"] isEqualToString:[self.user objectForKey:@"id"]] ) {
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
