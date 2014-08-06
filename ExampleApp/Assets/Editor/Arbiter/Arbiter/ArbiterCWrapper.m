//
//  Arbiter.m
//  Arbiter
//
//  Copyright (c) 2014 Arbiter. All rights reserved.
//


#import "Arbiter.h"


// TODO: Since this wrapper isn't a full on class, think about how we should be storing the single arbiter instance here.
Arbiter *arbiter = nil;

// TODO: Replace boilerplate with macros

char* AutonomousStringCopy(const char* string)
{
    if (string == NULL)
        return NULL;
    
    char* res = (char*)malloc(strlen(string) + 1);
    strcpy(res, string);
    return res;
}


void checkForArbiterGameObject()
{
    if (arbiter == nil) {
        NSLog(@"Arbiter Error: Missing Game API Key and Access Token. Make sure you have added the Arbiter Prefab to your loading scene and that you have entered your Game API Key and Access Token to the Arbiter Game Object using the Unity Inspector.");
    }
}



void _init( const char* apiKey, const char* accessToken )
{
    arbiter = [Arbiter alloc];
    [arbiter init:^(NSDictionary *jsonDict) {
        NSError *error;
        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:jsonDict options:0 error:&error];
        NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
        const char* jsonChar = AutonomousStringCopy([jsonString UTF8String]);
        UnitySendMessage("ArbiterBinding", "InitHandler", jsonChar);
    }
           apiKey:[[NSString alloc] initWithUTF8String:apiKey]
      accessToken:[[NSString alloc] initWithUTF8String:accessToken]
     ];
}

void _loginAsAnonymous()
{
    checkForArbiterGameObject();
    [arbiter loginAsAnonymous:^(NSDictionary *jsonDict) {
        NSError *error;
        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:jsonDict options:0 error:&error];
        NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
        const char* jsonChar = AutonomousStringCopy([jsonString UTF8String]);
        UnitySendMessage("ArbiterBinding", "LoginAsAnonymousHandler", jsonChar);
    }];
}

void _loginWithGameCenterPlayer()
{
    checkForArbiterGameObject();
    [arbiter loginWithGameCenterPlayer:^(NSDictionary *jsonDict) {
        NSError *error;
        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:jsonDict options:0 error:&error];
        NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
        const char* jsonChar = AutonomousStringCopy([jsonString UTF8String]);
        UnitySendMessage("ArbiterBinding", "LoginWithGameCenterHandler", jsonChar);
    }];
}

void _login()
{
    checkForArbiterGameObject();
    [arbiter login:^(NSDictionary *jsonDict) {
        NSError *error;
        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:jsonDict options:0 error:&error];
        NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
        const char* jsonChar = AutonomousStringCopy([jsonString UTF8String]);
        UnitySendMessage( "ArbiterBinding", "LoginHandler", jsonChar );
    }];
}

void _logout()
{
    checkForArbiterGameObject();
    [arbiter logout:^(NSDictionary *jsonDict) {
        NSError *error;
        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:jsonDict options:0 error:&error];
        NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
        const char* jsonChar = AutonomousStringCopy([jsonString UTF8String]);
        UnitySendMessage( "ArbiterBinding", "LogoutHandler", jsonChar );
    }];
}

void _verifyUser()
{
    checkForArbiterGameObject();
    [arbiter verifyUser:^(NSDictionary *jsonDict) {
        NSError *error;
        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:jsonDict options:0 error:&error];
        NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
        const char* jsonChar = AutonomousStringCopy([jsonString UTF8String]);
        UnitySendMessage("ArbiterBinding", "VerifyUserHandler", jsonChar);
    }];
}

void _getWallet()
{
    checkForArbiterGameObject();
    [arbiter getWallet:^(NSDictionary *jsonDict) {
        NSError *error;
        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:jsonDict options:0 error:&error];
        NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
        const char* jsonChar = AutonomousStringCopy([jsonString UTF8String]);
        UnitySendMessage("ArbiterBinding", "GetWalletHandler", jsonChar);
    }];
}

void _showWalletPanel()
{
    checkForArbiterGameObject();
    [arbiter showWalletPanel:^(void) {
        const char* emptyString = AutonomousStringCopy([@"" UTF8String]);
        UnitySendMessage( "ArbiterBinding", "ShowWalletPanelHandler", emptyString );
    }];
}

void _copyDepositAddressToClipboard()
{
    [arbiter copyDepositAddressToClipboard];
}

void _requestTournament( const char* buyIn, const char* filters )
{
    checkForArbiterGameObject();
    [arbiter requestTournament:^(NSDictionary *jsonDict) {
        NSError *error;
        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:jsonDict options:0 error:&error];
        NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
        const char* jsonChar = AutonomousStringCopy([jsonString UTF8String]);
        UnitySendMessage("ArbiterBinding", "RequestTournamentHandler", jsonChar );
    }
                         buyIn:[[NSString alloc] initWithUTF8String:buyIn]
                       filters:[[NSString alloc] initWithUTF8String:filters]
     ];
}

void _getTournaments()
{
    checkForArbiterGameObject();
    [arbiter getTournaments:^(NSDictionary *jsonDict) {
        NSError *error;
        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:jsonDict options:0 error:&error];
        NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
        const char* jsonChar = AutonomousStringCopy([jsonString UTF8String]);
        UnitySendMessage("ArbiterBinding", "GetTournamentsHandler", jsonChar);
    } page:nil];
}

void _viewPreviousTournaments()
{
    checkForArbiterGameObject();
    [arbiter viewPreviousTournaments:^(void) {
        const char* emptyString = AutonomousStringCopy([@"" UTF8String]);
        UnitySendMessage("ArbiterBinding", "ViewPreviousTournamentsHandler", emptyString );
    } page:nil];
}

void _viewIncompleteTournaments()
{
    checkForArbiterGameObject();
    [arbiter viewIncompleteTournaments:^(NSString *tournamentId) {
        const char* jsonChar = AutonomousStringCopy([tournamentId UTF8String]);
        UnitySendMessage("ArbiterBinding", "ViewIncompleteTournamentsHandler", jsonChar );
    } page:nil];
}

void _reportScore( const char* tournamentId, const char* score )
{
    checkForArbiterGameObject();
    [arbiter reportScore:^(NSDictionary *jsonDict) {
        NSError *error;
        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:jsonDict options:0 error:&error];
        NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
        const char* jsonChar = AutonomousStringCopy([jsonString UTF8String]);
        UnitySendMessage("ArbiterBinding", "ReportScoreHandler", jsonChar );
    }
            tournamentId:[[NSString alloc] initWithUTF8String:tournamentId]
                   score:[[NSString alloc] initWithUTF8String:score]
     ];
}

void _showTournamentDetailsPanel( const char* tournamentId )
{
    checkForArbiterGameObject();
    [arbiter showTournamentDetailsPanel:^(void) {
        const char* emptyString = AutonomousStringCopy([@"" UTF8String]);
        UnitySendMessage("ArbiterBinding", "ShowTournamentDetailsPanelHandler", emptyString );
    } tournamentId:[[NSString alloc] initWithUTF8String:tournamentId]];
}
