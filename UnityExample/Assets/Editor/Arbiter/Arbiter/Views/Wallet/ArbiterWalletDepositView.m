//
//  ArbiterWalletDepsitView.m
//  Unity-iPhone
//
//  Created by Andy Zinsser on 9/4/14.
//
//

#import "ArbiterConstants.h"
#import "ArbiterUITableView.h"
#import "ArbiterWalletDepositView.h"
#import "ArbiterBundleSelectView.h"
#import "ArbiterContactInfoTableViewDelegate.h"
#import "ArbiterPaymentOptionsTableViewDelegate.h"
#import "ArbiterBillingInfoTableViewDelegate.h"
#import "ArbiterTransactionSuccessTableViewDelegate.h"
#import "PTKView.h"
#import "STPCard.h"
#import "Stripe.h"
#import "ArbiterTracking.h"

#define BUNDLE_SELECT_VIEW_TAG 1
#define CONTACT_INFO_VIEW_TAG 2
#define CARD_INFO_VIEW_TAG 3
#define GET_TOKEN_VIEW_TAG 4
#define SUCCESS_MESSAGE_VIEW_TAG 5

#define GET_BUNDLE_REQUEST_TAG 10
#define POST_DEPOSIT_REQUEST_TAG 11



@implementation ArbiterWalletDepositView

@synthesize parentDelegate = _parentDelegate;
@synthesize childDelegate = _childDelegate;

- (id)initWithFrame:(CGRect)frame andArbiterInstance:(Arbiter *)arbiterInstance
{
    self = [super initWithFrame:frame];
    if ( self ) {
        self.arbiter = arbiterInstance;
        self.activeViewIndex = BUNDLE_SELECT_VIEW_TAG;
        [self renderBackButton];
        [self navigateToActiveView];
    }
    return self;
}

- (void)navigateToActiveView
{
    [self removeUIWithTag:BUNDLE_SELECT_VIEW_TAG];
    [self removeUIWithTag:CONTACT_INFO_VIEW_TAG];
    [self removeUIWithTag:CARD_INFO_VIEW_TAG];
    [self.nextButton removeFromSuperview];
    self.childDelegate = nil;
    
    if ( self.purchaseCompleted ) {
        [self.parentDelegate handleBackButton];
    } else if ( self.activeViewIndex == BUNDLE_SELECT_VIEW_TAG ) {
        [self setupBundleSelect];
    } else if ( self.activeViewIndex == CONTACT_INFO_VIEW_TAG ) {
        [self setupContactInfoLayout];
    } else if ( self.activeViewIndex == CARD_INFO_VIEW_TAG ) {
        [self setupCreditCardInfoLayout];
    } else if ( self.activeViewIndex == GET_TOKEN_VIEW_TAG ) {
        [self getTokenAndSubmitPayment];
    } else if ( self.activeViewIndex == SUCCESS_MESSAGE_VIEW_TAG ) {
        [self setupSuccessMessage];
    } else {
        [self.parentDelegate handleNextButton];
    }
}

- (void)onWalletUpdated:(NSMutableDictionary *)wallet
{
    // No-op, since the total is not actually displayed on this screen
}


# pragma mark Rendering methods

- (void)setupBundleSelect
{
    [self.arbiter httpGet:BundleURL isBlocking:YES handler:[^(NSDictionary *responseDict) {
        ArbiterUITableView *tableView = [[ArbiterUITableView alloc] initWithFrame:CGRectMake(0.0, 60.0, self.frame.size.width, 160.0)];
        NSMutableArray *availableBundles = [[NSMutableArray alloc] initWithArray:[responseDict objectForKey:@"bundles"]];
        ArbiterBundleSelectView *tableDelegate = [[ArbiterBundleSelectView alloc] initWithBundles:availableBundles andSelectionCallback:[^(NSDictionary *selectedBundle) {
            self.selectedBundle = selectedBundle;
            self.activeViewIndex++;
            [self navigateToActiveView];
        } copy]];
        
        tableView.delegate = tableDelegate;
        tableView.dataSource = tableDelegate;
        tableView.scrollEnabled = YES;
        tableView.allowsSelection = YES;
        tableView.tag = BUNDLE_SELECT_VIEW_TAG;
        [tableView reloadData];
        [self addSubview:tableView];
    } copy]];
}

- (void)setupContactInfoLayout
{
    ArbiterUITableView *tableView = [[ArbiterUITableView alloc] initWithFrame:CGRectMake(0.0, 60.0, self.frame.size.width, 180.0)];
    ArbiterContactInfoTableViewDelegate *tableDelegate = [[ArbiterContactInfoTableViewDelegate alloc] initWithCallback:[^(NSDictionary *updatedFields) {
            NSLog(@"contact info callback");
            self.email = [updatedFields objectForKey:@"email"];
            self.username = [updatedFields objectForKey:@"username"];
            self.activeViewIndex++;
            [self navigateToActiveView];
    } copy]];
    
    tableDelegate.email = [self.arbiter.user objectForKey:@"email"];
    tableDelegate.username = [self.arbiter.user objectForKey:@"username"];
    tableDelegate.tag = CONTACT_INFO_VIEW_TAG;
    [self renderNextButtonWithText:@"Next"];
    self.childDelegate = tableDelegate;
    
    tableView.delegate = tableDelegate;
    tableView.dataSource = tableDelegate;
    tableView.scrollEnabled = YES;
    tableView.tag = CONTACT_INFO_VIEW_TAG;
    [tableView reloadData];
    [self addSubview:tableView];
}

- (void)setupCreditCardInfoLayout
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
    tableView.tag = CARD_INFO_VIEW_TAG;
    [tableView reloadData];
    [self addSubview:tableView];
}


- (void)getTokenAndSubmitPayment
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
    
    [Stripe createTokenWithCard:card completion:[^(STPToken *stripeToken, NSError *error) {
        if (error) {
            [self handleError:[error localizedDescription]];
        } else {
            NSDictionary *params = @{@"card_token": stripeToken.tokenId,
                                     @"bundle_sku": [self.selectedBundle objectForKey:@"sku"],
                                     @"email": self.email,
                                     @"username": self.username};
            [[ArbiterTracking arbiterInstance] track:@"Submitted Deposit Billing Info"];
            [self.arbiter httpPost:APIDepositURL params:params isBlocking:YES handler:[^(NSDictionary *responseDict) {
                if ( [[responseDict objectForKey:@"errors"] count] ) {
                    NSString *message = [[responseDict objectForKey:@"errors"] objectAtIndex:0];
                    [[ArbiterTracking arbiterInstance] track:@"Received Deposit Error" properties:@{@"error": message}];
                    [self handleError:message];
                } else {
                    [[ArbiterTracking arbiterInstance] track:@"Received Deposit Success"];
                    self.arbiter.user = [responseDict objectForKey:@"user"];
                    self.activeViewIndex++;
                    [self navigateToActiveView];
                    self.purchaseCompleted = YES;
                }
                
            } copy]];
        }

    } copy]];
}

- (void)setupSuccessMessage
{
    ArbiterTransactionSuccessTableViewDelegate *tableDelegate = [[ArbiterTransactionSuccessTableViewDelegate alloc]
                                                          initWithCallback:[^(void) {
        [self.parentDelegate handleBackButton];
    } copy]];
    
    ArbiterUITableView *tableView = [[ArbiterUITableView alloc] initWithFrame:CGRectMake(0.0, 60.0, self.frame.size.width, 140.0)];
    tableView.delegate = tableDelegate;
    tableView.dataSource = tableDelegate;
    tableView.tag = SUCCESS_MESSAGE_VIEW_TAG;
    [tableView reloadData];
    [self addSubview:tableView];
    [self.backButton removeFromSuperview];
    [self renderNextButtonWithText:@"Close"];
}

- (void)renderNextButtonWithText:(NSString *)btnText
{
    if ( self.nextButton == nil ) {
        self.nextButton = [UIButton buttonWithType:UIButtonTypeSystem];
        float btnWidth = 80.0;
        float btnHeight = 50.0;
        [self.nextButton setFrame:CGRectMake(self.bounds.size.width - btnWidth, 5.0, btnWidth, btnHeight)];
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

- (void)removeUIWithTag:(int)tag
{
    for (UIView *view in [self subviews]) {
        if (view.tag == tag) {
            [view removeFromSuperview];
        }
    }
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
    if ( self.activeViewIndex == BUNDLE_SELECT_VIEW_TAG ) {
        [self.parentDelegate handleBackButton];
    } else {
        if ( self.childDelegate != nil ) {
            [self.childDelegate handleBackButton];
        }
        self.activeViewIndex--;
        [self navigateToActiveView];
    }
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

@end
