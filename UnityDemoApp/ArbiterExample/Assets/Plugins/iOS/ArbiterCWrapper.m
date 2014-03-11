//
//  ArbiterCWrapper.m
//
//
//  Created by Andy Zinsser on 1/8/14.
//
//

#import "Arbiter.h"


// TODO: Since this wrapper isn't a full on class, think about how we should be storing the single arbiter instance here.
Arbiter *arbiter = nil;

char* AutonomousStringCopy(const char* string)
{
    if (string == NULL)
        return NULL;

    char* res = (char*)malloc(strlen(string) + 1);
    strcpy(res, string);
    return res;
}

void _init()
{
    arbiter = [Arbiter alloc];
    [arbiter init:^(NSDictionary *jsonDict) {
        NSLog(@"--- _init.response");
        NSError *error;
        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:jsonDict options:0 error:&error];
        NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
        const char* jsonChar = AutonomousStringCopy([jsonString UTF8String]);
        UnitySendMessage("ArbiterBinding", "InitHandler", jsonChar);
    }];
}

void _loginWithGameCenterPlayer()
{
    [arbiter loginWithGameCenterPlayer:^(NSDictionary *jsonDict) {
        NSLog(@"--- _loginWithGameCenterPlayer.response");
        NSError *error;
        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:jsonDict options:0 error:&error];
        NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
        NSLog(@"%@", jsonString);
        const char* jsonChar = AutonomousStringCopy([jsonString UTF8String]);
        UnitySendMessage("ArbiterBinding", "LoginWithGameCenterHandler", jsonChar);
    }];
}

void _verifyUser()
{
    [arbiter verifyUser:^(NSDictionary *jsonDict) {
        NSLog(@"--- _verifyUser.response");
        NSError *error;
        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:jsonDict options:0 error:&error];
        NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
        NSLog(@"%@", jsonString);
        const char* jsonChar = AutonomousStringCopy([jsonString UTF8String]);
        UnitySendMessage("ArbiterBinding", "VerifyUserHandler", jsonChar);
    }];
}

void _getWallet()
{
    [arbiter getWallet:^(NSDictionary *jsonDict) {
        NSLog(@"--- _getWallet.response");
        NSError *error;
        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:jsonDict options:0 error:&error];
        NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
        NSLog(@"%@", jsonString);
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

void _requestCompetition( const char* gameName, const char* buyIn, const char* filters )
{
    [arbiter requestCompetition:^(NSDictionary *jsonDict) {
            NSLog(@"--- _requestCompetition.response");
            NSError *error;
            NSData *jsonData = [NSJSONSerialization dataWithJSONObject:jsonDict options:0 error:&error];
            NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
            NSLog(@"%@", jsonString);
            const char* jsonChar = AutonomousStringCopy([jsonString UTF8String]);
            UnitySendMessage("ArbiterBinding", "RequestCompetitionHandler", jsonChar );
        }
        gameName:[[NSString alloc] initWithUTF8String:gameName]
        buyIn:[[NSString alloc] initWithUTF8String:buyIn]
        filters:[[NSString alloc] initWithUTF8String:filters]
     ];
}

void _viewPreviousCompetitions()
{
    [arbiter viewPreviousCompetitions:^(void) {
        NSLog(@"--- _viewPreviousCompteitions.response");
        UnitySendMessage("ArbiterBinding", "ViewPreviousCompetitionsHandler", @"" );
    }];
}