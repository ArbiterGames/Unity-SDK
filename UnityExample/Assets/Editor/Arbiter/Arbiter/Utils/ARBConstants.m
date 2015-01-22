//
//  ArbiterContants.m
//  
//
//  Created by Andy Zinsser on 6/25/14.
//
//
#import "ARBConstants.h"

NSString *const APIUserInitializeURL = @"https://staging.arbiter.me/api/v1/user/initialize";
NSString *const APIWalletURL = @"https://staging.arbiter.me/api/v1/wallet/";
NSString *const APIWalletDashboardWebViewURL = @"https://staging.arbiter.me/api/v1/wallet/webview/";
NSString *const APISendPromoCreditsURL = @"https://staging.arbiter.me/api/v1/promo-credits/send";
NSString *const APIUserLoginURL = @"https://staging.arbiter.me/api/v1/user/login";
NSString *const APIUserLogoutURL = @"https://staging.arbiter.me/api/v1/user/logout";
NSString *const APILinkWithGameCenterURL = @"https://staging.arbiter.me/api/v1/user/link-with-game-center";
NSString *const APIUserDetailsURL = @"https://staging.arbiter.me/api/v1/user/";
NSString *const APITournamentCreateURL = @"https://staging.arbiter.me/api/v1/tournament/create";
NSString *const APIRequestTournamentURL = @"https://staging.arbiter.me/api/v1/tournament";
NSString *const APITournamentBaseURL = @"https://staging.arbiter.me/api/v1/tournament/";
NSString *const APITournamentMarkAsViewed = @"https://staging.arbiter.me/api/v1/tournament/mark-as-viewed";
NSString *const APIReportScoreURLPart2 = @"/report-score/";

NSString *const APICashChallengeCreateURL = @"https://staging.arbiter.me/api/v1/score-challenge/create";
NSString *const APICashChallengeBaseURL = @"https://staging.arbiter.me/api/v1/score-challenge/";
NSString *const APICashChallengeRulesURL = @"https://staging.arbiter.me/api/v1/regulation/challenge-rules/";
NSString *const APICashChallengeAcceptURLPart2 = @"/accept";
NSString *const APICashChallengeRejectURLPart2 = @"/reject";
NSString *const APICashChallengeReportURLPart2 = @"/report-score";

NSString *const APIDepositURL = @"https://staging.arbiter.me/stripe/deposit";
NSString *const APIWithdrawURL = @"https://staging.arbiter.me/stripe/withdraw";

NSString *const GameSettingsURL = @"https://staging.arbiter.me/api/v1/games/";
NSString *const BundleURL = @"https://staging.arbiter.me/cashier/bundle";
NSString *const StripeTestPublishableKey = @"pk_test_1SQ84edElZEWoGqlR7XB9V5j";
NSString *const StripeLivePublishableKey = @"pk_live_VxZ9u3zgtCRtaDe62rQyMwuj";


NSString* const USER_TOKEN = @"token";
NSString* const DEFAULTS_USER_TOKEN = @"arbiter_user_token";