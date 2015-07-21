/* ttt
#import <CoreLocation/CoreLocation.h>
#import "ARBPanelWindow.h"
#import "ARBWalletObserver.h"
*/
void ClientCallbackUserUpdated();
void ClientCallbackWalletUpdated();

//@interface Arbiter : NSObject<NSURLConnectionDelegate, UIAlertViewDelegate, CLLocationManagerDelegate>
@interface Arbiter : NSObject<NSURLConnectionDelegate>

@property (atomic) int connectionStatus;
@property BOOL isWalletDashboardWebViewEnabled;
@property (strong, atomic) NSDictionary *game;
@property (copy) NSString *accessToken;
@property (copy) NSString *apiKey;
//ttt @property (retain) ARBPanelWindow *panelWindow;
@property (strong) UIActivityIndicatorView *spinnerView;
@property (strong) NSMutableDictionary *requestQueue;
@property (copy) NSString *verificationUrl;
@property (copy) NSString *nextPageTournamentsUrl;
@property (copy) NSString *previousPageTournamentsUrl;
@property (copy) NSString *nextPageIncompleteTournamentsUrl;
@property (copy) NSString *previousPageIncompleteTournamentsUrl;
@property int previousTournamentsCount;
@property int locationVerificationAttempts;
@property (copy) NSString *currentIncompleteTournamentId;
//ttt @property (strong, atomic) id<ARBWalletObserver> walletObserver;


@property (strong, atomic) NSString* _deviceHash;
- (NSString*)deviceHash;

@property (strong, atomic) NSMutableDictionary* _user;
- (void)setUser:(NSMutableDictionary *)user;
- (NSMutableDictionary *)user;
- (void)saveUserToken:(NSMutableDictionary *)user;

@property (strong, atomic) NSMutableDictionary* _wallet;
- (void)setWallet:(NSMutableDictionary *)wallet;
- (NSMutableDictionary *)wallet;

- (void)showNativeAlertMessage:(void(^)(void))callback title:(NSString *)title message:(NSString *)message;

+ (Arbiter *)sharedInstance;
+ (bool)isInitialized;
+ (Arbiter *)initWithApiKey:(NSString *)apiKey accessToken:(NSString *)accessToken handler:(void(^)(NSDictionary *))handler;
- (id)init:(void(^)(NSDictionary *))handler apiKey:(NSString *)apiKey accessToken:(NSString *)accessToken;
- (void)loginWithDevice:(void(^)(NSDictionary *))handler;
- (void)loginWithGameCenterPlayer:(void(^)(NSDictionary *))handler;
- (void)login:(void(^)(NSDictionary *))handler;
- (void)logout:(void(^)(NSDictionary *))handler;
- (bool)isUserAuthenticated;
- (bool)isUserVerified;
- (bool)isUserAuthenticated;
- (bool)hydrateUserWithCachedToken;
- (void)verifyUser:(void(^)(NSDictionary *))handler;
- (void)verifyUser:(void(^)(NSDictionary *))handler tryToGetLatLong:(BOOL)tryToGetLatLong;
- (void)getCachedUser:(void(^)(NSDictionary *))handler;

- (void)getCachedUser:(void(^)(NSDictionary *))handler;
- (void)getCachedWallet:(void(^)(NSDictionary *))handler;
- (void)fetchWallet:(void(^)(NSDictionary *))handler isBlocking:(BOOL)isBlocking;
- (void)getCachedWallet:(void(^)(NSDictionary *))handler;
//ttt - (void)addWalletObserver:(id<ARBWalletObserver>)observer;
- (void)showWalletPanel:(void(^)(void))handler onTab:(NSString *)tab;
- (void)showWalletPanel:(void(^)(void))handler;
- (void)sendPromoCredits:(void(^)(NSDictionary *))handler amount:(NSString *)amount;
- (void)getDeviceLocation:(void(^)(NSDictionary *))handler requireLatLong:(BOOL)requireLatLong;

- (void)requestTournament:(void(^)(NSDictionary *))handler buyIn:(NSString *)buyIn filters:(NSString *)filters;
- (void)fetchTournaments:(void(^)(NSDictionary*))handler page:(NSString *)page isBlocking:(BOOL)isBlocking excludeViewed:(BOOL)excludeViewed;
- (void)showPreviousTournaments:(void(^)(void))handler page:(NSString *)page excludeViewed:(BOOL)excludeViewed;
- (void)fetchIncompleteTournaments:(void(^)(NSDictionary *))handler page:(NSString *)page isBlocking:(BOOL)isBlocking;
- (void)showIncompleteTournaments:(void(^)(NSString *))handler page:(NSString *)page;
- (void)reportScore:(void(^)(NSDictionary *))handler tournamentId:(NSString*)tournamentId score:(NSString*)score;
- (void)markViewedTournament:(void(^)(void))handler tournamentIds:(NSMutableArray*)tournamentIds;

- (void)requestCashChallenge:(void(^)(NSDictionary *))handler filters:(NSString*)filters;
- (void)acceptCashChallenge:(void(^)(NSDictionary *))handler challengeId:(NSString*)challengeId;
- (void)rejectCashChallenge:(void(^)(NSDictionary *))handler challengeId:(NSString*)challengeId;
- (void)reportScoreForChallenge:(void(^)(NSDictionary *))handler challengeId:(NSString*)challengeId score:(NSString*)score;
- (void)showCashChallengeRules:(void(^)(void))handler challengeId:(NSString*)challengeId;

- (void)showWalkThrough:(void(^)(void))handler walkThroughId:(NSString*)walkThroughId;
- (void)showTournamentDetailsPanel:(void(^)(void))handler tournamentId:(NSString *)tournamentId;

- (bool)hasConnection:(void(^)(NSDictionary*))handler;
- (NSMutableURLRequest*)makeHttpRequest:(NSString*)url authTokenOverride:(NSString*)authTokenOverride;
- (void)doHttpCall:(NSURLRequest*)request key:(NSString*)key isBlocking:(BOOL)isBlocking handler:(void(^)(NSDictionary*))handler;
- (void)httpGet:(NSString*)url isBlocking:(BOOL)isBlocking handler:(void(^)(NSDictionary*))handler;
- (void)httpGet:(NSString*)url params:(NSDictionary*)params authTokenOverride:(NSString*)authTokenOverride isBlocking:(BOOL)isBlocking handler:(void(^)(NSDictionary*))handler;
- (void)httpPost:(NSString*)url params:(NSDictionary*)params isBlocking:(BOOL)isBlocking handler:(void(^)(NSDictionary*))handler;
- (void)httpPost:(NSString*)url params:(NSDictionary*)params authTokenOverride:(NSString*)authTokenOverrde isBlocking:(BOOL)isBlocking handler:(void(^)(NSDictionary*))handler;
- (bool)isSuccessfulResponse:(NSDictionary*)response;
- (void)addRequestToQueue:(NSString *)key;
- (void)removeRequestFromQueue:(NSString *)key;

- (NSString*)getPlayerScoreFromTournament:(NSDictionary *)tournament;
- (NSString*)getOpponentScoreFromTournament:(NSDictionary *)tournament;

- (NSDictionary*)getCurrentUserFromTournament:(NSDictionary *)tournament;
- (NSDictionary*)getOpponentFromTournament:(NSDictionary *)tournament;

@end
