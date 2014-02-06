//
//  Arbiter.h
//  Arbiter
//
//  Created by Andy Zinsser on 12/5/13.
//  Copyright (c) 2013 Arbiter. All rights reserved.
//

@interface Arbiter : NSObject<NSURLConnectionDelegate, UIAlertViewDelegate>
{
    void (^_connectionHandler)(NSDictionary *params);
    void (^_completionHandler)(NSDictionary *params);
    NSMutableData *_responseData;
}

@property (nonatomic, copy) NSString *userId;
@property (nonatomic, copy) NSDictionary *wallet;
@property (nonatomic, copy) NSString *verificationUrl;

- (id)init:(void(^)(NSDictionary *))handler;
- (void)verifyUser:(void(^)(NSDictionary *))handler;
- (void)getWallet:(void(^)(NSDictionary *))handler;
- (void)copyDepositAddressToClipboard;

@end
