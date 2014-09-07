//
//  ArbiterWalletWithdrawView.m
//  Unity-iPhone
//
//  Created by Andy Zinsser on 9/4/14.
//
//

#import "Arbiter.h"
#import "ArbiterConstants.h"
#import "ArbiterUITableView.h"
#import "ArbiterWalletWithdrawView.h"
#import "ArbiterFullContactInfoTableViewDelegate.h"

#define AMOUNT_SELECTION_UI_TAG 100
#define CONTACT_INFO_UI_TAG 101
#define BILLING_INFO_UI_TAG 102
#define SUCCESS_MESSAGE_UI_TAG 103

#define POST_WITHDRAWAL_REQUEST_TAG 200


@implementation ArbiterWalletWithdrawView

@synthesize delegate = _delegate;

- (id)initWithFrame:(CGRect)frame andArbiterInstance:(Arbiter *)arbiterInstance
{
    self = [super initWithFrame:frame];
    if ( self ) {
        self.arbiter = arbiterInstance;
        self.activeViewIndex = 0;
        [self renderBackButton];
        [self navigateToActiveView];
    }
    return self;
}

- (void)navigateToActiveView
{
    [self removeUIWithTag:AMOUNT_SELECTION_UI_TAG];
    [self removeUIWithTag:CONTACT_INFO_UI_TAG];
    [self removeUIWithTag:BILLING_INFO_UI_TAG];
    [self removeUIWithTag:SUCCESS_MESSAGE_UI_TAG];
    
    if ( self.withdrawComplete ) {
        [self.delegate handleBackButton];
    } else if ( self.activeViewIndex == 0 ) {
        [self setupAmountSelectionUI];
    } else if ( self.activeViewIndex == 1 ) {
        [self setupContactInfoUI];
    } else if ( self.activeViewIndex == 2 ) {
        [self setupBillingInfoUI];
    } else if ( self.activeViewIndex == 3 ) {
        [self getTokenAndSubmitWithdraw];
    } else if ( self.activeViewIndex == 4 ) {
        [self setupSuccessMessageUI];
    }
}


# pragma mark Render Methods

- (void)renderNextButton
{
    self.nextButton = [UIButton buttonWithType:UIButtonTypeSystem];
    float btnWidth = 80.0;
    float btnHeight = 50.0;
    [self.nextButton setFrame:CGRectMake(self.bounds.size.width - btnWidth, 5.0, btnWidth, btnHeight)];
    [self.nextButton setTitle:@"Next" forState:UIControlStateNormal];
    [self.nextButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.nextButton addTarget:self action:@selector(nextButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    self.nextButton.titleLabel.textAlignment = NSTextAlignmentRight;
    self.nextButton.titleLabel.font = [UIFont boldSystemFontOfSize:17.0];
    [self addSubview:self.nextButton];
}

- (void)renderBackButton
{
    self.backButton = [UIButton buttonWithType:UIButtonTypeSystem];
    float btnWidth = 50.0;
    float btnHeight = 50.0;
    [self.backButton setFrame:CGRectMake(0.0, 5.0, btnWidth, btnHeight)];
    [self.backButton setTitle:@"Back" forState:UIControlStateNormal];
    [self.backButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.backButton addTarget:self action:@selector(backButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    self.backButton.titleLabel.textAlignment = NSTextAlignmentLeft;
    self.backButton.titleLabel.font = [UIFont boldSystemFontOfSize:17.0];
    [self addSubview:self.backButton];
}

- (void)setupAmountSelectionUI
{
    float walletBalance = [[[self.arbiter wallet] objectForKey:@"balance"] floatValue];
    self.withdrawAmount = ( self.withdrawAmount ) ? self.withdrawAmount : roundl(( walletBalance + 100.0 ) / 2);
    
    if ( walletBalance < 100 ) {
        UILabel *message = [[UILabel alloc] initWithFrame:CGRectMake(0.0, 70.0, self.frame.size.width, 50.0)];
        message.numberOfLines = 0;
        message.textAlignment = NSTextAlignmentCenter;
        message.tag = AMOUNT_SELECTION_UI_TAG;
        message.text = [NSString stringWithFormat:@"Your current wallet balance (%.f credits) is below the withdraw minimum.", walletBalance];
        [self addSubview:message];
    } else {
        [self renderNextButton];
        
        UILabel *message = [[UILabel alloc] initWithFrame:CGRectMake(0.0, 70.0, self.bounds.size.width, 50.0)];
        message.numberOfLines = 0;
        message.text = @"How many credits would you like to withdraw?";
        message.textColor = [UIColor whiteColor];
        message.textAlignment = NSTextAlignmentCenter;
        message.tag = AMOUNT_SELECTION_UI_TAG;
        [self addSubview:message];
        
        UISlider *slider = [[UISlider alloc] initWithFrame:CGRectMake(0.0, 140.0, self.bounds.size.width, 100.0)];
        [slider addTarget:self action:@selector(sliderAction:) forControlEvents:UIControlEventValueChanged];
        slider.tag = AMOUNT_SELECTION_UI_TAG;
        slider.minimumValue = 100.0;
        slider.maximumValue = walletBalance;
        slider.continuous = YES;
        slider.value = self.withdrawAmount;
        [self addSubview:slider];
        
        self.withdrawSelectionLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0, 120.0, self.bounds.size.width, 20.0)];
        self.withdrawSelectionLabel.textAlignment = NSTextAlignmentCenter;
        self.withdrawSelectionLabel.textColor = [UIColor whiteColor];
        self.withdrawSelectionLabel.tag = AMOUNT_SELECTION_UI_TAG;
        [self addSubview:self.withdrawSelectionLabel];
        [self updateSelectedAmountLabel];
        
        self.withdrawValueLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0, 140.0, self.bounds.size.width, 20.0)];
        self.withdrawValueLabel.textAlignment = NSTextAlignmentCenter;
        self.withdrawValueLabel.tag = AMOUNT_SELECTION_UI_TAG;
        self.withdrawValueLabel.textColor = [UIColor whiteColor];
        [self addSubview:self.withdrawValueLabel];
        [self updateWithdrawValueLabel];
    }
}

- (void)setupContactInfoUI
{
    ArbiterFullContactInfoTableViewDelegate *tableDelegate = [[ArbiterFullContactInfoTableViewDelegate alloc]
                                                              initWithCallback:[^(NSString *updatedEmail) {
        if ( [updatedEmail isKindOfClass:[NSString class]]) {
            self.email = updatedEmail;
        }
        self.activeViewIndex++;
        [self navigateToActiveView];
    } copy]];
    
    tableDelegate.email = [self.arbiter.user objectForKey:@"email"];
    tableDelegate.fullName = [self.arbiter.user objectForKey:@"full_name"];
    ArbiterUITableView *tableView = [[ArbiterUITableView alloc] initWithFrame:CGRectMake(0.0, 60.0, self.frame.size.width, 140.0)];
    tableView.scrollEnabled = YES;
    tableView.delegate = tableDelegate;
    tableView.dataSource = tableDelegate;
    tableView.tag = CONTACT_INFO_UI_TAG;
    [tableView reloadData];
    [self addSubview:tableView];
}

- (void)setupBillingInfoUI
{
    NSString *stripePublishableKey;
    
    if ( [[[self.arbiter game] objectForKey:@"is_live"] boolValue] == true ) {
        stripePublishableKey = StripeLivePublishableKey;
    } else {
        stripePublishableKey = StripeTestPublishableKey;
    }
    
    // TODO: Move this into an ArbiterTableView
    self.stripeView = [[STPView alloc] initWithFrame:CGRectMake((self.frame.size.width) / 2, 40.0f,
                                                                self.frame.size.width, 40.0f)
                                              andKey:stripePublishableKey];
    self.stripeView.delegate = self;
    [self addSubview:self.stripeView];
}

- (void)setupSuccessMessageUI
{
    NSLog(@"TODO: success message UI");
    [self.backButton removeFromSuperview];
    self.nextButton.titleLabel.text = @"Close";
}

- (void)removeUIWithTag:(int)tag
{
    for (UIView *view in [self subviews]) {
        if (view.tag == tag) {
            [view removeFromSuperview];
        }
    }
}

- (void)getTokenAndSubmitWithdraw
{
    [self.arbiter.alertWindow addRequestToQueue:POST_WITHDRAWAL_REQUEST_TAG];
    [self setHidden:YES];
    [self.stripeView createToken:^(STPToken *token, NSError *error) {
//        NSDictionary *params;
//        NSMutableDictionary *mutableParams;
        
        if (error) {
            [self.arbiter.alertWindow removeRequestFromQueue:POST_WITHDRAWAL_REQUEST_TAG];
            [self handleError:[error localizedDescription]];
            [self setHidden:NO];
        } else {
            
            NSDictionary *params = @{@"card_token": token.tokenId,
                                     @"amount": [NSString stringWithFormat:@"%.0f", self.withdrawAmount],
                                     @"email": self.email,
                                     @"card_name": self.fullName};
//            mutableParams = [NSMutableDictionary dictionaryWithObjects: @[token.tokenId, [NSString stringWithFormat:@"%.0f", self.withdrawAmount]]
//                                                               forKeys:@[@"card_token", @"amount"]];
//            
//            if ( self.emailField != nil ) {
//                [mutableParams setObject:self.emailField.text forKey:@"email"];
//            }
//            
//            if ( self.nameField != nil ) {
//                [mutableParams setObject:self.nameField.text forKey:@"card_name"];
//            }
            
//            params = [mutableParams copy];
            [self.arbiter httpPost:APIWithdrawURL params:params handler:[^(NSDictionary *responseDict) {
                [self.arbiter.alertWindow removeRequestFromQueue:POST_WITHDRAWAL_REQUEST_TAG];
                if ([[responseDict objectForKey:@"errors"] count]) {
                    [self handleError:[[responseDict objectForKey:@"errors"] objectAtIndex:0]];
                } else {
                    self.arbiter.wallet = [responseDict objectForKey:@"wallet"];
                    self.arbiter.user = [responseDict objectForKey:@"user"];
                    self.activeViewIndex++;
                    [self navigateToActiveView];
                }
            } copy]];
        }
    }];
}


# pragma mark Click Handlers

- (void)nextButtonClicked:(id)sender
{
    self.activeViewIndex++;
    [self navigateToActiveView];
}

- (void)backButtonClicked:(id)sender
{
    if ( self.activeViewIndex == 0 ) {
        [self.delegate handleBackButton];
    } else {
        self.activeViewIndex--;
        [self navigateToActiveView];
    }
}

- (void)sliderAction:(id)sender
{
    UISlider *slider = (UISlider*)sender;
    int rounded = roundl(slider.value);
    slider.value = (float)rounded;
    self.withdrawAmount = rounded;
    [self updateSelectedAmountLabel];
    [self updateWithdrawValueLabel];
}


# pragma mark Stripe View Delegate Methods

- (void)stripeView:(STPView *)view withCard:(PKCard *)card isValid:(BOOL)valid
{
    [self renderNextButton];
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


# pragma mark Helpers

- (void)updateSelectedAmountLabel
{
    self.withdrawSelectionLabel.text = [NSString stringWithFormat:@"%.0f credits", self.withdrawAmount];
}

- (void)updateWithdrawValueLabel
{
    self.withdrawValueLabel.text = [NSString stringWithFormat:@"$%.02f", self.withdrawAmount / 100.0f];
}

@end
