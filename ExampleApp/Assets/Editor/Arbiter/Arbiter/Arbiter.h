//
//  Arbiter.h
//  Arbiter
//
//  Copyright (c) 2014 Arbiter. All rights reserved.
//

#import <CoreLocation/CoreLocation.h>
#import "ArbiterPanelWindow.h"

void ClientCallbackUserUpdated();
void ClientCallbackWalletUpdated();

@interface Arbiter : NSObject<NSURLConnectionDelegate, UIAlertViewDelegate, CLLocationManagerDelegate>

@property (strong, atomic) NSDictionary *game;
@property (copy) NSString *accessToken;
@property (copy) NSString *apiKey;
@property (retain) ArbiterPanelWindow *panelWindow;
@property (strong) UIActivityIndicatorView *spinnerView;
@property (strong) NSMutableDictionary *requestQueue;
@property (copy) NSString *verificationUrl;
@property (copy) NSString *nextPageTournamentsUrl;
@property (copy) NSString *previousPageTournamentsUrl;
@property (copy) NSString *nextPageIncompleteTournamentsUrl;
@property (copy) NSString *previousPageIncompleteTournamentsUrl;
@property int previousTournamentsCount;
@property (copy) NSString *currentIncompleteTournamentId;

@property (strong, atomic) NSMutableDictionary* _user;
- (void)setUser:(NSMutableDictionary *)user;
- (NSMutableDictionary *)user;

@property (strong, atomic) NSMutableDictionary* _wallet;
- (void)setWallet:(NSMutableDictionary *)wallet;
- (NSMutableDictionary *)wallet;

- (id)init:(void(^)(NSDictionary *))handler apiKey:(NSString *)apiKey accessToken:(NSString *)accessToken;
- (void)loginAsAnonymous:(void(^)(NSDictionary *))handler;
- (void)loginWithGameCenterPlayer:(void(^)(NSDictionary *))handler;
- (void)login:(void(^)(NSDictionary *))handler;
- (void)logout:(void(^)(NSDictionary *))handler;
- (bool)isUserAuthenticated;
- (bool)isUserVerified;
- (bool)isUserAuthenticated;
- (void)verifyUser:(void(^)(NSDictionary *))handler;
- (void)getCachedUser:(void(^)(NSDictionary *))handler;

- (void)getCachedUser:(void(^)(NSDictionary *))handler;
- (void)getCachedWallet:(void(^)(NSDictionary *))handler;
- (void)fetchWallet:(void(^)(NSDictionary *))handler isBlocking:(BOOL)isBlocking;
- (void)getCachedWallet:(void(^)(NSDictionary *))handler;
- (void)showWalletPanel:(void(^)(void))handler;
- (void)sendPromoCredits:(void(^)(NSDictionary *))handler amount:(NSString *)amount;
- (void)getDevicePostalCode:(void(^)(NSDictionary *))handler;

- (void)requestTournament:(void(^)(NSDictionary *))handler buyIn:(NSString *)buyIn filters:(NSString *)filters;
- (void)fetchTournaments:(void(^)(NSDictionary*))handler page:(NSString *)page isBlocking:(BOOL)isBlocking excludeViewed:(BOOL)exludeViewed;
- (void)showPreviousTournaments:(void(^)(void))handler page:(NSString *)page;

- (void)fetchIncompleteTournaments:(void(^)(NSDictionary *))handler page:(NSString *)page isBlocking:(BOOL)isBlocking;
- (void)showIncompleteTournaments:(void(^)(NSString *))handler page:(NSString *)page;

- (void)reportScore:(void(^)(NSDictionary *))handler tournamentId:(NSString*)tournamentId score:(NSString*)score;
- (void)markViewedTournament:(void(^)(NSDictionary *))handler tournamentId:(NSString*)tournamentId;
- (void)showTournamentDetailsPanel:(void(^)(void))handler tournamentId:(NSString *)tournamentId;

- (void)httpGet:(NSString*)url isBlocking:(BOOL)isBlocking handler:(void(^)(NSDictionary*))handler;
- (void)httpPost:(NSString*)url params:(NSDictionary*)params isBlocking:(BOOL)isBlocking handler:(void(^)(NSDictionary*))handler;
- (void)httpPostAsDeveloper:(NSString*)url params:(NSDictionary*)params handler:(void(^)(NSDictionary*))handler;

- (void)addRequestToQueue:(NSString *)key;
- (void)removeRequestFromQueue:(NSString *)key;

- (NSString*)getPlayerScoreFromTournament:(NSDictionary *)tournament;
- (NSString*)getOpponentScoreFromTournament:(NSDictionary *)tournament;

- (NSDictionary*)getCurrentUserFromTournament:(NSDictionary *)tournament;
- (NSDictionary*)getOpponentFromTournament:(NSDictionary *)tournament;

@end
