//
//  ARBCardPaymentView.h
//  Unity-iPhone
//
//  Created by Andy Zinsser on 9/4/14.
//
//

#import <UIKit/UIKit.h>
#import "PTKView.h"
#import "STPToken.h"
#import "Arbiter.h"


@interface ARBCardPaymentView : UIView <UITableViewDataSource, UITableViewDelegate, PTKViewDelegate>

- (void)handleNextButton;

@property BOOL *isDeposit;
@property (strong) PTKView *pkView;
@property (strong) STPToken *stpToken;
@property (strong) NSDictionary *bundle;
@property float withdrawAmount;
@property (strong) NSString *email;
@property (strong) NSString *username;
@property (strong) NSString *fullName;
@property (strong) Arbiter *arbiter;
@property (strong) void (^onAuthorizationSuccess)(void);
@property (strong) void (^onPaymentSuccess)(void);

@end
