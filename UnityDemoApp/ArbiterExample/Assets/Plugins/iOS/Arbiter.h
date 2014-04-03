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
@property (copy) NSString *nextPageIncompleteCompetitionsUrl;
@property (copy) NSString *previousPageIncompleteCompetitionsUrl;
@property (copy) NSString *currentIncompleteCompetitionId;


- (id)init:(void(^)(NSDictionary *))handler;
- (void)loginWithGameCenterPlayer:(void(^)(NSDictionary *))handler;
- (void)verifyUser:(void(^)(NSDictionary *))handler;

- (void)getWallet:(void(^)(NSDictionary *))handler;
- (void)showWalletPanel:(void(^)(void))handler;
- (void)copyDepositAddressToClipboard;

- (void)requestCompetition:(void(^)(NSDictionary *))handler gameName:(NSString*)gameName buyIn:(NSString*)buyIn;
- (void)getCompetitions:(void(^)(NSDictionary*))handler page:(NSString *)page;
- (void)viewPreviousCompetitions:(void(^)(void))handler page:(NSString *)page;

- (void)getIncompleteCompetitions:(void(^)(NSDictionary *))handler page:(NSString *)page;
- (void)viewIncompleteCompetitions:(void(^)(NSString *))handler page:(NSString *)page;

- (void)reportScore:(void(^)(NSDictionary *))handler competitionId:(NSString*)competitionId score:(NSString*)score;

@end
