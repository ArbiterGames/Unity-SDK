//
//  ArbiterPKViewController.m
//  Unity-iPhone
//
//  Created by Andy Zinsser on 9/22/14.
//
//

#import "ArbiterPKViewController.h"
#import <PassKit/PassKit.h>
#import "Stripe.h"

@implementation ArbiterPKViewController

- (id)initWithRequest:(PKPaymentRequest *)request
{
    self = [super init];
    if ( self ) {
        self.request = request;
        
        NSLog(@"Creating the paymentController");
        UIViewController *paymentController = [Stripe
                                               paymentControllerWithRequest:request
                                               delegate:self];
        [self presentViewController:paymentController animated:YES completion:nil];
    }
    return self;
}


# pragma mark PassKit delegate methods

- (void)paymentAuthorizationViewController:(PKPaymentAuthorizationViewController *)controller
                       didAuthorizePayment:(PKPayment *)payment
                                completion:(void (^)(PKPaymentAuthorizationStatus))completion {
    /*
     We'll implement this method below in 'Creating a single-use token'.
     Note that we've also been given a block that takes a
     PKPaymentAuthorizationStatus. We'll call this function with either
     PKPaymentAuthorizationStatusSuccess or PKPaymentAuthorizationStatusFailure
     after all of our asynchronous code is finished executing. This is how the
     PKPaymentAuthorizationViewController knows when and how to update its UI.
     */
    NSLog(@"pyamentAuthorizationViewController");
    [self handlePaymentAuthorizationWithPayment:payment completion:completion];
}

- (void)paymentAuthorizationViewControllerDidFinish:(PKPaymentAuthorizationViewController *)controller {
    NSLog(@"TODO: Remove the paymentViewController");

    // TODO: Setup a callback and pass that into completion here
    [self dismissViewControllerAnimated:YES completion:nil];
}

// ViewController.m

- (void)handlePaymentAuthorizationWithPayment:(PKPayment *)payment
                                   completion:(void (^)(PKPaymentAuthorizationStatus))completion {
    [Stripe createTokenWithPayment:payment
                        completion:^(STPToken *token, NSError *error) {
                            if (error) {
                                completion(PKPaymentAuthorizationStatusFailure);
                                return;
                            }
                            /*
                             We'll implement this below in "Sending the token to your server".
                             Notice that we're passing the completion block through.
                             See the above comment in didAuthorizePayment to learn why.
                             */
                            NSLog(@"Send the token to our server to create a charge");
                            NSLog(@"token: %@", token.tokenId);
//                            [self createBackendChargeWithToken:token completion:completion];
                        }];
}

@end
