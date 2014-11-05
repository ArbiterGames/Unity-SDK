//
//  ArbiterApplePayViewController.h
//  Unity-iPhone
//
//  Created by Andy Zinsser on 11/4/14.
//
//

#import <UIKit/UIKit.h>
#import "STPToken.h"
#import "Arbiter.h"
@import PassKit;

@interface ArbiterApplePayViewController : UIViewController <PKPaymentAuthorizationViewControllerDelegate>

@property (strong) Arbiter *arbiter;
@property BOOL paymentSuccess;
@property (strong) NSDictionary *bundle;
@property (strong) NSString *email;
@property (strong) NSString *username;
@property (strong) void (^paymentCallback)(STPToken *);

@end
