//
//  Arbiter.h
//  Arbiter
//
//  Created by Andy Zinsser on 12/5/13.
//  Copyright (c) 2013 Arbiter. All rights reserved.
//

@interface Arbiter : NSObject<NSURLConnectionDelegate, UIAlertViewDelegate>
{
    // TODO: Replace the completionHandler with a 'alertViewHandlerRegistry'
    void (^_completionHandler)(NSDictionary *params);
    NSMutableDictionary *_alertViewHandlerRegistry;
    
    NSMutableDictionary *_connectionHandlerRegistry;
    NSMutableDictionary *_responseDataRegistry;
}

@property (copy) NSString *userId;
@property (copy) NSDictionary *wallet;
@property (copy) NSString *verificationUrl;
@property (copy) NSString *nextPageCompetitionsUrl;
@property (copy) NSString *previousPageCompetitionsUrl;


- (id)init:(void(^)(NSDictionary *))handler;
- (void)loginWithGameCenterPlayer:(void(^)(NSDictionary *))handler;
- (void)verifyUser:(void(^)(NSDictionary *))handler;
- (void)getWallet:(void(^)(NSDictionary *))handler;
- (void)showWalletPanel:(void(^)(void))handler;
- (void)copyDepositAddressToClipboard;

@end
