//
//  Arbiter.m
//  Arbiter
//
//  Copyright (c) 2014 Arbiter. All rights reserved.
//


#import "Arbiter.h"
#import "ARBLogger.h"


# pragma mark Utility Methods

char *AutonomousStringCopy(const char *string)
{
    if (string == NULL) {
        return NULL;
    }
    char *res = (char*)malloc(strlen(string) + 1);
    strcpy(res, string);
    return res;
}


const char* ProcessDictionaryParams( NSDictionary *jsonDict )
{
    if( jsonDict == nil ) {
        return AutonomousStringCopy([@"" UTF8String]);
    } else {
        NSError *error;
        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:jsonDict options:0 error:&error];
        NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
        const char *jsonChar = AutonomousStringCopy([jsonString UTF8String]);
        return jsonChar;
    }
}

NSMutableDictionary* JsonToDict( const char* jsonString )
{
    NSMutableDictionary* dict = [[NSMutableDictionary alloc] init];
    [dict setObject:[NSString stringWithFormat:@"%s", jsonString] forKey:@"game_data"];
    return dict;
}


# pragma mark Client Triggers Events

void ClientCallbackNewUser()
{
    [[Arbiter sharedInstance] getCachedUser:^(NSDictionary *jsonDict) {
        UnitySendMessage("ArbiterBinding", "OnNewUser", ProcessDictionaryParams( jsonDict ));
    }];
}
void ClientCallbackUserUpdated()
{
    [[Arbiter sharedInstance] getCachedUser:^(NSDictionary *jsonDict) {
        UnitySendMessage("ArbiterBinding", "OnUserUpdated", ProcessDictionaryParams( jsonDict ));
    }];
}
void ClientCallbackWalletUpdated()
{
    [[Arbiter sharedInstance] getCachedWallet:^(NSDictionary *jsonDict) {
        UnitySendMessage("ArbiterBinding", "OnWalletUpdated", ProcessDictionaryParams( jsonDict ));
    }];
}


# pragma mark Arbiter Class Wrapper Methods

void _init( const char *apiKey, const char *accessToken )
{
    [Arbiter initWithApiKey:[[NSString alloc] initWithUTF8String:apiKey]
                accessToken:[[NSString alloc] initWithUTF8String:accessToken]
                    handler:^(NSDictionary *jsonDict) {
        UnitySendMessage("ArbiterBinding", "InitHandler", ProcessDictionaryParams( jsonDict ));
    }];
}

void _loginWithDeviceId()
{
    [[Arbiter sharedInstance] loginWithDevice:^(NSDictionary *jsonDict) {
        UnitySendMessage("ArbiterBinding", "LoginWithDeviceIdHandler", ProcessDictionaryParams( jsonDict ));
    }];
}

void _loginWithGameCenterPlayer()
{
    [[Arbiter sharedInstance] loginWithGameCenterPlayer:^(NSDictionary *jsonDict) {
        UnitySendMessage("ArbiterBinding", "LoginWithGameCenterHandler", ProcessDictionaryParams( jsonDict ));
    }];
}

void _login()
{
    [[Arbiter sharedInstance] login:^(NSDictionary *jsonDict) {
        UnitySendMessage( "ArbiterBinding", "LoginHandler", ProcessDictionaryParams( jsonDict ) );
    }];
}

void _logout()
{
    [[Arbiter sharedInstance] logout:^(NSDictionary *jsonDict) {
        UnitySendMessage( "ArbiterBinding", "LogoutHandler", AutonomousStringCopy([@"" UTF8String]) );
    }];
}

bool _isUserAuthenticated()
{
    return [[Arbiter sharedInstance] isUserAuthenticated];
}

void _verifyUser()
{
    [[Arbiter sharedInstance] verifyUser:^(NSDictionary *jsonDict) {
        UnitySendMessage("ArbiterBinding", "VerifyUserHandler", ProcessDictionaryParams( jsonDict ));
    }];
}

bool _isUserVerified()
{
    return [[Arbiter sharedInstance] isUserVerified];
}

void _fetchWallet()
{
    [[Arbiter sharedInstance] fetchWallet:^(NSDictionary *jsonDict) {
        UnitySendMessage("ArbiterBinding", "FetchWalletHandler", ProcessDictionaryParams( jsonDict ));
    } isBlocking:NO];
}


void _showWalletPanel()
{
    [[Arbiter sharedInstance] showWalletPanel:^{
        UnitySendMessage( "ArbiterBinding", "ShowWalletPanelHandler", AutonomousStringCopy([@"" UTF8String]) );
    }];
}

void _sendPromoCredits( const char *amount )
{
    [[Arbiter sharedInstance] sendPromoCredits:^(NSDictionary *jsonDict) {
        UnitySendMessage( "ArbiterBinding", "SendPromoCreditsHandler", ProcessDictionaryParams( jsonDict ) );
    } amount:[[NSString alloc] initWithUTF8String:amount]];
}

void _requestTournament( const char *buyIn, const char *filters )
{
    [[Arbiter sharedInstance] requestTournament:^(NSDictionary *jsonDict) {
        UnitySendMessage("ArbiterBinding", "RequestTournamentHandler", ProcessDictionaryParams( jsonDict ) );
    } buyIn:[[NSString alloc] initWithUTF8String:buyIn] filters:[[NSString alloc] initWithUTF8String:filters]];
}

void _fetchTournaments()
{
    [[Arbiter sharedInstance] fetchTournaments:^(NSDictionary *jsonDict) {
        UnitySendMessage("ArbiterBinding", "FetchTournamentsHandler", ProcessDictionaryParams( jsonDict ));
    } page:nil isBlocking:NO excludeViewed:NO];
}

void _fetchUnviewedTournaments()
{
    [[Arbiter sharedInstance] fetchTournaments:^(NSDictionary *jsonDict) {
        UnitySendMessage("ArbiterBinding", "FetchUnviewedTournamentsHandler", ProcessDictionaryParams( jsonDict ));
    } page:nil isBlocking:NO excludeViewed:YES];
}

void _showPreviousTournaments()
{
    [[Arbiter sharedInstance] showPreviousTournaments:^{
        UnitySendMessage("ArbiterBinding", "ShowPreviousTournamentsHandler", AutonomousStringCopy([@"" UTF8String]) );
    } page:nil excludeViewed:NO];
}

void _showUnviewedTournaments()
{
    [[Arbiter sharedInstance] showPreviousTournaments:^{
        UnitySendMessage("ArbiterBinding", "ShowUnviewedTournamentsHandler", AutonomousStringCopy([@"" UTF8String]) );
    } page:nil excludeViewed:YES];
}

void _showIncompleteTournaments()
{
    [[Arbiter sharedInstance] showIncompleteTournaments:^(NSString *tournamentId) {
        UnitySendMessage("ArbiterBinding", "ShowIncompleteTournamentsHandler", AutonomousStringCopy([tournamentId UTF8String]) );
    } page:nil];
}

void _reportScore( const char *tournamentId, const char *score )
{
    [[Arbiter sharedInstance] reportScore:^(NSDictionary *jsonDict) {
        UnitySendMessage("ArbiterBinding", "ReportScoreHandler", ProcessDictionaryParams( jsonDict ) );
    } tournamentId:[[NSString alloc] initWithUTF8String:tournamentId] score:[[NSString alloc] initWithUTF8String:score]];
}

void _requestCashChallenge( const char *filters )
{
    [[Arbiter sharedInstance] requestCashChallenge:^(NSDictionary *jsonDict) {
        UnitySendMessage("ArbiterBinding", "RequestCashChallengeHandler", ProcessDictionaryParams( jsonDict ) );
    } filters:[[NSString alloc] initWithUTF8String:filters]];
}

void _acceptCashChallenge( const char *challengeId )
{
    [[Arbiter sharedInstance] acceptCashChallenge:^(NSDictionary *jsonDict) {
        UnitySendMessage("ArbiterBinding", "AcceptCashChallengeHandler", ProcessDictionaryParams( jsonDict ) );
    } challengeId:[[NSString alloc] initWithUTF8String:challengeId]];
}

void _rejectCashChallenge( const char *challengeId )
{
    [[Arbiter sharedInstance] rejectCashChallenge:^(NSDictionary *jsonDict) {
        UnitySendMessage("ArbiterBinding", "RejectCashChallengeHandler", ProcessDictionaryParams( jsonDict ) );
    } challengeId:[[NSString alloc] initWithUTF8String:challengeId]];
}

void _reportScoreForChallenge( const char *challengeId, const char *score )
{
    [[Arbiter sharedInstance] reportScoreForChallenge:^(NSDictionary *jsonDict) {
        UnitySendMessage("ArbiterBinding", "ReportScoreForChallengeHandler", ProcessDictionaryParams( jsonDict ) );
    } challengeId:[[NSString alloc] initWithUTF8String:challengeId] score:[[NSString alloc] initWithUTF8String:score]];
}

void _showCashChallengeRules( const char* challengeId )
{
    [[Arbiter sharedInstance] showCashChallengeRules:^{
        UnitySendMessage("ArbiterBinding", "ShowCashChallengeRulesHandler", AutonomousStringCopy([@"" UTF8String]) );
    } challengeId:[[NSString alloc] initWithUTF8String:challengeId]];
}

void _showWalkThrough( const char* walkThroughId )
{
    [[Arbiter sharedInstance] showWalkThrough:^{
        UnitySendMessage("ArbiterBinding", "ShowWalkThroughHandler", AutonomousStringCopy([@"" UTF8String]) );
    } walkThroughId:[[NSString alloc] initWithUTF8String:walkThroughId]];
}

void _showTournamentDetailsPanel( const char *tournamentId )
{
    [[Arbiter sharedInstance] showTournamentDetailsPanel:^{
        UnitySendMessage("ArbiterBinding", "ShowTournamentDetailsPanelHandler", AutonomousStringCopy([@"" UTF8String]) );
    } tournamentId:[[NSString alloc] initWithUTF8String:tournamentId]];
}


void _dumpLogs( const char *jsonData ) 
{
     [[ARBLogger sharedManager] reportLog:JsonToDict(jsonData) arbiterState:[Arbiter sharedInstance]];
}
