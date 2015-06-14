//
//  ArbiterContants.m
//  
//
//  Created by Andy Zinsser on 6/25/14.
//
//
#import "ARBConstants.h"

NSString *const APIWalletURL = @"http://192.168.1.14:5000/api/v1/wallet/";
NSString *const APIWalletDashboardWebViewURL = @"http://192.168.1.14:5000/api/v1/wallet/webview/";
NSString *const APIWalletDashboardWebViewDepositURL = @"http://192.168.1.14:5000/api/v1/wallet/webview/#/tab/deposit";
NSString *const APISendPromoCreditsURL = @"http://192.168.1.14:5000/api/v1/promo-credits/send";
NSString *const APIUserLoginURL = @"http://192.168.1.14:5000/api/v1/user/login";
NSString *const APIUserLogoutURL = @"http://192.168.1.14:5000/api/v1/user/logout";
NSString *const APIUserLoginDevice = @"http://192.168.1.14:5000/api/v1/user/login-by-device";
NSString *const APIUserLoginGameCenterURL = @"http://192.168.1.14:5000/api/v1/user/login-by-game-center";
NSString *const APIUserDetailsURL = @"http://192.168.1.14:5000/api/v1/user/";
NSString *const APITournamentCreateURL = @"http://192.168.1.14:5000/api/v1/tournament/create";
NSString *const APIRequestTournamentURL = @"http://192.168.1.14:5000/api/v1/tournament";
NSString *const APITournamentBaseURL = @"http://192.168.1.14:5000/api/v1/tournament/";
NSString *const APITournamentMarkAsViewed = @"http://192.168.1.14:5000/api/v1/tournament/mark-as-viewed";
NSString *const APIReportScoreURLPart2 = @"/report-score/";

NSString *const APICashChallengeCreateURL = @"http://192.168.1.14:5000/api/v1/score-challenge/create";
NSString *const APICashChallengeBaseURL = @"http://192.168.1.14:5000/api/v1/score-challenge/";
NSString *const APICashChallengeRulesURL = @"http://192.168.1.14:5000/api/v1/regulation/challenge-rules/";
NSString *const APICashChallengeAcceptURLPart2 = @"/accept";
NSString *const APICashChallengeRejectURLPart2 = @"/reject";
NSString *const APICashChallengeReportURLPart2 = @"/report-score";

NSString *const APIDepositURL = @"http://192.168.1.14:5000/stripe/deposit";
NSString *const APIWithdrawURL = @"http://192.168.1.14:5000/stripe/withdraw";

NSString *const GameSettingsURL = @"http://192.168.1.14:5000/api/v1/games/";
NSString *const BundleURL = @"http://192.168.1.14:5000/cashier/bundle";
NSString *const StripeTestPublishableKey = @"pk_test_1SQ84edElZEWoGqlR7XB9V5j";
NSString *const StripeLivePublishableKey = @"pk_live_VxZ9u3zgtCRtaDe62rQyMwuj";


NSString* const USER_TOKEN = @"token";
NSString* const DEFAULTS_USER_TOKEN = @"arbiter_user_token";
NSString* const DEPOSIT_TAB = @"deposit";

extern int const UNKNOWN = 0;
extern int const CONNECTED = 1;
extern int const NOT_CONNECTED = -1;