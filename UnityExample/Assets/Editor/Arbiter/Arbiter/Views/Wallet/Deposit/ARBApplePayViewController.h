//
//  ARBApplePayViewController.h
//  Unity-iPhone
//
//  Created by Andy Zinsser on 11/4/14.
//
//

#import <UIKit/UIKit.h>
#import <PassKit/PassKit.h>
#import "Arbiter.h"

@interface ARBApplePayViewController : UIViewController <PKPaymentAuthorizationViewControllerDelegate>

@property (strong) Arbiter *arbiter;
@property BOOL paymentSuccess;
@property (strong) NSDictionary *bundle;
@property (strong) void (^paymentCallback)(BOOL);

- (void)authorizePayment;

@end
