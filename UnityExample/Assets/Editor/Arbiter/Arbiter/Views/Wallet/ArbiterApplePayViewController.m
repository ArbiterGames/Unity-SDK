//
//  ArbiterApplePayViewController.m
//  Unity-iPhone
//
//  Created by Andy Zinsser on 11/4/14.
//
//

#import "ArbiterApplePayViewController.h"
#import "Stripe.h"

#define APPLE_MERCHANT_ID @"merchant.arbiter.unityexample"



@interface ArbiterApplePayViewController ()

@end

@implementation ArbiterApplePayViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    NSLog(@"ApplePay VC view did load");
    
    PKPaymentRequest *request = [Stripe
                                 paymentRequestWithMerchantIdentifier:APPLE_MERCHANT_ID
                                 amount:[NSDecimalNumber decimalNumberWithString:@"10.00"]
                                 currency:@"USD"
                                 description:@"Premium llama food"];
    
    if ([Stripe canSubmitPaymentRequest:request]) {
        PKPaymentAuthorizationViewController *paymentController = [[PKPaymentAuthorizationViewController alloc] initWithPaymentRequest:request];
        paymentController.delegate = self;
        [self presentViewController:paymentController animated:YES completion:nil];
    } else {
        // Show the user your own credit card form (see options 2 or 3)
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
    NSLog(@"didAuthorizePayment");
}
- (void)paymentAuthorizationViewControllerDidFinish:(PKPaymentAuthorizationViewController *)controller
{
    NSLog(@"didFinish");
}

@end
