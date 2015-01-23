//
//  Arbiter.m
//  Arbiter
//
//  Copyright (c) 2014 Arbiter. All rights reserved.
//

//


#import <Foundation/Foundation.h>
#import <GameKit/GameKit.h>
#import <CoreLocation/CoreLocation.h>
#import <CommonCrypto/CommonDigest.h>
#import "Reachability.h"
#import "ARBConstants.h"
#import "Arbiter.h"
#import "ARBWalletDashboardView.h"
#import "ARBWalletDashboardWebView.h"
#import "ARBTournamentResultsView.h"
#import "ARBPreviousTournamentsView.h"
#import "ARBWalkThrough.h"
#import "ARBCashChallengeOfficialRules.h"
#import "ARBLogger.h"
#import "ARBTracking.h"

#define LOGIN_ALERT_TAG 329
#define INVALID_LOGIN_ALERT_TAG 330
#define WALLET_ALERT_TAG 331
#define VERIFICATION_ALERT_TAG 332
#define ENABLE_LOCATION_ALERT_TAG 333
#define SHOW_INCOMPLETE_TOURNAMENTS_ALERT_TAG 337
#define TOURNAMENT_DETAILS_ALERT_TAG 338
#define NO_ACTION_ALERT_TAG 339
#define DEVELOPMENT_TRACKING_ID @"2dd66d1b05b4ce8c7dcc7c3cb35e113a"
#define PRODUCTION_TRACKING_ID @"d9bda693b63f0d1922a3c153b65d02d9"

@implementation Arbiter
{
    NSMutableDictionary *_alertViewHandlerRegistry;
    NSMutableDictionary *_connectionHandlerRegistry;
    NSMutableDictionary *_responseDataRegistry;
    CLLocationManager *locationManager;
    CLLocation *currentLocation;
    NSDictionary *_NO_CONNECTION_RESPONSE_DICT;
}

static Arbiter *_sharedInstance = nil;

+ (Arbiter *)initWithApiKey:(NSString *)apiKey accessToken:(NSString *)accessToken handler:(void(^)(NSDictionary *))handler
{
    static dispatch_once_t oncePredicate;
    dispatch_once(&oncePredicate, ^{
        _sharedInstance = [[Arbiter alloc] init:handler apiKey:apiKey accessToken:accessToken];
    });
    return _sharedInstance;
}

+ (Arbiter *)sharedInstance
{
    if ( _sharedInstance == nil ) {
        NSLog(@"Arbiter Error: sharedInstance called before initWithApiKey:accessToken:handler");
    }
    return _sharedInstance;
}

- (id)init:(void(^)(NSDictionary *))handler apiKey:(NSString*)apiKey accessToken:(NSString*)accessToken
{
    self = [super init];
    if ( self ) {
        _NO_CONNECTION_RESPONSE_DICT = @{
            @"success": @false, 
            @"errors": @[@"Device has no internet connection."],
            @"descriptions": @[@"Your device appears to be offline. Make sure you are connected to the internet."]
        };
        
        self.hasConnection = NO;
        self.apiKey = apiKey;
        self.accessToken = accessToken;
        self._deviceHash = [self buildDeviceHash];
        self.locationVerificationAttempts = 0;
        self.panelWindow = [[ARBPanelWindow alloc] initWithGameWindow:[[UIApplication sharedApplication] keyWindow]];
        
        _alertViewHandlerRegistry = [[NSMutableDictionary alloc] init];
        _responseDataRegistry = [[NSMutableDictionary alloc] init];
        _connectionHandlerRegistry = [[NSMutableDictionary alloc] init];
        
        self.requestQueue = [[NSMutableDictionary alloc] init];
        self.spinnerView = [[UIActivityIndicatorView alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
        self.spinnerView.activityIndicatorViewStyle = UIActivityIndicatorViewStyleWhiteLarge;
        self.spinnerView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.5f];


        void (^handlerWrapper)(NSDictionary *) = [^(NSDictionary *innerResponse) {
            if( [self hydrateUserWithCachedToken] ) {
                [self loginWithDevice:handler];
            } else {
                handler(innerResponse);
                // At this point, we know that no user is logged in. So we are going from
                //      undefined user to no user.
                ClientCallbackUserUpdated();
            }
        } copy];
        [self establishConnection:handlerWrapper];
    } else {
        handler(@{@"success": @true});
    }
    return self;
}


# pragma mark Internet Connection Utilities

-(void)establishConnection:(void(^)(NSDictionary *))handler
{
    void (^connectionHandler)(NSDictionary *) = [^(NSDictionary *responseDict) {
        self.hasConnection = YES;
        self.isWalletDashboardWebViewEnabled = [[responseDict objectForKey:@"is_wallet_webview_enabled"] boolValue];
        self.game = responseDict;
        if ( [[self.game objectForKey:@"is_live"] boolValue] ) {
            [ARBTracking arbiterInstanceWithToken:PRODUCTION_TRACKING_ID];
        } else {
            [ARBTracking arbiterInstanceWithToken:DEVELOPMENT_TRACKING_ID];
        }

        NSNumber* timesSeen = [NSNumber numberWithInt:0];
        NSString* thisGameId = [NSString stringWithFormat:@"seen_arbiter_game_%@", self.apiKey];
        if( [[NSUserDefaults standardUserDefaults] objectForKey:thisGameId] != nil ) {
            timesSeen = [[NSUserDefaults standardUserDefaults] objectForKey:thisGameId];
        }
        NSDictionary* trackingProperties = @{@"seen_game_on_device":timesSeen};
        timesSeen = [NSNumber numberWithInt:([timesSeen intValue]+1)];
        [[NSUserDefaults standardUserDefaults] setObject:timesSeen forKey:thisGameId];
        
        ARBTracking *arbiterInstance = [ARBTracking arbiterInstance];
        [arbiterInstance identify:arbiterInstance.distinctId];
        [arbiterInstance registerSuperProperties:@{@"game": [self.game objectForKey:@"name"]}];
        [arbiterInstance track:@"Loaded Game" properties:trackingProperties];
        handler(@{@"success": @true});
    } copy];
    
    Reachability* reach = [Reachability reachabilityWithHostname:@"www.google.com"];
    reach.reachableBlock = ^(Reachability*reach) { self.hasConnection = YES; };
    reach.unreachableBlock = ^(Reachability*reach) { self.hasConnection = NO; };
    [reach startNotifier];

    NSString *gameSettingsUrl = [NSString stringWithFormat:@"%@%@", GameSettingsURL, self.apiKey];
    [self httpGet:gameSettingsUrl params:nil authTokenOverride:self.accessToken isBlocking:NO handler:connectionHandler];
}


- (NSString*)deviceHash
{
    return self._deviceHash;
}
// NOTE: Use the self.deviceHash property to get the hash. This is designed to be called once and then cash it in the deviceHash property.
- (NSString*)buildDeviceHash {
    NSString* deviceId = [UIDevice currentDevice].identifierForVendor.UUIDString;
    return [self sha1:[deviceId stringByAppendingString:self.apiKey]];
}



#pragma mark User Methods

- (void)setUser:(NSMutableDictionary*)user
{
    bool wasNil = self._user == nil;
    self._user = user;
    
    // If this is a "full" user, save it and alert any listeners
    // Also need to alert when the user first goes null (eg logout)
    if( !IS_NULL_STRING([user objectForKey:@"id"]) || (!wasNil && self._user == nil)) {
        ClientCallbackUserUpdated();
        [self saveUserToken:user];
    }
}
- (NSMutableDictionary *)user
{
    return self._user;
}

- (void)getCachedUser:(void(^)(NSDictionary *))handler
{
    handler(self.user);
}

- (void)saveUserToken:(NSMutableDictionary*)user
{
    if( user == nil ) {
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:DEFAULTS_USER_TOKEN];
    } else {
        NSString* token = [NSString stringWithString:[self.user objectForKey:USER_TOKEN]];
        [[NSUserDefaults standardUserDefaults] setObject:token forKey:DEFAULTS_USER_TOKEN];
    }
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (bool)hydrateUserWithCachedToken {
    NSString* savedToken = [[NSUserDefaults standardUserDefaults] objectForKey:DEFAULTS_USER_TOKEN];
    if ( !IS_NULL_STRING(savedToken)) {
        if (self.user == nil) {
            self.user = [[NSMutableDictionary alloc] initWithDictionary:@{USER_TOKEN:[NSString stringWithString:savedToken]}];
        } else {
            [self.user setObject:savedToken forKey:USER_TOKEN];
        }
        return true;
    } else {
        return false;
    }
}

- (void)loginWithDevice:(void(^)(NSDictionary *))handler
{
    void (^connectionHandler)(NSDictionary *) = [^(NSDictionary *responseDict) {
        if ([self isSuccessfulResponse:responseDict]) {
            self.wallet = [NSMutableDictionary dictionaryWithDictionary:[responseDict objectForKey:@"wallet"]];
            self.user = [NSMutableDictionary dictionaryWithDictionary:[responseDict objectForKey:@"user"]];
            [[ARBTracking arbiterInstance] identify:[self.user objectForKey:@"id"]];    
        }
        handler(responseDict);
    } copy];
    
    if ( self.hasConnection ) {
        NSDictionary *urlParams = @{@"tracking_id":[[ARBTracking arbiterInstance] distinctId]};
        [self httpPost:APIUserLoginDevice params:urlParams authTokenOverride:self.accessToken isBlocking:NO handler:connectionHandler];
    } else {
        handler(_NO_CONNECTION_RESPONSE_DICT);
    }
}

- (void)loginWithGameCenterPlayer:(void(^)(NSDictionary *))handler
{
    GKLocalPlayer *localPlayer = [GKLocalPlayer localPlayer];
    if( !localPlayer.isAuthenticated ) {
        handler(@{@"success": @false,
                  @"errors": @[@"local player is not authenticated"]});
        return;
    }
    
    if ( [localPlayer respondsToSelector:@selector(generateIdentityVerificationSignatureWithCompletionHandler:)] ) {
        void (^connectionHandler)(NSDictionary *) = [^(NSDictionary *responseDict) {
            self.wallet = [NSMutableDictionary dictionaryWithDictionary:[responseDict objectForKey:@"wallet"]];
            self.user = [NSMutableDictionary dictionaryWithDictionary:[responseDict objectForKey:@"user"]];
            [[ARBTracking arbiterInstance] identify:[self.user objectForKey:@"id"]];
            handler(responseDict);
        } copy];
        
        if ( self.hasConnection ) {
            [localPlayer generateIdentityVerificationSignatureWithCompletionHandler:^(NSURL *publicKeyUrl, NSData *signature, NSData *salt, uint64_t timestamp, NSError *error) {
                if (error) {
                    handler( @{@"success": @false,
                               @"errors": @[[error localizedDescription]]});
                } else {
                    NSDictionary *paramsDict = @{@"publicKeyUrl":[publicKeyUrl absoluteString],
                                                 @"timestamp":[NSString stringWithFormat:@"%llu", timestamp],
                                                 @"signature":[signature base64EncodedStringWithOptions:0],
                                                 @"salt":[salt base64EncodedStringWithOptions:0],
                                                 @"playerID":localPlayer.playerID,
                                                 @"game_center_username": localPlayer.alias,
                                                 @"bundleID":[[NSBundle mainBundle] bundleIdentifier],
                                                 @"tracking_id":[[ARBTracking arbiterInstance] distinctId]};
                    [self httpPost:APIUserLoginGameCenterURL params:paramsDict isBlocking:NO handler:connectionHandler];
                }
            }];
        } else {
            handler(_NO_CONNECTION_RESPONSE_DICT);
        }
    } else {
        handler(@{@"success": @false,
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
    [[UIApplication sharedApplication] endIgnoringInteractionEvents];
    [loginAlert show];
    
    UIAlertView *invalidLoginAlert = [[UIAlertView alloc] initWithTitle:@"Unable to login"
                                                                message:@"The email or password was incorrect."
                                                               delegate:self
                                                      cancelButtonTitle:@"OK"
                                                      otherButtonTitles:nil];
    [invalidLoginAlert setTag:INVALID_LOGIN_ALERT_TAG];
    
    
    void (^connectionHandler)(NSDictionary *) = [^(NSDictionary *responseDict) {
        if ([self isSuccessfulResponse:responseDict]) {
            self.wallet = [NSMutableDictionary dictionaryWithDictionary:[responseDict objectForKey:@"wallet"]];
            self.user = [NSMutableDictionary dictionaryWithDictionary:[responseDict objectForKey:@"user"]];
            ARBTracking *arbiterInstance = [ARBTracking arbiterInstance];
            [arbiterInstance identify:[self.user objectForKey:@"id"]];
            handler(responseDict);
        } else {
            [[UIApplication sharedApplication] endIgnoringInteractionEvents];
            [invalidLoginAlert show];
        }
    } copy];
    
    void (^loginAlertHandler)(NSDictionary *) = [^(NSDictionary *loginCredentials) {
        if ( [loginCredentials objectForKey:@"errors"] ) {
            handler(@{@"success": @"false", @"errors":[loginCredentials objectForKey:@"errors"]});
        } else {
            if ( self.hasConnection ) {
                NSMutableDictionary *params = [[NSMutableDictionary alloc] initWithDictionary:loginCredentials];
                [params setObject:[[ARBTracking arbiterInstance] distinctId] forKey:@"tracking_id"];
                [self httpPost:APIUserLoginURL params:params isBlocking:NO handler:connectionHandler];
            } else {
                handler(_NO_CONNECTION_RESPONSE_DICT);
            }
        }
    } copy];
    
    void (^invalidLoginAlertHandler)(NSDictionary *) = [^(NSDictionary *emptyDict) {
        [[UIApplication sharedApplication] endIgnoringInteractionEvents];
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
    
    if ( self.hasConnection ) {
        [self httpPost:APIUserLogoutURL params:nil isBlocking:NO handler:connectionHandler];
    } else {
        handler(_NO_CONNECTION_RESPONSE_DICT);
    }
}

- (bool)isUserAuthenticated
{
    return self.user != nil && !IS_NULL_STRING([self.user objectForKey:@"id"]);
}

- (void)verifyUser:(void(^)(NSDictionary *))handler
{
    [self verifyUser:handler tryToGetLatLong:YES];
}
- (void)verifyUser:(void(^)(NSDictionary *))handler tryToGetLatLong:(BOOL)tryToGetLatLong
{
    if( self.user == nil ) {
        NSLog(@"Arbiter Error: Cannot verify users since no user is currently logged in. Call one of the Login first.");
        handler( @{@"success": @"false"} );
        return;
    }

    if ( !self.hasConnection ) {
        handler(_NO_CONNECTION_RESPONSE_DICT);
        return;
    }

    [[ARBTracking arbiterInstance] track:@"Verifying User"];

    /* Recursively call this function to check each thing that needs to be verified in order.
     * Once all checks pass, this function calls the handler (this method argument)
     */


    /**********************************************
     * COMMON ASYNC HANDLER DECLARATIONS
     **********************************************/
    void (^locationCallback)(NSDictionary *) = ^(NSDictionary *geoCodeResponse) {
        NSLog(@"GeoCodeResponse:\n%@", geoCodeResponse);
        if ([self isSuccessfulResponse:geoCodeResponse]) {

            [self.user setObject:[geoCodeResponse objectForKey:@"postalCode"] forKey:@"postal_code"];
            if ( tryToGetLatLong ) {
                NSString* lat = [geoCodeResponse objectForKey:@"lat"];
                NSString* lon = [geoCodeResponse objectForKey:@"long"];
                if( lat != nil )
                    [self.user setObject:lat forKey:@"lat"];
                if( lon != nil )
                    [self.user setObject:lon forKey:@"long"];
            }

            [[ARBTracking arbiterInstance] track:@"Device Location Found"];

            // Don't try to get lat/long more than 1 time--since we just tried to get it and it's optional, move on no matter what next time
            [self verifyUser:handler tryToGetLatLong:NO];
        } else {

            void (^alertViewHandler)(NSDictionary *) = [^(NSDictionary *response) {
                if ([self isSuccessfulResponse:response]) {
                    [self verifyUser:handler tryToGetLatLong:tryToGetLatLong];
                } else {
                    handler(response);
                }
            } copy];
            if( [_alertViewHandlerRegistry objectForKey:@"enableLocationServices"] == nil ) {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Tournaments are Disabled"
                                                                message:@"Make sure Location Services are enabled in your phone\'s settings to play in cash challenges.\n\nYou can enable Location Services on your device through: Settings > Privacy > Location Services."
                                                               delegate:self
                                                      cancelButtonTitle:@"Keep disabled"
                                                      otherButtonTitles:@"Check again", nil];
                [_alertViewHandlerRegistry setObject:alertViewHandler forKey:@"enableLocationServices"];
                [alert setTag:ENABLE_LOCATION_ALERT_TAG];
                [[UIApplication sharedApplication] endIgnoringInteractionEvents];
                [alert show];
            }            
        }
    };

    void (^postVerifyCallback)(NSDictionary* ) = ^(NSDictionary *verifyResponse) {
        if ([self isSuccessfulResponse:verifyResponse]) {
            [[ARBTracking arbiterInstance] track:@"Verify API Success"];
            self.wallet = [NSMutableDictionary dictionaryWithDictionary:[verifyResponse objectForKey:@"wallet"]];
            self.user = [NSMutableDictionary dictionaryWithDictionary:[verifyResponse objectForKey:@"user"]];

            [self verifyUser:handler tryToGetLatLong:tryToGetLatLong];   
        } else {
            [[ARBTracking arbiterInstance] track:@"Verify API Failure"];
            handler(verifyResponse);
        }
    };



    /**********************************************
     * VERIFICATION CHECKS
     **********************************************/
    if( IS_NULL_STRING([self.user objectForKey:@"postal_code"]) ) {
        [[ARBTracking arbiterInstance] track:@"Ask Device For Location"];
        [self getDeviceLocation:locationCallback requireLatLong:NO];

    } else if( tryToGetLatLong && (IS_NULL_STRING([self.user objectForKey:@"lat"]) || IS_NULL_STRING([self.user objectForKey:@"long"])) ) {
        [[ARBTracking arbiterInstance] track:@"Ask Device For LatLong"];
        // NOTE: Lat/Long is a happy benefit but not a REQUIREMENT to verify a user
        [self getDeviceLocation:locationCallback requireLatLong:NO];

    } else if( IS_NULL_STRING([self.user objectForKey:@"agreed_to_terms"]) || [[self.user objectForKey:@"agreed_to_terms"] boolValue] == false ) {

        void (^alertViewHandler)(NSDictionary *) = [^(NSDictionary *response) {
            if ([self isSuccessfulResponse:response]) {
                [self postVerify:postVerifyCallback];
            } else {
                handler(response);
            }
        } copy];
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle: @"Terms and Conditions"
                                                        message: @"By clicking Agree below, you are confirming that you are at least 18 years old and agree to the terms of service."
                                                       delegate: self
                                              cancelButtonTitle:@"Agree"
                                              otherButtonTitles:@"View terms", @"Cancel", nil];
        [_alertViewHandlerRegistry setObject:alertViewHandler forKey:@"agreedToTermsHandler"];
        [alert setTag:VERIFICATION_ALERT_TAG];
        [[UIApplication sharedApplication] endIgnoringInteractionEvents];
        [alert show];
        [[ARBTracking arbiterInstance] track:@"Displayed Terms Dialog"];

    } else if( IS_NULL_STRING([self.user objectForKey:@"location_approved"]) || [[self.user objectForKey:@"location_approved"] boolValue] == false ) {
        [self postVerify:postVerifyCallback];

    } else {
        // Sanity check to ensure our isUserVerified() function validates the behavior of this function
        if( [self isUserVerified] ) {
            handler( @{@"user":self.user, @"success":@true} );
        } else {
            NSString* msg = [NSString stringWithFormat:@"Verification Error. Could not verify user:%@", self.user];
            NSLog( @"%@", msg );
            handler( @{
                @"success": @false, 
                @"errors": @[ msg ]
            });
            [[ARBTracking arbiterInstance] track:@"ERR: SDK Verify"];
        }
    }
}

- (void)postVerify:(void(^)(NSDictionary *))handler
{
    NSDictionary *postParams;
    if( IS_NULL_STRING([self.user objectForKey:@"lat"]) || IS_NULL_STRING([self.user objectForKey:@"long"]) ){
        postParams = @{@"postal_code": [self.user objectForKey:@"postal_code"]};
    } else {
        postParams = @{@"postal_code": [self.user objectForKey:@"postal_code"],
                       @"lat": [self.user objectForKey:@"lat"],
                       @"long": [self.user objectForKey:@"long"]};
    }
    NSMutableString *verificationUrl = [NSMutableString stringWithString: APIUserDetailsURL];
    [verificationUrl appendString: [self.user objectForKey:@"id"]];
    [verificationUrl appendString: @"/verify"];
    [self httpPost:verificationUrl params:postParams isBlocking:YES handler:handler];
}

- (bool)isUserVerified
{
    bool termsExists = !IS_NULL_STRING([self.user objectForKey:@"agreed_to_terms"]);
    bool locationExists = !IS_NULL_STRING([self.user objectForKey:@"location_approved"]);
    if (self.user != nil && termsExists && locationExists) {
        return [[self.user objectForKey:@"agreed_to_terms"] boolValue] == true &&
        [[self.user objectForKey:@"location_approved"] boolValue] == true;
    } else {
        return false;
    }
}

- (void)getDeviceLocation:(void(^)(NSDictionary *))handler requireLatLong:(BOOL)requireLatLong
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
        if( error ) {
            /* NOTE/HACK: Turning on device location services is not really asynchronous. Therefore poll it a few times
             *          here before giving up and falling back to tha handler given to this method call
             */
            if ( self.locationVerificationAttempts < 4 ) {
                [NSThread sleepForTimeInterval:2 * self.locationVerificationAttempts];
                self.locationVerificationAttempts++;
                [self getDeviceLocation:handler requireLatLong:requireLatLong];
            } else {
                [response setObject:@[ [error localizedDescription] ] forKey:@"errors"];
                handler( response );
            }
        } else {
            CLPlacemark *placemark = [placemarks objectAtIndex:0];
            [response setValue:placemark.postalCode forKey:@"postalCode"];
            CLLocation* loc = placemark.location;
            CLLocationCoordinate2D coord = loc.coordinate;
            [response setValue:[NSString stringWithFormat:@"%f", coord.latitude] forKey:@"lat"];
            [response setValue:[NSString stringWithFormat:@"%f", coord.longitude] forKey:@"long"];
            
            if ( requireLatLong == NO || ([response objectForKey:(@"lat")] != nil && [response objectForKey:(@"long")] != nil )) {
                [response setValue:@true forKey:@"success"];
            }
            
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

- (void)addWalletObserver:(id<ARBWalletObserver>)observer
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
        if ( self.hasConnection ) {
            NSString *walletUrl = [APIWalletURL stringByAppendingString:[self.user objectForKey:@"id"]];
            [self httpGet:walletUrl isBlocking:isBlocking handler:connectionHandler];
        } else {
            handler(_NO_CONNECTION_RESPONSE_DICT);
        }
    } else {
        handler(@{@"success": @"false",
                  @"errors": @[@"No user is currently logged in."]
                  });
    }
}


- (void)showWalletPanel:(void(^)(void))handler
{
    [[ARBTracking arbiterInstance] track:@"Show Wallet Dashboard"];
    if ( [self isUserAuthenticated] ) {
        [[UIApplication sharedApplication] beginIgnoringInteractionEvents];
        UIView *keyRVCV = [[UIApplication sharedApplication] keyWindow].rootViewController.view;
        [self.spinnerView setFrame:keyRVCV.bounds];
        [keyRVCV addSubview:self.spinnerView];
        [self.spinnerView startAnimating];

        void (^populateThenShowPanel)(void) = [^(void) {
            [[UIApplication sharedApplication] endIgnoringInteractionEvents];
            [self.spinnerView stopAnimating];
            [self.spinnerView removeFromSuperview];
            
            if ( self.isWalletDashboardWebViewEnabled && self.hasConnection ) {
                ARBWalletDashboardWebView *walletDashboard = [[ARBWalletDashboardWebView alloc] init:self];
                walletDashboard.callback = handler;
                [self.panelWindow show:walletDashboard];
            } else {
                ARBWalletDashboardView *walletDashboard = [[ARBWalletDashboardView alloc] init:self];
                walletDashboard.callback = handler;
                [self addWalletObserver:walletDashboard];
                [self.panelWindow show:walletDashboard];
            }
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
        NSLog(@"Arbiter Error: No user is currently logged in.");
    }
}

- (void)sendPromoCredits:(void (^)(NSDictionary *))handler amount:(NSString *)amount
{
    if ( self.hasConnection ) {
        [self httpPost:APISendPromoCreditsURL params:@{@"amount": amount, @"to": [self.user objectForKey:@"id"]} authTokenOverride:self.accessToken isBlocking:NO handler:handler];
    } else {
        handler(_NO_CONNECTION_RESPONSE_DICT);
    }
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
            if ([self isSuccessfulResponse:dict]) {
                [self httpPost:APITournamentCreateURL params:paramsDict isBlocking:NO handler:connectionHandler];
            }
        } copy];
        [self verifyUser:verifyCallback];
    } else {
        if ( self.hasConnection ) {
            [self httpPost:APITournamentCreateURL params:paramsDict isBlocking:NO handler:connectionHandler];
        } else {
            handler(_NO_CONNECTION_RESPONSE_DICT);
        }
    }
}

- (void)fetchTournament:(void(^)(NSDictionary*))handler tournamentId:(NSString *)tournamentId isBlocking:(BOOL)isBlocking
{
    void (^connectionHandler)(NSDictionary *) = [^(NSDictionary *responseDict) {
        NSDictionary *tournament = [responseDict objectForKey:@"tournament"];
        handler(tournament);
    } copy];
    
    if ( self.hasConnection ) {
         [self httpGet:[NSString stringWithFormat:@"%@%@", APITournamentBaseURL, tournamentId] isBlocking:isBlocking handler:connectionHandler];
    } else {
        handler(_NO_CONNECTION_RESPONSE_DICT);
    }
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
    
    if ( self.hasConnection ) {
         [self httpGet:tournamentsUrl isBlocking:isBlocking handler:connectionHandler];
    } else {
        handler(_NO_CONNECTION_RESPONSE_DICT);
    }
}



/**
 Calls getTournaments, then parses the results and displays the tournaments in an alertView
 */
- (void)showPreviousTournaments:(void(^)(void))handler page:(NSString *)page excludeViewed:(BOOL)excludeViewed
{
    ARBPreviousTournamentsView *view = [[ARBPreviousTournamentsView alloc] init:self excludeViewed:excludeViewed];
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
    
    if ( self.hasConnection ) {
        [self httpGet:tournamentsUrl isBlocking:isBlocking handler:connectionHandler];
    } else {
        handler(_NO_CONNECTION_RESPONSE_DICT);
    }
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
        [[UIApplication sharedApplication] endIgnoringInteractionEvents];
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
    
    if ( self.hasConnection ) {
        NSString *requestUrl = [APITournamentBaseURL stringByAppendingString: [tournamentId stringByAppendingString: [APIReportScoreURLPart2 stringByAppendingString:[self.user objectForKey:@"id"]]]];
        [self httpPost:requestUrl params:paramsDict isBlocking:NO handler:connectionHandler];
    } else {
        handler(_NO_CONNECTION_RESPONSE_DICT);
    }
}

- (void)markViewedTournament:(void(^)(void))handler tournamentIds:(NSMutableArray*)tournamentIds
{
    [self httpPost:APITournamentMarkAsViewed params:@{@"tournaments": tournamentIds} isBlocking:NO handler:[handler copy]];
}

- (void)showWalkThrough:(void (^)(void))handler walkThroughId:(NSString *)walkThroughId
{
    ARBWalkThrough *view = [[ARBWalkThrough alloc] initWithWalkThroughId:walkThroughId arbiterInstance:self];
    view.callback = handler;
    [self.panelWindow show:view];
}

- (void)showTournamentDetailsPanel:(void(^)(void))handler tournamentId:(NSString *)tournamentId
{
    [self fetchTournament:[^(NSDictionary *tournament) {
        ARBTournamentResultsView *resultsView = [[ARBTournamentResultsView alloc] initWithTournament:tournament arbiterInstance:self];
        resultsView.callback = handler;
        [self.panelWindow show:resultsView];
    } copy] tournamentId:tournamentId isBlocking:YES];
}


#pragma mark Cash Challenge Methods

- (void)requestCashChallenge:(void(^)(NSDictionary *))handler filters:(NSString*)filters
{
    if ( self.hasConnection ) {
        [self httpPost:APICashChallengeCreateURL params:@{@"filters":filters} isBlocking:NO handler:[^(NSDictionary *responseDict) {
            handler(responseDict);
        } copy]];
    } else {
        handler(_NO_CONNECTION_RESPONSE_DICT);
    }
}

- (void)acceptCashChallenge:(void(^)(NSDictionary *))handler challengeId:(NSString*)challengeId
{
    if ( self.hasConnection ) {
        NSString *url = [NSString stringWithFormat:@"%@%@%@", APICashChallengeBaseURL, challengeId, APICashChallengeAcceptURLPart2];
        [self httpPost:url params:nil isBlocking:NO handler:[^(NSDictionary *responseDict) {
            handler(responseDict);
        } copy]];
    } else {
        handler(_NO_CONNECTION_RESPONSE_DICT);
    }
}

- (void)rejectCashChallenge:(void(^)(NSDictionary *))handler challengeId:(NSString*)challengeId
{
    if ( self.hasConnection ) {
        NSString *url = [NSString stringWithFormat:@"%@%@%@", APICashChallengeBaseURL, challengeId, APICashChallengeRejectURLPart2];
        [self httpPost:url params:nil isBlocking:NO handler:[^(NSDictionary *responseDict) {
            handler(responseDict);
        } copy]];
    } else {
        handler(_NO_CONNECTION_RESPONSE_DICT);
    }
}

- (void)reportScoreForChallenge:(void (^)(NSDictionary *))handler challengeId:(NSString *)challengeId score:(NSString *)score
{
    if ( self.hasConnection ) {
        NSString *url = [NSString stringWithFormat:@"%@%@%@", APICashChallengeBaseURL, challengeId, APICashChallengeReportURLPart2];
        [self httpPost:url params:@{@"score": score} isBlocking:NO handler:[^(NSDictionary *responseDict) {
            handler(responseDict);
        } copy]];
    } else {
        handler(_NO_CONNECTION_RESPONSE_DICT);
    }
}

- (void)showCashChallengeRules:(void (^)(void))handler challengeId:(NSString *)challengeId
{
    ARBCashChallengeOfficialRules *view = [[ARBCashChallengeOfficialRules alloc] initWithChallengeId:challengeId arbiterInstance:self];
    view.callback = handler;
    [self.panelWindow show:view];
}


#pragma mark Utility Helper Methods

- (bool)isSuccessfulResponse:(NSDictionary*)response {
    NSNumber* successObj = [response objectForKey:@"success"];
    return successObj != nil && [successObj boolValue] == YES;
}

-(NSString*) sha1:(NSString*)str
{
    const char *cstr = [str cStringUsingEncoding:NSUTF8StringEncoding];
    NSData *data = [NSData dataWithBytes:cstr length:str.length];
 
    uint8_t digest[CC_SHA1_DIGEST_LENGTH];
    CC_SHA1(data.bytes, data.length, digest);
 
    NSMutableString* hash = [NSMutableString stringWithCapacity:CC_SHA1_DIGEST_LENGTH * 2];
 
    for(int i = 0; i < CC_SHA1_DIGEST_LENGTH; i++)
        [hash appendFormat:@"%02x", digest[i]];
 
    return hash;
}

- (NSString*)formattedAuthHeaderForToken:(NSString*)authToken {
    NSString* tokenPrefix = @"";
    if (!IS_NULL_STRING(authToken)) {
        tokenPrefix = [NSString stringWithFormat:@"Token %@", authToken];
    }
    return [NSString stringWithFormat:@"%@::key:%@::did:%@", tokenPrefix, self.apiKey, self.deviceHash];
}


#pragma mark NSURLConnection Delegate Methods


- (void)httpGet:(NSString*)url isBlocking:(BOOL)isBlocking handler:(void(^)(NSDictionary*))handler
{
    [self httpGet:url params:nil authTokenOverride:[self.user objectForKey:USER_TOKEN] isBlocking:isBlocking handler:handler];
}
- (void)httpGet:(NSString*)url params:(NSDictionary*)params isBlocking:(BOOL)isBlocking handler:(void(^)(NSDictionary*))handler
{
    [self httpGet:url params:params authTokenOverride:[self.user objectForKey:USER_TOKEN] isBlocking:isBlocking handler:handler];
}

- (void)httpGet:(NSString*)url params:(NSDictionary*)params authTokenOverride:(NSString*)authTokenOverride isBlocking:(BOOL)isBlocking handler:(void(^)(NSDictionary*))handler
{
    NSMutableString *urlParams = [[NSMutableString alloc] initWithString:@""];
    if( params != nil ) {
        [urlParams appendString:@"?"];
        [params enumerateKeysAndObjectsUsingBlock: ^(NSString *key, NSString *value, BOOL *stop) {
            [urlParams appendString:[NSString stringWithFormat:@"%@=%@", key, value]];
        }];
    }

    NSString *authHeader = [self formattedAuthHeaderForToken:authTokenOverride];

    NSString *fullUrl = [NSString stringWithFormat:@"%@%@", url, urlParams];
    NSLog( @"ArbiterSDK GET %@", fullUrl );
    NSMutableURLRequest *request = [NSMutableURLRequest
                                    requestWithURL:[NSURL URLWithString:fullUrl]
                                    cachePolicy:NSURLRequestUseProtocolCachePolicy
                                    timeoutInterval:60.0];
    
    [request setHTTPShouldHandleCookies:NO];
    [request setValue:authHeader forHTTPHeaderField:@"Authorization"];
    NSString *key = [fullUrl stringByAppendingString:@":GET"];
    [_connectionHandlerRegistry setObject:handler forKey:key];
    if ( isBlocking ) {
        [self addRequestToQueue:key];
    }
    
    [NSURLConnection connectionWithRequest:request delegate:self];
}

-(void)httpPost:(NSString*)url params:(NSDictionary*)params isBlocking:(BOOL)isBlocking handler:(void(^)(NSDictionary*))handler
{
    [self httpPost:url params:params authTokenOverride:[self.user objectForKey:USER_TOKEN] isBlocking:isBlocking handler:handler];
}
-(void)httpPost:(NSString*)url params:(NSDictionary*)params authTokenOverride:(NSString*)authTokenOverride isBlocking:(BOOL)isBlocking handler:(void(^)(NSDictionary*))handler
{
    NSLog( @"ArbiterSDK POST %@", url );
    NSError *error = nil;
    NSData *paramsData;
    NSString *paramsStr;
    NSString *key = [url stringByAppendingString:@":POST"];
    
    if( params == nil ) {
        params = @{};
    }
    paramsData = [NSJSONSerialization dataWithJSONObject:params
                                                 options:0
                                                   error:&error];
    paramsStr = [[NSString alloc] initWithData:paramsData encoding:NSUTF8StringEncoding];

    NSString *authHeader = [self formattedAuthHeaderForToken:authTokenOverride];
    
    if( error != nil ) {
        NSLog(@"ERROR: %@", error);
        handler( @{
                   @"success": @"false",
                   @"errors": @[error]
                   });
    } else {
        NSMutableURLRequest *request = [NSMutableURLRequest
                                        requestWithURL:[NSURL URLWithString:url]
                                           cachePolicy:NSURLRequestUseProtocolCachePolicy
                                       timeoutInterval:60.0];
        
        [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
        [request setHTTPShouldHandleCookies:NO];
        [request setValue:authHeader forHTTPHeaderField:@"Authorization"];
        [request setHTTPMethod:@"POST"];
        [request setHTTPBody:[paramsStr dataUsingEncoding:NSUTF8StringEncoding]];
    
        if ( isBlocking ) {
            [self addRequestToQueue:key];
        }
        [_connectionHandlerRegistry setObject:handler forKey:key];
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
        [[UIApplication sharedApplication] beginIgnoringInteractionEvents];
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
        [[UIApplication sharedApplication] endIgnoringInteractionEvents];
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
    NSLog(@"Connection error from: %@", [[connection currentRequest] URL]);
    NSLog(@"Error:%@", error);
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

        void(^agreeHandler)(NSDictionary*) = [_alertViewHandlerRegistry objectForKey:@"agreedToTermsHandler"];

        // Agree
        if ( buttonIndex == 0 ) {
            [[ARBTracking arbiterInstance] track:@"Clicked Agree to Terms"];
            agreeHandler(@{@"success":@true});

        // View Terms
        } else if ( buttonIndex == 1 ) {
            [[ARBTracking arbiterInstance] track:@"Clicked View Terms"];
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://www.arbiter.me/terms/"]];
        }
        
        // Cancel
        if (buttonIndex == 2) {
            [[ARBTracking arbiterInstance] track:@"Clicked Cancel Terms"];
            agreeHandler(@{@"success": @"false", @"errors":@[@"User has canceled verification."]});
        }
        
    } else if ( alertView.tag == ENABLE_LOCATION_ALERT_TAG) {
        void (^handler)(NSDictionary *) = [_alertViewHandlerRegistry objectForKey:@"enableLocationServices"];
        [_alertViewHandlerRegistry removeObjectForKey:@"enableLocationServices"];
        
        if (buttonIndex == 1) {
            [[ARBTracking arbiterInstance] track:@"Clicked Check LS"];
            handler(@{@"success":@true});
        } else {
            [[ARBTracking arbiterInstance] track:@"Clicked Keep LS Disabled"];
            handler( @{@"success": @false, @"errors":@[@"Could not get device location."]});
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
        NSLog(@"Unrecognized alertView tag: %ld", (long)alertView.tag);
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

- (UIWindow*)getTopApplicationWindow
{
    UIApplication *clientApp = [UIApplication sharedApplication];
    NSArray *windows = [clientApp windows];
    UIWindow *topWindow = nil;
    
    if (windows && [windows count] > 0)
        topWindow = [[clientApp windows] objectAtIndex:0];
    
    return topWindow;
}

@end
