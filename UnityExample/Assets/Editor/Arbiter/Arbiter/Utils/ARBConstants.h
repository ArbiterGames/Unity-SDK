//
//  ArbiterContants.h
//  
//
//  Created by Andy Zinsser on 6/25/14.
//
//


#define IS_NULL_STRING(value) (value == nil || value == (id)[NSNull null] || ([value isKindOfClass:[NSString class]] && ([value isEqualToString:@""] || [value isEqualToString:@"<null>"]))) ? YES : NO

extern NSString *const APIUserInitializeURL;
extern NSString *const APIWalletURL;
extern NSString *const APIWalletDashboardWebViewURL;
extern NSString *const APISendPromoCreditsURL;
extern NSString *const APIUserLoginURL;
extern NSString *const APIUserLogoutURL;
extern NSString *const APILinkWithGameCenterURL;
extern NSString *const APIUserDetailsURL;
extern NSString *const APITournamentCreateURL;
extern NSString *const APIRequestTournamentURL;
extern NSString *const APITournamentBaseURL;
extern NSString *const APITournamentMarkAsViewed;
extern NSString *const APIReportScoreURLPart2;

extern NSString *const APICashChallengeCreateURL;
extern NSString *const APICashChallengeBaseURL;
extern NSString *const APICashChallengeRulesURL;
extern NSString *const APICashChallengeAcceptURLPart2;
extern NSString *const APICashChallengeRejectURLPart2;
extern NSString *const APICashChallengeReportURLPart2;

extern NSString *const APIDepositURL;
extern NSString *const APIWithdrawURL;

extern NSString *const GameSettingsURL;
extern NSString *const BundleURL;
extern NSString *const StripeTestPublishableKey;
extern NSString *const StripeLivePublishableKey;

extern NSString* const USER_TOKEN;
extern NSString* const DEFAULTS_USER_TOKEN;