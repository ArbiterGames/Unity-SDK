//
//  ArbiterPKViewController.h
//  Unity-iPhone
//
//  Created by Andy Zinsser on 9/22/14.
//
//

#import <UIKit/UIKit.h>
#import <PassKit/PassKit.h>

@interface ArbiterPKViewController : UIViewController <PKPaymentAuthorizationViewControllerDelegate>

@property (strong) PKPaymentRequest *request;
- (id)initWithRequest:(PKPaymentRequest *)request;

@end
