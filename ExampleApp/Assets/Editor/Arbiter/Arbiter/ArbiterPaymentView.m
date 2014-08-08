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

@implementation ArbiterPaymentView
{
    // Picker View
    UIPickerView *pickerView;
    NSMutableArray *dataArray;
    NSMutableDictionary *selectedBundle;
}

- (void)setupNextScreen
{
    [self setupBundleSelectLayout];
}

- (void)setupBundleSelectLayout
{
    UILabel *title = [[UILabel alloc] initWithFrame:CGRectMake(0.0f, 10.0f, self.bounds.size.width, 40.0f)];
    [title setText:@"How many credits would you like?"];
    [title setFont:[UIFont boldSystemFontOfSize:17]];
    [title setTextAlignment:NSTextAlignmentCenter];
    [title setTag:BUNDLE_SELECT_TAG];
    [self addSubview:title];

    [self renderCancelButton];
    [self renderSelectButton];
    [self renderBundleOptions];
}

- (void)setupEmailFieldLayout
{
    CGRect frame = self.frame;
    frame.size.height = 140.0f;
    frame.origin.y = ([UIScreen mainScreen].bounds.size.height / 2 - frame.size.height) / 2;
    [self setFrame:frame];
    
    UILabel *message = [[UILabel alloc] initWithFrame:CGRectMake(0.0f, 5.0f, self.bounds.size.width, 40.0f)];
    [message setText:@"Would you like a receipt?"];
    [message setFont:[UIFont boldSystemFontOfSize:17]];
    [message setTextAlignment:NSTextAlignmentCenter];
    [message setBackgroundColor:[UIColor clearColor]];
    [message setTag:EMAIL_FIELD_TAG];
    [self addSubview:message];
    
    self.emailField = [[UITextField alloc] initWithFrame:CGRectMake(20.0f, 40.0f, frame.size.width - 25.0f, 45.0f)];
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
    
    UIImageView *backgroundImageView = [[UIImageView alloc] initWithFrame:CGRectMake(5.0f, 40.0f, frame.size.width - 10.0f, 45.0f)];
    backgroundImageView.image = [[UIImage imageNamed:@"textfield"]
                                 resizableImageWithCapInsets:UIEdgeInsetsMake(0, 8, 0, 8)];
    [backgroundImageView setTag:EMAIL_FIELD_TAG];
    [self addSubview:backgroundImageView];
    [self addSubview:self.emailField];
    [self.emailField becomeFirstResponder];
    
    [self renderSaveEmailButton];
    [self renderCancelButton];
}

- (void)setupBillingInfoLayout
{
    NSString *stripePublishableKey;
    CGRect frame = self.frame;
    frame.size.height = 140.0f;
    frame.origin.y = ([UIScreen mainScreen].bounds.size.height / 2 - frame.size.height) / 2;
    [self setFrame:frame];

    float cardFieldWidth = 290.0f;  // taken from PKView.m
    
    if ( [[[self.arbiter game] objectForKey:@"is_live"] boolValue] == true ) {
        stripePublishableKey = StripeLivePublishableKey;
    } else {
        stripePublishableKey = StripeTestPublishableKey;
    }
    
    self.stripeView = [[STPView alloc] initWithFrame:CGRectMake((self.frame.size.width - cardFieldWidth) / 2, 40.0f,
                                                                frame.size.width, 40.0f)
                                              andKey:stripePublishableKey];
    self.stripeView.delegate = self;
    [self addSubview:self.stripeView];
    
    UILabel *message = [[UILabel alloc] initWithFrame:CGRectMake(0.0f, 5.0f, self.bounds.size.width, 40.0f)];
    [message setText:@"Enter billing details"];
    [message setFont:[UIFont boldSystemFontOfSize:17]];
    [message setTextAlignment:NSTextAlignmentCenter];
    [message setBackgroundColor:[UIColor clearColor]];
    [message setTag:PAYMENT_INFO_TAG];
    [self addSubview:message];
    
    [self renderPurchaseButton];
    [self renderCancelButton];
}

- (void)selectBundleButtonClicked:(id)sender
{
    NSString *email = [NSString stringWithFormat:@"%@", [self.arbiter.user objectForKey:@"email"]];
    [self hideBundleSelectUI];
    
    if ( email.length > 0 ) {
        [self setupBillingInfoLayout];
    } else {
        [self setupEmailFieldLayout];
    }
}

- (void)saveEmailButtonClicked:(id)sender
{
    [self hideEmailFieldUI];
    [self.arbiter.user setObject:self.emailField.text forKey:@"email"];
    [self setupBillingInfoLayout];
}

- (void)purchaseButtonClicked:(id)sender
{
    [self.stripeView createToken:^(STPToken *token, NSError *error) {
        if (error) {
            [self handleError:[error localizedDescription]];
        } else {
            NSLog(@"Received token %@", token.tokenId);
    
            self.responseHandler = [^(NSDictionary *responseDict) {
                if ([[responseDict objectForKey:@"errors"] count]) {
                    [self handleError:[[responseDict objectForKey:@"errors"] objectAtIndex:0]];
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

- (void)renderSelectButton
{
    UIButton *button = [UIButton buttonWithType:UIButtonTypeSystem];
    [button setFrame:CGRectMake(self.bounds.size.width / 2, self.bounds.size.height - 50, self.bounds.size.width / 2, 50)];
    [button setTitle:@"Next" forState:UIControlStateNormal];
    [button.titleLabel setFont:[UIFont boldSystemFontOfSize:17]];
    [button setTag:BUNDLE_SELECT_TAG];
    [button addTarget:self action:@selector(selectBundleButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    
    CALayer *topBorder = [CALayer layer];
    topBorder.frame = CGRectMake(0, 0, button.frame.size.width, 0.5f);
    topBorder.backgroundColor = [[UIColor lightGrayColor] CGColor];
    [button.layer addSublayer:topBorder];

    [self addSubview:button];
}

- (void)renderCancelButton
{
    UIButton *button = [UIButton buttonWithType:UIButtonTypeSystem];
    [button setFrame:CGRectMake(0, self.bounds.size.height - 50, self.bounds.size.width / 2, 50.0f)];
    [button setTitle:@"Cancel" forState:UIControlStateNormal];
    [button setTag:BUNDLE_SELECT_TAG];
    [button.titleLabel setFont:[UIFont systemFontOfSize:17]];
    [button addTarget:self action:@selector(cancelButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    
    CALayer *topBorder = [CALayer layer];
    topBorder.frame = CGRectMake(0, 0, button.frame.size.width, 0.5f);
    topBorder.backgroundColor = [[UIColor lightGrayColor] CGColor];
    [button.layer addSublayer:topBorder];
    
    CALayer *rightBorder = [CALayer layer];
    rightBorder.frame = CGRectMake(button.frame.size.width - 0.5f, 0, 0.5f, button.frame.size.height);
    rightBorder.backgroundColor = [[UIColor lightGrayColor] CGColor];
    [button.layer addSublayer:rightBorder];
    
    [self addSubview:button];
}

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
    } copy];
    
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

- (void)renderSaveEmailButton
{
    UIButton *button = [UIButton buttonWithType:UIButtonTypeSystem];
    [button setFrame:CGRectMake(self.bounds.size.width / 2, self.bounds.size.height - 50, self.bounds.size.width / 2, 50)];
    [button setTitle:@"Next" forState:UIControlStateNormal];
    [button.titleLabel setFont:[UIFont boldSystemFontOfSize:17]];
    [button setTag:EMAIL_FIELD_TAG];
    [button addTarget:self action:@selector(saveEmailButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    
    CALayer *topBorder = [CALayer layer];
    topBorder.frame = CGRectMake(0, 0, button.frame.size.width, 0.5f);
    topBorder.backgroundColor = [[UIColor lightGrayColor] CGColor];
    [button.layer addSublayer:topBorder];
    
    [self addSubview:button];

}

- (void)renderPurchaseButton
{
    // Keep it hidden until the payment form is correct
    self.purchaseButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [self.purchaseButton setTitle:@"Submit" forState:UIControlStateNormal];
    [self.purchaseButton.titleLabel setFont:[UIFont boldSystemFontOfSize:17]];
    [self.purchaseButton setFrame:CGRectMake(self.bounds.size.width / 2, self.bounds.size.height - 50,
                                              self.bounds.size.width / 2, 50)];
    self.purchaseButton.enabled = false;
    [self.purchaseButton setTag:PAYMENT_INFO_TAG];
    CALayer *topBorder = [CALayer layer];
    topBorder.frame = CGRectMake(0, 0, self.purchaseButton.frame.size.width, 0.5f);
    topBorder.backgroundColor = [[UIColor lightGrayColor] CGColor];
    [self.purchaseButton.layer addSublayer:topBorder];
    [self.purchaseButton addTarget:self action:@selector(purchaseButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:self.purchaseButton];
}

# pragma mark Stripe View Delegate Methods

- (void)stripeView:(STPView *)view withCard:(PKCard *)card isValid:(BOOL)valid
{
    self.purchaseButton.enabled = true;
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
