//
//  ArbiterContants.m
//  
//
//  Created by Andy Zinsser on 6/25/14.
//
//
#import "ARBConstants.h"

NSString *const APIWalletURL = @"https://www.arbiter.me/api/v1/wallet/";
NSString *const APIWalletDashboardWebViewURL = @"https://www.arbiter.me/api/v1/wallet/webview/";
NSString *const APISendPromoCreditsURL = @"https://www.arbiter.me/api/v1/promo-credits/send";
NSString *const APIUserLoginURL = @"https://www.arbiter.me/api/v1/user/login";
NSString *const APIUserLogoutURL = @"https://www.arbiter.me/api/v1/user/logout";
NSString *const APIUserLoginDevice = @"https://www.arbiter.me/api/v1/user/login-by-device";
NSString *const APIUserLoginGameCenterURL = @"https://www.arbiter.me/api/v1/user/login-by-game-center";
NSString *const APIUserDetailsURL = @"https://www.arbiter.me/api/v1/user/";
NSString *const APITournamentCreateURL = @"https://www.arbiter.me/api/v1/tournament/create";
NSString *const APIRequestTournamentURL = @"https://www.arbiter.me/api/v1/tournament";
NSString *const APITournamentBaseURL = @"https://www.arbiter.me/api/v1/tournament/";
NSString *const APITournamentMarkAsViewed = @"https://www.arbiter.me/api/v1/tournament/mark-as-viewed";
NSString *const APIReportScoreURLPart2 = @"/report-score/";

NSString *const APICashChallengeCreateURL = @"https://www.arbiter.me/api/v1/score-challenge/create";
NSString *const APICashChallengeBaseURL = @"https://www.arbiter.me/api/v1/score-challenge/";
NSString *const APICashChallengeRulesURL = @"https://www.arbiter.me/api/v1/regulation/challenge-rules/";
NSString *const APICashChallengeAcceptURLPart2 = @"/accept";
NSString *const APICashChallengeRejectURLPart2 = @"/reject";
NSString *const APICashChallengeReportURLPart2 = @"/report-score";

NSString *const APIDepositURL = @"https://www.arbiter.me/stripe/deposit";
NSString *const APIWithdrawURL = @"https://www.arbiter.me/stripe/withdraw";

NSString *const GameSettingsURL = @"https://www.arbiter.me/api/v1/games/";
NSString *const BundleURL = @"https://www.arbiter.me/cashier/bundle";
NSString *const StripeTestPublishableKey = @"pk_test_1SQ84edElZEWoGqlR7XB9V5j";
NSString *const StripeLivePublishableKey = @"pk_live_VxZ9u3zgtCRtaDe62rQyMwuj";


NSString* const USER_TOKEN = @"token";
NSString* const DEFAULTS_USER_TOKEN = @"arbiter_user_token";