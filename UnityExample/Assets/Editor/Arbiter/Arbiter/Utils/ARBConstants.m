//
//  ArbiterContants.m
//  
//
//  Created by Andy Zinsser on 6/25/14.
//
//
#import "ARBConstants.h"

NSString *const APIWalletURL = @"http://staging.arbiter.me/api/v1/wallet/";
NSString *const APIWalletDashboardWebViewURL = @"http://staging.arbiter.me/api/v1/wallet/webview/";
NSString *const APISendPromoCreditsURL = @"http://staging.arbiter.me/api/v1/promo-credits/send";
NSString *const APIUserLoginURL = @"http://staging.arbiter.me/api/v1/user/login";
NSString *const APIUserLogoutURL = @"http://staging.arbiter.me/api/v1/user/logout";
NSString *const APIUserLoginDevice = @"http://staging.arbiter.me/api/v1/user/login-by-device";
//ttt NSString *const APILinkWithGameCenterURL = @"http://staging.arbiter.me/api/v1/user/link-with-game-center";
NSString *const APIUserLoginGameCenterURL = @"http://staging.arbiter.me/api/v1/user/login-by-game-center";
NSString *const APIUserDetailsURL = @"http://staging.arbiter.me/api/v1/user/";
NSString *const APITournamentCreateURL = @"http://staging.arbiter.me/api/v1/tournament/create";
NSString *const APIRequestTournamentURL = @"http://staging.arbiter.me/api/v1/tournament";
NSString *const APITournamentBaseURL = @"http://staging.arbiter.me/api/v1/tournament/";
NSString *const APITournamentMarkAsViewed = @"http://staging.arbiter.me/api/v1/tournament/mark-as-viewed";
NSString *const APIReportScoreURLPart2 = @"/report-score/";

NSString *const APICashChallengeCreateURL = @"http://staging.arbiter.me/api/v1/score-challenge/create";
NSString *const APICashChallengeBaseURL = @"http://staging.arbiter.me/api/v1/score-challenge/";
NSString *const APICashChallengeRulesURL = @"http://staging.arbiter.me/api/v1/regulation/challenge-rules/";
NSString *const APICashChallengeAcceptURLPart2 = @"/accept";
NSString *const APICashChallengeRejectURLPart2 = @"/reject";
NSString *const APICashChallengeReportURLPart2 = @"/report-score";

NSString *const APIDepositURL = @"http://staging.arbiter.me/stripe/deposit";
NSString *const APIWithdrawURL = @"http://staging.arbiter.me/stripe/withdraw";

NSString *const GameSettingsURL = @"http://staging.arbiter.me/api/v1/games/";
NSString *const BundleURL = @"http://staging.arbiter.me/cashier/bundle";
NSString *const StripeTestPublishableKey = @"pk_test_1SQ84edElZEWoGqlR7XB9V5j";
NSString *const StripeLivePublishableKey = @"pk_live_VxZ9u3zgtCRtaDe62rQyMwuj";


NSString* const USER_TOKEN = @"token";
NSString* const DEFAULTS_USER_TOKEN = @"arbiter_user_token";