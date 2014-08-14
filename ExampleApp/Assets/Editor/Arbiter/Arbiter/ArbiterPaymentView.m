//
//  ArbiterPaymentView.m
//  
//
//  Created by Andy Zinsser on 6/24/14.
//
//

#import <objc/runtime.h>
#import <QuartzCore/QuartzCore.h>
#import "ArbiterPaymentView.h"
#import "ArbiterConstants.h"

#define BUNDLE_SELECT_TAG 667
#define PAYMENT_INFO_TAG 668
#define EMAIL_FIELD_TAG 668
#define GET_BUNDLE_REQUEST_TAG 671
#define POST_DEPOSIT_REQUEST_TAG 672

@implementation ArbiterPaymentView
{
    BOOL shouldEnableNextButton;
    
    // Picker View
    UIPickerView *pickerView;
    NSMutableArray *dataArray;
    NSMutableDictionary *selectedBundle;
}

- (void)setupNextScreen
{
    [self.nextButton removeFromSuperview];
    [self.cancelButton removeFromSuperview];
    
    [self hideBundleSelectUI];
    [self hideEmailFieldUI];
    
    if ( [selectedBundle count] == 0 ) {
        [self setupBundleSelectLayout];
    } else if ( [NSString stringWithFormat:@"%@", [self.arbiter.user objectForKey:@"email"]].length == 0 && self.emailField == nil ) {
        [self setupEmailFieldLayout];
    } else if ( self.stripeView == nil ) {
        [self setupBillingInfoLayout];
    } else {
        [self getTokenAndSubmitPayment];
    }
}

- (void)resetSubviewFrames
{
    [self.nextButton removeFromSuperview];
    [self.cancelButton removeFromSuperview];
    [self renderNextButton:shouldEnableNextButton];
    [self renderCancelButton];
}

- (void)setupBundleSelectLayout
{
    UILabel *title = [[UILabel alloc] initWithFrame:CGRectMake(0.0f, 10.0f, self.bounds.size.width, 40.0f)];
    [title setText:@"How many credits would you like?"];
    [title setFont:[UIFont boldSystemFontOfSize:17]];
    [title setTextAlignment:NSTextAlignmentCenter];
    [title setTag:BUNDLE_SELECT_TAG];
    [self addSubview:title];
 
    shouldEnableNextButton = YES;
    [self renderBundleOptions];
    [self renderCancelButton];
    [self renderNextButton:shouldEnableNextButton];
}

- (void)setupEmailFieldLayout
{
    shouldEnableNextButton = YES;
    [self setMaxHeight:190.0f];
    
    UILabel *message = [[UILabel alloc] initWithFrame:CGRectMake(0.0f, 5.0f, self.bounds.size.width, 40.0f)];
    [message setText:@"Would you like a receipt?"];
    [message setFont:[UIFont boldSystemFontOfSize:17]];
    [message setTextAlignment:NSTextAlignmentCenter];
    [message setBackgroundColor:[UIColor clearColor]];
    [message setTag:EMAIL_FIELD_TAG];
    [self addSubview:message];
    
    self.emailField = [[UITextField alloc] initWithFrame:CGRectMake(20.0f, 40.0f, self.frame.size.width - 25.0f, 45.0f)];
    [self.emailField setBackgroundColor:[UIColor clearColor]];
    [self.emailField setFont:[UIFont boldSystemFontOfSize:17]];
    [self.emailField setPlaceholder:@"Email address (optional)"];
    [self.emailField setAutocorrectionType:UITextAutocorrectionTypeNo];
    [self.emailField setKeyboardType:UIKeyboardTypeDefault];
    [self.emailField setReturnKeyType:UIReturnKeyDone];
    [self.emailField setClearButtonMode:UITextFieldViewModeWhileEditing];
    [self.emailField setContentVerticalAlignment:UIControlContentVerticalAlignmentCenter];
    [self.emailField setAutocapitalizationType:UITextAutocapitalizationTypeNone];
    [self.emailField setDelegate:self];
    [self.emailField setTag:EMAIL_FIELD_TAG];
    
    UIImageView *backgroundImageView = [[UIImageView alloc] initWithFrame:CGRectMake(5.0f, 40.0f, self.frame.size.width - 10.0f, 45.0f)];
    backgroundImageView.image = [[UIImage imageNamed:@"textfield"]
                                 resizableImageWithCapInsets:UIEdgeInsetsMake(0, 8, 0, 8)];
    [backgroundImageView setTag:EMAIL_FIELD_TAG];

    [self addSubview:backgroundImageView];
    [self addSubview:self.emailField];
    [self.emailField becomeFirstResponder];
}

- (void)setupBillingInfoLayout
{
    NSString *stripePublishableKey;
    float cardFieldWidth = 290.0f;  // taken from Stripe/Stripe/Vendor/PaymentKit/PaymentKit/PKView.m
    shouldEnableNextButton = NO;
    [self setMaxHeight:190.0f];
    
    if ( [[[self.arbiter game] objectForKey:@"is_live"] boolValue] == true ) {
        stripePublishableKey = StripeLivePublishableKey;
    } else {
        stripePublishableKey = StripeTestPublishableKey;
    }
    
    self.stripeView = [[STPView alloc] initWithFrame:CGRectMake((self.frame.size.width - cardFieldWidth) / 2, 40.0f,
                                                                 self.frame.size.width, 40.0f)
                                              andKey:stripePublishableKey];
    self.stripeView.delegate = self;
    [self addSubview:self.stripeView];
    
    UILabel *message = [[UILabel alloc] initWithFrame:CGRectMake(0.0f, 5.0f, self.frame.size.width, 40.0f)];
    [message setText:@"Enter billing details"];
    [message setFont:[UIFont boldSystemFontOfSize:17]];
    [message setTextAlignment:NSTextAlignmentCenter];
    [message setBackgroundColor:[UIColor clearColor]];
    [message setTag:PAYMENT_INFO_TAG];
    [self addSubview:message];
}


# pragma mark Click Handlers

- (void)nextButtonClicked:(id)sender
{
    [self setupNextScreen];
}

- (void)saveEmailButtonClicked:(id)sender
{
    [self hideEmailFieldUI];
    [self.arbiter.user setObject:self.emailField.text forKey:@"email"];
    [self setupBillingInfoLayout];
}

- (void)getTokenAndSubmitPayment
{
    [self.arbiter.alertWindow addRequestToQueue:POST_DEPOSIT_REQUEST_TAG];
    [self setHidden:YES];
    [self.stripeView createToken:^(STPToken *token, NSError *error) {
        if (error) {
            [self.arbiter.alertWindow removeRequestFromQueue:POST_DEPOSIT_REQUEST_TAG];
            [self handleError:[error localizedDescription]];
            [self setHidden:NO];
        } else {
            self.responseHandler = [^(NSDictionary *responseDict) {
                [self.arbiter.alertWindow removeRequestFromQueue:POST_DEPOSIT_REQUEST_TAG];
                if ([[responseDict objectForKey:@"errors"] count]) {
                    [self handleError:[[responseDict objectForKey:@"errors"] objectAtIndex:0]];
                    [self setHidden:NO];
                } else {
                    [self animateOut];
                }
            } copy];
            
            NSString *arbiterEmail = [NSString stringWithFormat:@"%@", [self.arbiter.user objectForKey:@"email"]];
            NSString *receiptEmail;
            
            if ( arbiterEmail.length == 0 ) {
                receiptEmail = self.emailField.text;
            } else {
                receiptEmail = arbiterEmail;
            }
            
            NSDictionary *params = @{@"card_token": token.tokenId,
                                     @"bundle_sku": [selectedBundle objectForKey:@"sku"],
                                     @"email": receiptEmail};
            
            [self.arbiter httpPost:APIDepositURL params:params handler:self.responseHandler];
        }
    }];
}


# pragma mark UI Rendering Methods

- (void)renderBundleOptions
{
    // Once we get the current bundle prices, display them in a UIPicker
    self.responseHandler = [^(NSDictionary *responseDict) {
        dataArray = [[NSMutableArray alloc] initWithArray:[responseDict objectForKey:@"bundles"]];
        
        pickerView = [[UIPickerView alloc] init];
        [pickerView setTag:BUNDLE_SELECT_TAG];
        [pickerView setDataSource: self];
        [pickerView setDelegate: self];
        [pickerView setFrame: CGRectMake(0.0f, 40.0f, self.bounds.size.width, 180.0f)];
        pickerView.showsSelectionIndicator = YES;
        
        NSInteger selectedRow = 2;
        [pickerView selectRow:selectedRow inComponent:0 animated:YES];
        selectedBundle = [dataArray objectAtIndex:selectedRow];
        
        [self addSubview: pickerView];
        [self.arbiter.alertWindow removeRequestFromQueue:GET_BUNDLE_REQUEST_TAG];
    } copy];

    [self.arbiter.alertWindow addRequestToQueue:GET_BUNDLE_REQUEST_TAG];
    [self.arbiter httpGet:BundleURL handler:self.responseHandler];
}

- (void)hideBundleSelectUI
{
    for (UIView *view in [self subviews]) {
        if (view.tag == BUNDLE_SELECT_TAG) {
            [view removeFromSuperview];
        }
    }
}

- (void)hideEmailFieldUI
{
    for ( UIView *view in [self subviews] ) {
        if ( view.tag == EMAIL_FIELD_TAG ) {
            [view removeFromSuperview];
        }
    }
}

# pragma mark Stripe View Delegate Methods

- (void)stripeView:(STPView *)view withCard:(PKCard *)card isValid:(BOOL)valid
{
    shouldEnableNextButton = YES;
    self.nextButton.enabled = true;
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


# pragma mark Picker Delegate Methods

// Number of components.
-(NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}

// Total rows in our component.
-(NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    return [dataArray count];
}

// Display each row's data.
-(NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    return [NSString stringWithFormat:@"%@ credits for $%@", [self addThousandsSeparatorToString:[[dataArray objectAtIndex:row] objectForKey:@"value"]],
                                                             [[dataArray objectAtIndex:row] objectForKey:@"price"]];
}

// Do something with the selected row.
-(void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    selectedBundle = [dataArray objectAtIndex:row];
}


@end
