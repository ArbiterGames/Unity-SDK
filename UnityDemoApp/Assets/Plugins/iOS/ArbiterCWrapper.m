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

void _init( const char* apiKey )
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
    ];
}

void _loginWithGameCenterPlayer()
{
    [arbiter loginWithGameCenterPlayer:^(NSDictionary *jsonDict) {
        NSError *error;
        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:jsonDict options:0 error:&error];
        NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
        const char* jsonChar = AutonomousStringCopy([jsonString UTF8String]);
        UnitySendMessage("ArbiterBinding", "LoginWithGameCenterHandler", jsonChar);
    }];
}

void _verifyUser()
{
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
    [arbiter showWalletPanel:^(void) {
        const char* emptyString = AutonomousStringCopy([@"" UTF8String]);
        UnitySendMessage( "ArbiterBinding", "ShowWalletPanelHandler", emptyString );
    }];
}

void _copyDepositAddressToClipboard()
{
    [arbiter copyDepositAddressToClipboard];
}

void _requestCompetition( const char* buyIn, const char* filters )
{
    [arbiter requestCompetition:^(NSDictionary *jsonDict) {
            NSError *error;
            NSData *jsonData = [NSJSONSerialization dataWithJSONObject:jsonDict options:0 error:&error];
            NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
            const char* jsonChar = AutonomousStringCopy([jsonString UTF8String]);
            UnitySendMessage("ArbiterBinding", "RequestCompetitionHandler", jsonChar );
        }
        buyIn:[[NSString alloc] initWithUTF8String:buyIn]
        filters:[[NSString alloc] initWithUTF8String:filters]
     ];
}

void _getCompetitions()
{
    [arbiter getCompetitions:^(NSDictionary *jsonDict) {
        NSError *error;
        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:jsonDict options:0 error:&error];
        NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
        const char* jsonChar = AutonomousStringCopy([jsonString UTF8String]);
        UnitySendMessage("ArbiterBinding", "GetCompetitionsHandler", jsonChar);
    } page:nil];
}

void _viewPreviousCompetitions()
{
    [arbiter viewPreviousCompetitions:^(void) {
        UnitySendMessage("ArbiterBinding", "ViewPreviousCompetitionsHandler", @"" );
    } page:nil];
}

void _viewIncompleteCompetitions()
{
    [arbiter viewIncompleteCompetitions:^(NSString *competitionId) {
        const char* jsonChar = AutonomousStringCopy([competitionId UTF8String]);
        UnitySendMessage("ArbiterBinding", "ViewIncompleteCompetitionsHandler", jsonChar );
    } page:nil];
}

void _reportScore( const char* competitionId, const char* score )
{
    [arbiter reportScore:^(NSDictionary *jsonDict) {
            NSError *error;
            NSData *jsonData = [NSJSONSerialization dataWithJSONObject:jsonDict options:0 error:&error];
            NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
            const char* jsonChar = AutonomousStringCopy([jsonString UTF8String]);
            UnitySendMessage("ArbiterBinding", "ReportScoreHandler", jsonChar );
        }
        competitionId:[[NSString alloc] initWithUTF8String:competitionId]
        score:[[NSString alloc] initWithUTF8String:score]
    ];
}
