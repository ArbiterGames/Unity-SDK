//
//  Arbiter.h
//  Arbiter
//
//  Created by Andy Zinsser on 12/5/13.
//  Copyright (c) 2013 Arbiter. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "ArbiterSession.h"
#import "ArbiterWallet.h"

@interface Arbiter : NSObject
{
    void (^_completionHandler)(NSString *param);
}

@property (nonatomic, copy) NSString *gameAPIKey;
@property (nonatomic, copy) NSString *accessToken;
@property (nonatomic, copy) NSString *userId;
@property (nonatomic, strong) ArbiterSession *session;
@property (nonatomic, strong) ArbiterWallet *wallet;

- (id)initWithAccessToken:(NSString *)accessToken gameAPIKey:(NSString *)gameAPIKey callback:(void(^)(NSString *))handler;
- (void)getWalletDetailsWithCallback:(void(^)(NSString *))handler;
- (void)withdrawWithSettings:(NSDictionary *)withdrawDetails callback:(void(^)(NSString *))handler;
- (void)claimAccountWithCredentials:(NSDictionary*)credentials callback:(void(^)(NSString *))handler;
- (void)loginWithCredentials:(NSDictionary*)credentials callback:(void(^)(NSString *))handler;
- (void)logout;

@end
