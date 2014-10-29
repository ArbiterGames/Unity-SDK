//
//  Arbiter.m
//  Arbiter
//
//  Copyright (c) 2014 Arbiter. All rights reserved.
//


#import "Arbiter.h"
#import "ArbiterLogger.h"


Arbiter* _arbiter = nil;
Arbiter* ArbiterInstance()
{
    if (_arbiter == nil) {
        NSLog(@"Arbiter Error: Missing Game API Key and Access Token. Make sure you have added the Arbiter Prefab to your loading scene and that you have entered your Game API Key and Access Token to the Arbiter Game Object using the Unity Inspector.");
    }
    return _arbiter;
}

char *AutonomousStringCopy(const char *string)
{
    if (string == NULL)
        return NULL;
    
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


void ClientCallbackNewUser()
{
    [ArbiterInstance() getCachedUser:^(NSDictionary *jsonDict) {
        UnitySendMessage("ArbiterBinding", "OnNewUser", ProcessDictionaryParams( jsonDict ));
    }];
}
void ClientCallbackUserUpdated()
{
    [ArbiterInstance() getCachedUser:^(NSDictionary *jsonDict) {
        UnitySendMessage("ArbiterBinding", "OnUserUpdated", ProcessDictionaryParams( jsonDict ));
    }];
}
void ClientCallbackWalletUpdated()
{
    [ArbiterInstance() getCachedWallet:^(NSDictionary *jsonDict) {
        UnitySendMessage("ArbiterBinding", "OnWalletUpdated", ProcessDictionaryParams( jsonDict ));
    }];
}



void _init( const char *apiKey, const char *accessToken )
{
    _arbiter = [[Arbiter alloc] init:^(NSDictionary *jsonDict) {
            UnitySendMessage("ArbiterBinding", "InitHandler", ProcessDictionaryParams( jsonDict ));
        }
               apiKey:[[NSString alloc] initWithUTF8String:apiKey]
          accessToken:[[NSString alloc] initWithUTF8String:accessToken]
    ];
}

void _loginAsAnonymous()
{
    [ArbiterInstance() loginAsAnonymous:^(NSDictionary *jsonDict) {
        UnitySendMessage("ArbiterBinding", "LoginAsAnonymousHandler", ProcessDictionaryParams( jsonDict ));
    }];
}

void _loginWithGameCenterPlayer()
{
    [ArbiterInstance() loginWithGameCenterPlayer:^(NSDictionary *jsonDict) {
        UnitySendMessage("ArbiterBinding", "LoginWithGameCenterHandler", ProcessDictionaryParams( jsonDict ));
    }];
}

void _login()
{
    [ArbiterInstance() login:^(NSDictionary *jsonDict) {
        UnitySendMessage( "ArbiterBinding", "LoginHandler", ProcessDictionaryParams( jsonDict ) );
    }];
}

void _logout()
{
    [ArbiterInstance() logout:^(NSDictionary *jsonDict) {
        UnitySendMessage( "ArbiterBinding", "LogoutHandler", AutonomousStringCopy([@"" UTF8String]) );
    }];
}

bool _isUserAuthenticated()
{
    return [ArbiterInstance() isUserAuthenticated];
}

void _verifyUser()
{
    [ArbiterInstance() verifyUser:^(NSDictionary *jsonDict) {
        UnitySendMessage("ArbiterBinding", "VerifyUserHandler", ProcessDictionaryParams( jsonDict ));
    }];
}

bool _isUserVerified()
{
    return [ArbiterInstance() isUserVerified];
}

void _fetchWallet()
{
    [ArbiterInstance() fetchWallet:^(NSDictionary *jsonDict) {
        UnitySendMessage("ArbiterBinding", "FetchWalletHandler", ProcessDictionaryParams( jsonDict ));
    } isBlocking:NO];
}


void _showWalletPanel()
{
    [ArbiterInstance() showWalletPanel:^(void) {
        UnitySendMessage( "ArbiterBinding", "ShowWalletPanelHandler", AutonomousStringCopy([@"" UTF8String]) );
    }];
}

void _sendPromoCredits( const char *amount )
{
    [ArbiterInstance() sendPromoCredits:^(NSDictionary *jsonDict) {
        UnitySendMessage( "ArbiterBinding", "SendPromoCreditsHandler", AutonomousStringCopy([@"" UTF8String]) );
    }
                       amount:[[NSString alloc] initWithUTF8String:amount]];
}

void _requestTournament( const char *buyIn, const char *filters )
{
    [ArbiterInstance() requestTournament:^(NSDictionary *jsonDict) {
        UnitySendMessage("ArbiterBinding", "RequestTournamentHandler", ProcessDictionaryParams( jsonDict ) );
    }
                         buyIn:[[NSString alloc] initWithUTF8String:buyIn]
                       filters:[[NSString alloc] initWithUTF8String:filters]
     ];
}

void _fetchTournaments()
{
    [ArbiterInstance() fetchTournaments:^(NSDictionary *jsonDict) {
        UnitySendMessage("ArbiterBinding", "FetchTournamentsHandler", ProcessDictionaryParams( jsonDict ));
    } page:nil isBlocking:NO excludeViewed:NO];
}

void _fetchUnviewedTournaments()
{
    [ArbiterInstance() fetchTournaments:^(NSDictionary *jsonDict) {
        UnitySendMessage("ArbiterBinding", "FetchUnviewedTournamentsHandler", ProcessDictionaryParams( jsonDict ));
    } page:nil isBlocking:NO excludeViewed:YES];
}

void _showPreviousTournaments()
{
    [ArbiterInstance() showPreviousTournaments:^(void) {
        UnitySendMessage("ArbiterBinding", "ShowPreviousTournamentsHandler", AutonomousStringCopy([@"" UTF8String]) );
    } page:nil excludeViewed:NO];
}

void _showUnviewedTournaments()
{
    [ArbiterInstance() showPreviousTournaments:^(void) {
        UnitySendMessage("ArbiterBinding", "ShowUnviewedTournamentsHandler", AutonomousStringCopy([@"" UTF8String]) );
    } page:nil excludeViewed:YES];
}

void _showIncompleteTournaments()
{
    [ArbiterInstance() showIncompleteTournaments:^(NSString *tournamentId) {
        UnitySendMessage("ArbiterBinding", "ShowIncompleteTournamentsHandler", AutonomousStringCopy([tournamentId UTF8String]) );
    } page:nil];
}

void _reportScore( const char *tournamentId, const char *score )
{
    [ArbiterInstance() reportScore:^(NSDictionary *jsonDict) {
        UnitySendMessage("ArbiterBinding", "ReportScoreHandler", ProcessDictionaryParams( jsonDict ) );
    } tournamentId:[[NSString alloc] initWithUTF8String:tournamentId] score:[[NSString alloc] initWithUTF8String:score]];
}

// TODO: This needs to accept an array of tournamentIds.
//       Commenting out for now and coming back to deal with this
//void _markViewedTournament( const char* tournamentId )
//{
//    [ArbiterInstance() markViewedTournament:^(NSDictionary *jsonDict) {
//        UnitySendMessage("ArbiterBinding", "MarkViewedTournamentHandler", ProcessDictionaryParams( jsonDict ) );
//    }
//            tournamentId:[[NSString alloc] initWithUTF8String:tournamentId]
//     ];
//}

void _requestScoreChallenge( const char *buyIn, const char *filters )
{
    [ArbiterInstance() requestScoreChallenge:^(NSDictionary *jsonDict) {
        UnitySendMessage("ArbiterBinding", "RequestScoreChallengeHandler", ProcessDictionaryParams( jsonDict ) );
    } entryFee:[[NSString alloc] initWithUTF8String:buyIn]];
}

void _acceptScoreChallenge( const char *challengeId )
{
    [ArbiterInstance() acceptScoreChallenge:^(NSDictionary *jsonDict) {
        UnitySendMessage("ArbiterBinding", "AcceptScoreChallengeHandler", ProcessDictionaryParams( jsonDict ) );
    } challengeId:[[NSString alloc] initWithUTF8String:challengeId]];
}

void _rejectScoreChallenge( const char *challengeId )
{
    [ArbiterInstance() rejectScoreChallenge:^(NSDictionary *jsonDict) {
        UnitySendMessage("ArbiterBinding", "RejectScoreChallengeHandler", ProcessDictionaryParams( jsonDict ) );
    } challengeId:[[NSString alloc] initWithUTF8String:challengeId]];
}

void _reportScoreForChallenge( const char *challengeId, const char *score )
{
    [ArbiterInstance() reportScoreForChallenge:^(NSDictionary *jsonDict) {
        UnitySendMessage("ArbiterBinding", "ReportScoreForChallengeHandler", ProcessDictionaryParams( jsonDict ) );
    } challengeId:[[NSString alloc] initWithUTF8String:challengeId] score:[[NSString alloc] initWithUTF8String:score]];
}

void _showScoreChallengeRules( const char* challengeId )
{
    [ArbiterInstance() showScoreChallengeRules:^(void) {
        UnitySendMessage("ArbiterBinding", "ShowScoreChallengeRulesHandler", AutonomousStringCopy([@"" UTF8String]) );
    } challengeId:[[NSString alloc] initWithUTF8String:challengeId]];
}

void _showWalkThrough( const char* walkThroughId )
{
    [ArbiterInstance() showWalkThrough:^(void) {
        UnitySendMessage("ArbiterBinding", "ShowWalkThroughHandler", AutonomousStringCopy([@"" UTF8String]) );
    } walkThroughId:[[NSString alloc] initWithUTF8String:walkThroughId]];
}

void _showTournamentDetailsPanel( const char *tournamentId )
{
    [ArbiterInstance() showTournamentDetailsPanel:^(void) {
        UnitySendMessage("ArbiterBinding", "ShowTournamentDetailsPanelHandler", AutonomousStringCopy([@"" UTF8String]) );
    } tournamentId:[[NSString alloc] initWithUTF8String:tournamentId]];
}


void _dumpLogs( const char *jsonData ) 
{
     [[ArbiterLogger sharedManager] reportLog:JsonToDict(jsonData) arbiterState:ArbiterInstance()];
}
