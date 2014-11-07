//
//  ArbiterContants.h
//  
//
//  Created by Andy Zinsser on 6/25/14.
//
//


#define IS_NULL_NS(value) (value == nil || value == (id)[NSNull null] || ([value isKindOfClass:[NSString class]] && ([value isEqualToString:@""] || [value isEqualToString:@"<null>"]))) ? YES : NO

extern NSString *const APIUserInitializeURL;
extern NSString *const APIWalletURL;
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

extern NSString *const APIScoreChallengeCreateURL;
extern NSString *const APIScoreChallengeBaseURL;
extern NSString *const APIScoreChallengeRulesURL;
extern NSString *const APIScoreChallengeAcceptURLPart2;
extern NSString *const APIScoreChallengeRejectURLPart2;
extern NSString *const APIScoreChallengeReportURLPart2;

extern NSString *const APIDepositURL;
extern NSString *const APIWithdrawURL;

extern NSString *const GameSettingsURL;
extern NSString *const BundleURL;
extern NSString *const StripeTestPublishableKey;
extern NSString *const StripeLivePublishableKey;