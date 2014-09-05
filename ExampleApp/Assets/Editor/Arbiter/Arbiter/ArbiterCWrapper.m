//
//  Arbiter.m
//  Arbiter
//
//  Copyright (c) 2014 Arbiter. All rights reserved.
//


#import "Arbiter.h"


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


const char* EMPTY_STRING = (char*)@"";


const char* ProcessDictionaryParams( NSDictionary *jsonDict )
{
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:jsonDict options:0 error:&error];
    NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    const char *jsonChar = AutonomousStringCopy([jsonString UTF8String]);
    return jsonChar;
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



void _init( const char *apiKey, const char *accessToken )
{
    _arbiter = [Arbiter alloc];
    [_arbiter init:^(NSDictionary *jsonDict) {
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
        UnitySendMessage( "ArbiterBinding", "LogoutHandler", ProcessDictionaryParams( jsonDict ) );
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
    }];
}

// ttt this isn't needed....?
void _updateClientWallet()
{
    [ArbiterInstance() getCachedWallet:^(NSDictionary *jsonDict) {
        UnitySendMessage("ArbiterBinding", "GetWalletHandler", ProcessDictionaryParams( jsonDict ));
    }];
}


void _showWalletPanel()
{
    [ArbiterInstance() showWalletPanel:^(void) {
        UnitySendMessage( "ArbiterBinding", "ShowWalletPanelHandler", EMPTY_STRING );
    }];
}

void _sendPromoCredits( const char *amount )
{
    [ArbiterInstance() sendPromoCredits:^(NSDictionary *jsonDict) {
        UnitySendMessage( "ArbiterBinding", "GetWalletHandler", ProcessDictionaryParams( jsonDict ) );
        UnitySendMessage( "ArbiterBinding", "SendPromoCreditsHandler", EMPTY_STRING );
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

void _getTournaments() // ttt rename?
{
    [ArbiterInstance() getTournaments:^(NSDictionary *jsonDict) {
        UnitySendMessage("ArbiterBinding", "GetTournamentsHandler", ProcessDictionaryParams( jsonDict ));
    } page:nil];
}

void _viewPreviousTournaments()
{
    [ArbiterInstance() viewPreviousTournaments:^(void) {
        UnitySendMessage("ArbiterBinding", "ViewPreviousTournamentsHandler", EMPTY_STRING );
    } page:nil];
}

void _viewIncompleteTournaments()
{
    [ArbiterInstance() viewIncompleteTournaments:^(NSString *tournamentId) {
        const char *jsonChar = AutonomousStringCopy([tournamentId UTF8String]);
        UnitySendMessage("ArbiterBinding", "ViewIncompleteTournamentsHandler", jsonChar );
    } page:nil];
}

void _reportScore( const char *tournamentId, const char *score )
{
    [ArbiterInstance() reportScore:^(NSDictionary *jsonDict) {
        UnitySendMessage("ArbiterBinding", "ReportScoreHandler", ProcessDictionaryParams( jsonDict ) );
    }
            tournamentId:[[NSString alloc] initWithUTF8String:tournamentId]
                   score:[[NSString alloc] initWithUTF8String:score]
     ];
}

void _showTournamentDetailsPanel( const char *tournamentId )
{
    [ArbiterInstance() showTournamentDetailsPanel:^(void) {
        UnitySendMessage("ArbiterBinding", "ShowTournamentDetailsPanelHandler", EMPTY_STRING );
    } tournamentId:[[NSString alloc] initWithUTF8String:tournamentId]];
}
