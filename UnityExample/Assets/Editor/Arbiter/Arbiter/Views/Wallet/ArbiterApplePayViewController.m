//
//  ArbiterApplePayViewController.m
//  Unity-iPhone
//
//  Created by Andy Zinsser on 11/4/14.
//
//

#import "ArbiterTracking.h"
#import "ArbiterApplePayViewController.h"
#import "Stripe.h"
#import "ArbiterConstants.h"

#define APPLE_MERCHANT_ID @"merchant.arbiter.unityexample"



@interface ArbiterApplePayViewController ()

@end

@implementation ArbiterApplePayViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.paymentSuccess = NO;
    PKPaymentRequest *request = [Stripe
                                 paymentRequestWithMerchantIdentifier:APPLE_MERCHANT_ID
                                 amount:[NSDecimalNumber decimalNumberWithString:[self.bundle objectForKey:@"price"]]
                                 currency:@"USD"
                                 description:[NSString stringWithFormat:@"$%@ for %@ Arbiter credits",
                                              [self.bundle objectForKey:@"price"], [self.bundle objectForKey:@"value"]]];
    
    if ([Stripe canSubmitPaymentRequest:request]) {
        PKPaymentAuthorizationViewController *paymentController = [[PKPaymentAuthorizationViewController alloc] initWithPaymentRequest:request];
        paymentController.delegate = self;
        [self presentViewController:paymentController animated:YES completion:nil];
    } else {
        // Show the user your own credit card form (see options 2 or 3)
    }
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/


# pragma mark PassKit Delegate methods

- (void)paymentAuthorizationViewController:(PKPaymentAuthorizationViewController *)controller
                       didAuthorizePayment:(PKPayment *)payment
                                completion:(void (^)(PKPaymentAuthorizationStatus status))completion
{
    [Stripe createTokenWithPayment:payment completion:[^(STPToken *stripeToken, NSError *error) {
        if (error) {
            [self handleError:[error localizedDescription]];
        } else {
            NSDictionary *params = @{@"card_token": stripeToken.tokenId,
                                     @"bundle_sku": [self.bundle objectForKey:@"sku"],
                                     @"email": self.email,
                                     @"username": self.username};
            [[ArbiterTracking arbiterInstance] track:@"Submitted Deposit Billing Info"];
            [self.arbiter httpPost:APIDepositURL params:params isBlocking:YES handler:[^(NSDictionary *responseDict) {
                if ( [[responseDict objectForKey:@"errors"] count] ) {
                    NSString *message = [[responseDict objectForKey:@"errors"] objectAtIndex:0];
                    [[ArbiterTracking arbiterInstance] track:@"Received Deposit Error" properties:@{@"error": message}];
                    [self handleError:message];
                    completion(PKPaymentAuthorizationStatusFailure);
                } else {
                    [[ArbiterTracking arbiterInstance] track:@"Received Deposit Success"];
                    self.arbiter.user = [responseDict objectForKey:@"user"];
                    completion(PKPaymentAuthorizationStatusSuccess);
                    self.paymentSuccess = YES;
                }
            } copy]];
        }
    } copy]];
}


- (void)paymentAuthorizationViewControllerDidFinish:(PKPaymentAuthorizationViewController *)controller
{
    self.paymentCallback(self.paymentSuccess);
    [self dismissViewControllerAnimated:YES completion:nil];
}


- (void)handleError:(NSString *)error
{
    UIAlertView *message = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error", @"Error")
                                                      message:error
                                                     delegate:nil
                                            cancelButtonTitle:NSLocalizedString(@"OK", @"OK")
                                            otherButtonTitles:nil];
    [message show];
}

@end
