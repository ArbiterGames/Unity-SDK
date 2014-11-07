//
//  ARBApplePayViewController.m
//  Unity-iPhone
//
//  Created by Andy Zinsser on 11/4/14.
//
//

#import <AddressBook/AddressBook.h>
#import "Stripe.h"

#import "ARBApplePayViewController.h"
#import "ARBTracking.h"
#import "ARBConstants.h"

#define APPLE_MERCHANT_ID @"merchant.arbiter.credits"



@interface ARBApplePayViewController ()

@end

@implementation ARBApplePayViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.paymentSuccess = NO;
}

- (void)authorizePayment
{
    if ( [[[self.arbiter game] objectForKey:@"is_live"] boolValue] == true ) {
        [Stripe setDefaultPublishableKey:StripeLivePublishableKey];
    } else {
        [Stripe setDefaultPublishableKey:StripeTestPublishableKey];
    }
    
    PKPaymentRequest *request = [Stripe
                                 paymentRequestWithMerchantIdentifier:APPLE_MERCHANT_ID
                                 amount:[NSDecimalNumber decimalNumberWithString:[self.bundle objectForKey:@"price"]]
                                 currency:@"USD"
                                 description:@"Arbiter"];

    if ([Stripe canSubmitPaymentRequest:request]) {
        request.requiredShippingAddressFields = PKAddressFieldEmail;
        NSString *summary = [NSString stringWithFormat:@"%@ Arbiter credits for %@ cash challenges", [self.bundle objectForKey:@"value"], [self.arbiter.game objectForKey:@"name"]];
        PKPaymentSummaryItem *lineItem1 = [PKPaymentSummaryItem summaryItemWithLabel:summary amount:[NSDecimalNumber decimalNumberWithString:[self.bundle objectForKey:@"price"]]];
        PKPaymentSummaryItem *total = [PKPaymentSummaryItem summaryItemWithLabel:@"Arbiter" amount:[NSDecimalNumber decimalNumberWithString:[self.bundle objectForKey:@"price"]]];
        request.paymentSummaryItems = @[lineItem1, total];
        PKPaymentAuthorizationViewController *paymentController = [[PKPaymentAuthorizationViewController alloc] initWithPaymentRequest:request];
        paymentController.delegate = self;
        [self presentViewController:paymentController animated:YES completion:nil];
    } else {
        [self handleError:@"We are unable to access the cards stored in Apple Pay on this device."];
        self.paymentCallback(NO);
    }
}


# pragma mark PassKit Delegate methods


- (void)paymentAuthorizationViewController:(PKPaymentAuthorizationViewController *)controller
                       didAuthorizePayment:(PKPayment *)payment
                                completion:(void (^)(PKPaymentAuthorizationStatus status))completion
{
    [Stripe createTokenWithPayment:payment completion:[^(STPToken *stripeToken, NSError *error) {
        if (error) {
            [self handleError:[error localizedDescription]];
        } else {
            NSString *existingEmail = [self.arbiter.user objectForKey:@"email"];
            NSString *email;
            ABMultiValueRef multiEmails = ABRecordCopyValue(payment.shippingAddress, kABPersonEmailProperty);
            for(CFIndex i = 0; i < ABMultiValueGetCount(multiEmails); i++) {
                CFStringRef emailRef = ABMultiValueCopyValueAtIndex(multiEmails, i);
                email = (NSString *) CFBridgingRelease(emailRef);
            }
            
            if ( email == (id)[NSNull null] || email.length == 0 ) {
                if ( existingEmail == (id)[NSNull null] || email.length == 0 ) {
                    NSLog(@"TODO: Show email input");
                } else {
                    email = existingEmail;
                }
            }
            
            NSDictionary *params = @{@"card_token": stripeToken.tokenId,
                                     @"bundle_sku": [self.bundle objectForKey:@"sku"],
                                     @"email": email,
                                     @"username": [self.arbiter.user objectForKey:@"username"]};
            [[ARBTracking arbiterInstance] track:@"Submitted Deposit Billing Info"];
            [self.arbiter httpPost:APIDepositURL params:params isBlocking:YES handler:[^(NSDictionary *responseDict) {
                if ( [[responseDict objectForKey:@"errors"] count] ) {
                    NSString *message = [[responseDict objectForKey:@"errors"] objectAtIndex:0];
                    [[ARBTracking arbiterInstance] track:@"Received Deposit Error" properties:@{@"error": message}];
                    [self handleError:message];
                    completion(PKPaymentAuthorizationStatusFailure);
                } else {
                    [[ARBTracking arbiterInstance] track:@"Received Deposit Success"];
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
    [self dismissViewControllerAnimated:YES completion:^(void) {
        self.paymentCallback(self.paymentSuccess);
       [self removeFromParentViewController];
    }];
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
