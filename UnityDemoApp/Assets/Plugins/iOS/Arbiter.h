//
//  Arbiter.h
//  Arbiter
//
//  Copyright (c) 2014 Arbiter. All rights reserved.
//

#import <CoreLocation/CoreLocation.h>

@interface Arbiter : NSObject<NSURLConnectionDelegate, UIAlertViewDelegate>
{
    NSMutableDictionary *_alertViewHandlerRegistry;
    NSMutableDictionary *_connectionHandlerRegistry;
    NSMutableDictionary *_responseDataRegistry;
    CLLocationManager *locationManager;
    CLLocation *currentLocation;
    
}

@property (strong, atomic) NSMutableDictionary *wallet;
@property (strong, atomic) NSMutableDictionary *user;
@property (copy) NSString *token;
@property (copy) NSString *apiKey;
@property (copy) NSString *verificationUrl;
@property (copy) NSString *nextPageTournamentsUrl;
@property (copy) NSString *previousPageTournamentsUrl;
@property (copy) NSString *nextPageIncompleteTournamentsUrl;
@property (copy) NSString *previousPageIncompleteTournamentsUrl;
@property (copy) NSString *currentIncompleteTournamentId;


- (id)init:(void(^)(NSDictionary *))handler apiKey:(NSString*)apiKey;
- (void)loginWithGameCenterPlayer:(void(^)(NSDictionary *))handler;
- (void)verifyUser:(void(^)(NSDictionary *))handler;
- (void)logout:(void(^)(NSDictionary *))handler;

- (void)getWallet:(void(^)(NSDictionary *))handler;
- (void)showWalletPanel:(void(^)(void))handler;
- (void)copyDepositAddressToClipboard;
- (void)getDevicePostalCode:(void(^)(NSString *))handler;

- (void)requestTournament:(void(^)(NSDictionary *))handler buyIn:(NSString*)buyIn;
- (void)getTournaments:(void(^)(NSDictionary*))handler page:(NSString *)page;
- (void)viewPreviousTournaments:(void(^)(void))handler page:(NSString *)page;

- (void)getIncompleteTournaments:(void(^)(NSDictionary *))handler page:(NSString *)page;
- (void)viewIncompleteTournaments:(void(^)(NSString *))handler page:(NSString *)page;

- (void)reportScore:(void(^)(NSDictionary *))handler tournamentId:(NSString*)tournamentId score:(NSString*)score;

@end
