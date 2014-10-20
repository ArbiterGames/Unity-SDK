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
#import "ArbiterBillingInfoTableViewDelegate.h"
#import "ArbiterTransactionSuccessTableViewDelegate.h"
#import "Stripe.h"
#import "PTKView.h"
#import "Mixpanel.h"

#define AMOUNT_SELECTION_UI_TAG 1
#define CONTACT_INFO_UI_TAG 2
#define BILLING_INFO_UI_TAG 3
#define TOKEN_REQUEST_UI_TAG 4
#define SUCCESS_MESSAGE_UI_TAG 5

#define POST_WITHDRAWAL_REQUEST_TAG 200


@implementation ArbiterWalletWithdrawView

@synthesize parentDelegate = _parentDelegate;
@synthesize childDelegate = _childDelegate;

- (id)initWithFrame:(CGRect)frame andArbiterInstance:(Arbiter *)arbiterInstance
{
    self = [super initWithFrame:frame];
    if ( self ) {
        self.arbiter = arbiterInstance;
        self.activeViewIndex = AMOUNT_SELECTION_UI_TAG;
        self.email = [self.arbiter.user objectForKey:@"email"];
        self.fullName = [self.arbiter.user objectForKey:@"full_name"];
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
    [self.nextButton removeFromSuperview];
    self.childDelegate = nil;
    
    if ( self.withdrawComplete ) {
        [self.parentDelegate handleBackButton];
    } else if ( self.activeViewIndex == AMOUNT_SELECTION_UI_TAG ) {
        [self setupAmountSelectionUI];
    } else if ( self.activeViewIndex == CONTACT_INFO_UI_TAG ) {
        [self setupContactInfoUI];
    } else if ( self.activeViewIndex == BILLING_INFO_UI_TAG ) {
        [[Mixpanel sharedInstance] track:@"Selected Withdraw Amount" properties:@{@"amount": [NSString stringWithFormat:@"%f", self.withdrawAmount]}];
        [self setupBillingInfoUI];
    } else if ( self.activeViewIndex == TOKEN_REQUEST_UI_TAG ) {
        [self getTokenAndSubmitWithdraw];
    } else if ( self.activeViewIndex == SUCCESS_MESSAGE_UI_TAG ) {
        [self setupSuccessMessageUI];
    } else {
        [self.parentDelegate handleNextButton];
    }
}

- (void)onWalletUpdated:(NSDictionary *)wallet
{
    // No-op, but as a polish feature we could rebuild the UI bar to have the new total. We'd need to consider the UX of doing something like that, though.
}


# pragma mark Render Methods

- (void)renderNextButtonWithText:(NSString *)btnText
{
    if ( self.nextButton == nil ) {
        self.nextButton = [UIButton buttonWithType:UIButtonTypeSystem];
        float btnWidth = 60.0;
        float btnHeight = 50.0;
        [self.nextButton setFrame:CGRectMake(self.bounds.size.width - btnWidth, 5.0, btnWidth, btnHeight)];
        [self.nextButton setTitle:btnText forState:UIControlStateNormal];
        [self.nextButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [self.nextButton addTarget:self action:@selector(nextButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
        self.nextButton.titleLabel.textAlignment = NSTextAlignmentRight;
        self.nextButton.titleLabel.font = [UIFont boldSystemFontOfSize:17.0];
    }
    [self.nextButton setTitle:btnText forState:UIControlStateNormal];
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
        UILabel *message = [[UILabel alloc] initWithFrame:CGRectMake(0.0, 70.0, self.frame.size.width, 100.0)];
        message.numberOfLines = 0;
        message.tag = AMOUNT_SELECTION_UI_TAG;
        message.textColor = [UIColor whiteColor];
        message.text = [NSString stringWithFormat:@"Your current wallet balance (%.f credits) is below the withdraw minimum (100 credits).", walletBalance];
        [self addSubview:message];
    } else {
        [self renderNextButtonWithText:@"Next"];
        
        UILabel *message = [[UILabel alloc] initWithFrame:CGRectMake(0.0, 70.0, self.bounds.size.width, 50.0)];
        message.numberOfLines = 0;
        message.text = @"How many credits would you like to withdraw?";
        message.textColor = [UIColor whiteColor];
        message.font = [UIFont boldSystemFontOfSize:17.0];
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
        self.withdrawSelectionLabel.textColor = [UIColor whiteColor];
        self.withdrawSelectionLabel.tag = AMOUNT_SELECTION_UI_TAG;
        [self addSubview:self.withdrawSelectionLabel];
        [self updateSelectedAmountLabel];
        
        self.withdrawValueLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0, 140.0, self.bounds.size.width, 20.0)];
        self.withdrawValueLabel.tag = AMOUNT_SELECTION_UI_TAG;
        self.withdrawValueLabel.textColor = [UIColor whiteColor];
        [self addSubview:self.withdrawValueLabel];
        [self updateWithdrawValueLabel];
    }
}

- (void)setupContactInfoUI
{
    ArbiterFullContactInfoTableViewDelegate *tableDelegate = [[ArbiterFullContactInfoTableViewDelegate alloc]
                                                              initWithCallback:[^(NSDictionary *updatedEmailAndName) {
        if ( [updatedEmailAndName isKindOfClass:[NSDictionary class]]) {
            self.email = [updatedEmailAndName objectForKey:@"email"];
            self.fullName = [updatedEmailAndName objectForKey:@"fullName"];
        }
        self.activeViewIndex++;
        [self navigateToActiveView];
    } copy]];
    tableDelegate.email = self.email;
    tableDelegate.fullName = self.fullName;
    self.childDelegate = tableDelegate;
    
    ArbiterUITableView *tableView = [[ArbiterUITableView alloc] initWithFrame:CGRectMake(0.0, 60.0, self.frame.size.width, 140.0)];
    tableView.scrollEnabled = YES;
    tableView.delegate = tableDelegate;
    tableView.dataSource = tableDelegate;
    tableView.tag = CONTACT_INFO_UI_TAG;
    [tableView reloadData];
    [self addSubview:tableView];
    [self renderNextButtonWithText:@"Next"];
}

- (void)setupBillingInfoUI
{
    if ( self.pkView == nil ) {
        PTKView *view = [[PTKView alloc] initWithFrame:CGRectMake(0.0, 0.0, 290.0, 55.0)];
        self.pkView = view;
        self.pkView.delegate = self;
    }
    
    ArbiterBillingInfoTableViewDelegate *tableDelegate = [[ArbiterBillingInfoTableViewDelegate alloc] init];
    tableDelegate.pkView = self.pkView;
    
    ArbiterUITableView *tableView = [[ArbiterUITableView alloc] initWithFrame:CGRectMake(0.0, 60.0, self.frame.size.width, 80.0)];
    tableView.delegate = tableDelegate;
    tableView.dataSource = tableDelegate;
    tableView.tag = BILLING_INFO_UI_TAG;
    [tableView reloadData];
    [self addSubview:tableView];
}

- (void)setupSuccessMessageUI
{
    ArbiterTransactionSuccessTableViewDelegate *tableDelegate = [[ArbiterTransactionSuccessTableViewDelegate alloc]
                                                                 initWithCallback:[^(void) {
        [self.parentDelegate handleBackButton];
    } copy]];
    ArbiterUITableView *tableView = [[ArbiterUITableView alloc] initWithFrame:CGRectMake(0.0, 60.0, self.frame.size.width, 140.0)];
    tableView.delegate = tableDelegate;
    tableView.dataSource = tableDelegate;
    tableView.tag = SUCCESS_MESSAGE_UI_TAG;
    [tableView reloadData];
    [self addSubview:tableView];
    [self.backButton removeFromSuperview];
    [self renderNextButtonWithText:@"Close"];
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
    STPCard *card = [[STPCard alloc] init];
    card.number = self.pkView.card.number;
    card.expMonth = self.pkView.card.expMonth;
    card.expYear = self.pkView.card.expYear;
    card.cvc = self.pkView.card.cvc;
    
    if ( [[[self.arbiter game] objectForKey:@"is_live"] boolValue] == true ) {
        [Stripe setDefaultPublishableKey:StripeLivePublishableKey];
    } else {
        [Stripe setDefaultPublishableKey:StripeTestPublishableKey];
    }
    
    [Stripe createTokenWithCard:card completion:[^(STPToken *token, NSError *error) {
        if (error) {
            [self handleError:[error localizedDescription]];
        } else {
            NSDictionary *params = @{@"card_token": token.tokenId,
                                     @"amount": [NSString stringWithFormat:@"%.0f", self.withdrawAmount],
                                     @"email": self.email,
                                     @"card_name": self.fullName};
            [self.arbiter httpPost:APIWithdrawURL params:params isBlocking:YES handler:[^(NSDictionary *responseDict) {
                if ([[responseDict objectForKey:@"errors"] count]) {
                    NSString *message = [[responseDict objectForKey:@"errors"] objectAtIndex:0];
                    [[Mixpanel sharedInstance] track:@"Received Withdraw Error" properties:@{@"error": message}];
                    [self handleError:message];
                    [self.nextButton removeFromSuperview];
                    self.activeViewIndex--;
                    [self navigateToActiveView];
                } else {
                    [[Mixpanel sharedInstance] track:@"Received Withdraw Success"];
                    self.arbiter.wallet = [responseDict objectForKey:@"wallet"];
                    self.arbiter.user = [responseDict objectForKey:@"user"];
                    self.activeViewIndex++;
                    [self navigateToActiveView];
                    self.withdrawComplete = YES;
                }
                
                
            } copy]];
        }
    } copy]];
}


# pragma mark Click Handlers

- (void)nextButtonClicked:(id)sender
{
    if ( self.childDelegate ) {
        [self.childDelegate handleNextButton];
    } else {
        self.activeViewIndex++;
        [self navigateToActiveView];
    }
}

- (void)backButtonClicked:(id)sender
{
    if ( self.activeViewIndex == 0 ) {
        [self.parentDelegate handleBackButton];
    } else {
        if ( self.childDelegate ) {
            [self.childDelegate handleBackButton];
        }
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

- (void)paymentView:(PTKView *)view withCard:(PTKCard *)card isValid:(BOOL)valid
{
    [self renderNextButtonWithText:@"Submit"];
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
