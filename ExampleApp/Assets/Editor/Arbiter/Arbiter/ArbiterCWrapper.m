//
//  Arbiter.m
//  Arbiter
//
//  Copyright (c) 2014 Arbiter. All rights reserved.
//


#import "Arbiter.h"


// TODO: Since this wrapper isn't a full on class, think about how we should be storing the single arbiter instance here.
Arbiter *arbiter = nil;

char *AutonomousStringCopy(const char *string)
{
    if (string == NULL)
        return NULL;
    
    char *res = (char*)malloc(strlen(string) + 1);
    strcpy(res, string);
    return res;
}


void CheckForArbiterGameObject()
{
    if (arbiter == nil) {
        NSLog(@"Arbiter Error: Missing Game API Key and Access Token. Make sure you have added the Arbiter Prefab to your loading scene and that you have entered your Game API Key and Access Token to the Arbiter Game Object using the Unity Inspector.");
    }
}


const char* ProcessParams( NSDictionary *jsonDict )
{
    CheckForArbiterGameObject();
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:jsonDict options:0 error:&error];
    NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    const char *jsonChar = AutonomousStringCopy([jsonString UTF8String]);
    return jsonChar;
}


void ClientCallbackUserUpdated()
{
    [arbiter getCachedUser:^(NSDictionary *jsonDict) {
        NSError *error;
        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:jsonDict options:0 error:&error];
        NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
        const char *jsonChar = AutonomousStringCopy([jsonString UTF8String]);
        UnitySendMessage("ArbiterBinding", "OnUserUpdated", jsonChar);
    }];
}



void _init( const char *apiKey, const char *accessToken )
{
    arbiter = [Arbiter alloc];
    [arbiter init:^(NSDictionary *jsonDict) {
        NSError *error;
        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:jsonDict options:0 error:&error];
        NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
        const char *jsonChar = AutonomousStringCopy([jsonString UTF8String]);
        UnitySendMessage("ArbiterBinding", "InitHandler", jsonChar);
    }
           apiKey:[[NSString alloc] initWithUTF8String:apiKey]
      accessToken:[[NSString alloc] initWithUTF8String:accessToken]
     ];
}

void _loginAsAnonymous()
{
    [arbiter loginAsAnonymous:^(NSDictionary *jsonDict) {
        UnitySendMessage("ArbiterBinding", "LoginAsAnonymousHandler", ProcessParams( jsonDict ));
    }];
}

void _loginWithGameCenterPlayer()
{
    CheckForArbiterGameObject();
    [arbiter loginWithGameCenterPlayer:^(NSDictionary *jsonDict) {
        NSError *error;
        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:jsonDict options:0 error:&error];
        NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
        const char *jsonChar = AutonomousStringCopy([jsonString UTF8String]);
        UnitySendMessage("ArbiterBinding", "LoginWithGameCenterHandler", jsonChar);
    }];
}

void _login()
{
    CheckForArbiterGameObject();
    [arbiter login:^(NSDictionary *jsonDict) {
        NSError *error;
        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:jsonDict options:0 error:&error];
        NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
        const char *jsonChar = AutonomousStringCopy([jsonString UTF8String]);
        UnitySendMessage( "ArbiterBinding", "LoginHandler", jsonChar );
    }];
}

void _logout()
{
    CheckForArbiterGameObject();
    [arbiter logout:^(NSDictionary *jsonDict) {
        NSError *error;
        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:jsonDict options:0 error:&error];
        NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
        const char *jsonChar = AutonomousStringCopy([jsonString UTF8String]);
        UnitySendMessage( "ArbiterBinding", "LogoutHandler", jsonChar );
    }];
}

bool _isUserAuthenticated()
{
    CheckForArbiterGameObject();
    return [arbiter isUserAuthenticated];
}

void _verifyUser()
{
    CheckForArbiterGameObject();
    [arbiter verifyUser:^(NSDictionary *jsonDict) {
        NSError *error;
        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:jsonDict options:0 error:&error];
        NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
        const char *jsonChar = AutonomousStringCopy([jsonString UTF8String]);
        UnitySendMessage("ArbiterBinding", "VerifyUserHandler", jsonChar);
    }];
}

bool _isUserVerified()
{
    CheckForArbiterGameObject();
    return [arbiter isUserVerified];
}

void _fetchWallet()
{
    CheckForArbiterGameObject();
    [arbiter fetchWallet:^(NSDictionary *jsonDict) {
        NSError *error;
        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:jsonDict options:0 error:&error];
        NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
        const char *jsonChar = AutonomousStringCopy([jsonString UTF8String]);
        UnitySendMessage("ArbiterBinding", "GetWalletHandler", jsonChar);
    }];
}

// ttt this isn't needed....?
void _updateClientWallet()
{
    [arbiter getCachedWallet:^(NSDictionary *jsonDict) {
        NSError *error;
        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:jsonDict options:0 error:&error];
        NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
        const char *jsonChar = AutonomousStringCopy([jsonString UTF8String]);
        UnitySendMessage("ArbiterBinding", "GetWalletHandler", jsonChar);
    }];
}

/* ttt kill
const char* _getWalletBalance()
{
    checkForArbiterGameObject();
//ttt    return [arbiter getWalletBalance];
    const char* emptyString = AutonomousStringCopy([@"" UTF8String]);
    return AutonomousStringCopy(emptyString);
}
*/


void _showWalletPanel()
{
    CheckForArbiterGameObject();
    [arbiter showWalletPanel:^(void) {
        const char *emptyString = AutonomousStringCopy([@"" UTF8String]);
        UnitySendMessage( "ArbiterBinding", "ShowWalletPanelHandler", emptyString );
    }];
}

void _sendPromoCredits( const char *amount )
{
    CheckForArbiterGameObject();
    [arbiter sendPromoCredits:^(NSDictionary *jsonDict) {
        NSError *error;
        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:jsonDict options:0 error:&error];
        NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
        const char *jsonChar = AutonomousStringCopy([jsonString UTF8String]);
        const char *emptyString = AutonomousStringCopy([@"" UTF8String]);
        UnitySendMessage( "ArbiterBinding", "GetWalletHandler", jsonChar );
        UnitySendMessage( "ArbiterBinding", "SendPromoCreditsHandler", emptyString );
    }
                       amount:[[NSString alloc] initWithUTF8String:amount]];
}

void _requestTournament( const char *buyIn, const char *filters )
{
    CheckForArbiterGameObject();
    [arbiter requestTournament:^(NSDictionary *jsonDict) {
        NSError *error;
        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:jsonDict options:0 error:&error];
        NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
        const char *jsonChar = AutonomousStringCopy([jsonString UTF8String]);
        UnitySendMessage("ArbiterBinding", "RequestTournamentHandler", jsonChar );
    }
                         buyIn:[[NSString alloc] initWithUTF8String:buyIn]
                       filters:[[NSString alloc] initWithUTF8String:filters]
     ];
}

void _getTournaments() // ttt rename?
{
    CheckForArbiterGameObject();
    [arbiter getTournaments:^(NSDictionary *jsonDict) {
        NSError *error;
        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:jsonDict options:0 error:&error];
        NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
        const char *jsonChar = AutonomousStringCopy([jsonString UTF8String]);
        UnitySendMessage("ArbiterBinding", "GetTournamentsHandler", jsonChar);
    } page:nil];
}

void _viewPreviousTournaments()
{
    CheckForArbiterGameObject();
    [arbiter viewPreviousTournaments:^(void) {
        const char *emptyString = AutonomousStringCopy([@"" UTF8String]);
        UnitySendMessage("ArbiterBinding", "ViewPreviousTournamentsHandler", emptyString );
    } page:nil];
}

void _viewIncompleteTournaments()
{
    CheckForArbiterGameObject();
    [arbiter viewIncompleteTournaments:^(NSString *tournamentId) {
        const char *jsonChar = AutonomousStringCopy([tournamentId UTF8String]);
        UnitySendMessage("ArbiterBinding", "ViewIncompleteTournamentsHandler", jsonChar );
    } page:nil];
}

void _reportScore( const char *tournamentId, const char *score )
{
    CheckForArbiterGameObject();
    [arbiter reportScore:^(NSDictionary *jsonDict) {
        NSError *error;
        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:jsonDict options:0 error:&error];
        NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
        const char *jsonChar = AutonomousStringCopy([jsonString UTF8String]);
        UnitySendMessage("ArbiterBinding", "ReportScoreHandler", jsonChar );
    }
            tournamentId:[[NSString alloc] initWithUTF8String:tournamentId]
                   score:[[NSString alloc] initWithUTF8String:score]
     ];
}

void _showTournamentDetailsPanel( const char *tournamentId )
{
    CheckForArbiterGameObject();
    [arbiter showTournamentDetailsPanel:^(void) {
        const char *emptyString = AutonomousStringCopy([@"" UTF8String]);
        UnitySendMessage("ArbiterBinding", "ShowTournamentDetailsPanelHandler", emptyString );
    } tournamentId:[[NSString alloc] initWithUTF8String:tournamentId]];
}
