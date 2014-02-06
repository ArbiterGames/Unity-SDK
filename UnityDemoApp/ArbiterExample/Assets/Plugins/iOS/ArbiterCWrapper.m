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

char* AutonomousStringCopy (const char* string)
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

void _copyDepositAddressToClipboard()
{
    [arbiter copyDepositAddressToClipboard];
}