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
#import "ArbiterBundleSelectTableViewDelegate.h"
#import "ArbiterContactInfoTableViewDelegate.h"
#import "ArbiterBillingInfoTableViewDelegate.h"
#import "ArbiterTransactionSuccessTableViewDelegate.h"
#import <PassKit/PassKit.h>
#import "Stripe.h"

#define BUNDLE_SELECT_UI_TAG 667
#define CONTACT_INFO_UI_TAG 668
#define BILLING_INFO_UI_TAG 669
#define GET_BUNDLE_REQUEST_TAG 671
#define POST_DEPOSIT_REQUEST_TAG 672
#define SUCCESS_MESSAGE_UI_TAG 673


@implementation ArbiterWalletDepositView

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
    [self removeUIWithTag:BUNDLE_SELECT_UI_TAG];
    [self removeUIWithTag:CONTACT_INFO_UI_TAG];
    [self removeUIWithTag:BILLING_INFO_UI_TAG];
    
    if ( self.purchaseCompleted ) {
        [self.delegate handleBackButton];
    } else if ( self.activeViewIndex == 0 ) {
        [self setupBundleSelect];
    } else if ( self.activeViewIndex == 1 ) {
        [self setupContactInfoLayout];
    } else if ( self.activeViewIndex == 2 ) {
        [self setupBillingInfoLayout];
    } else if ( self.activeViewIndex == 3 ) {
        [self getTokenAndSubmitPayment];
    } else if ( self.activeViewIndex == 4 ) {
        [self setupSuccessMessage];
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
        NSMutableArray *availableBundles = [[NSMutableArray alloc] initWithArray:[responseDict objectForKey:@"bundles"]];
        ArbiterBundleSelectView *selectView = [[ArbiterBundleSelectView alloc] initWithBundles:availableBundles
                                                                          andSelectionCallback:[^(NSDictionary *selectedBundle) {
            self.selectedBundle = selectedBundle;
            self.activeViewIndex++;
            [self navigateToActiveView];
        } copy]];
        
        ArbiterUITableView *tableView = [[ArbiterUITableView alloc] initWithFrame:CGRectMake(0.0, 60.0, self.frame.size.width, 160.0)];
        tableView.delegate = selectView;
        tableView.dataSource = selectView;
        tableView.tag = BUNDLE_SELECT_UI_TAG;
        tableView.scrollEnabled = YES;
        tableView.allowsSelection = YES;
        [tableView reloadData];
        [self addSubview:tableView];
    } copy]];
}

- (void)setupContactInfoLayout
{
    ArbiterUITableView *tableView = [[ArbiterUITableView alloc] initWithFrame:CGRectMake(0.0, 60.0, self.frame.size.width, 180.0)];
    ArbiterContactInfoTableViewDelegate *tableDelegate = [[ArbiterContactInfoTableViewDelegate alloc] initWithCallback:[^(NSDictionary *updatedFields) {
        self.email = [updatedFields objectForKey:@"email"];
        self.username = [updatedFields objectForKey:@"username"];
        self.activeViewIndex++;
        [self navigateToActiveView];
    } copy]];
    
    tableDelegate.email = [self.arbiter.user objectForKey:@"email"];
    tableDelegate.username = [self.arbiter.user objectForKey:@"username"];
    tableView.delegate = tableDelegate;
    tableView.dataSource = tableDelegate;
    tableView.scrollEnabled = YES;
    tableView.tag = CONTACT_INFO_UI_TAG;
    [tableView reloadData];
    [self addSubview:tableView];
}

- (void)setupBillingInfoLayout
{
    // TODO: While building out the ApplePay flow, just replace all of this with the ApplePay flow
    NSLog(@"apple pay");
    PKPaymentRequest *request = [Stripe pay];
    
    //    NSString *stripePublishableKey;
//    if ( self.stripeView == nil ) {
//        if ( [[[self.arbiter game] objectForKey:@"is_live"] boolValue] == true ) {
//            stripePublishableKey = StripeLivePublishableKey;
//        } else {
//            stripePublishableKey = StripeTestPublishableKey;
//        }
//        self.stripeView = [[STPView alloc] initWithFrame:self.frame andKey:stripePublishableKey];
//        self.stripeView.delegate = self;
//    }
//    ArbiterBillingInfoTableViewDelegate *tableDelegate = [[ArbiterBillingInfoTableViewDelegate alloc]
//                                                          initWithStripeView:self.stripeView];
//    
//    ArbiterUITableView *tableView = [[ArbiterUITableView alloc] initWithFrame:CGRectMake(0.0, 60.0, self.frame.size.width, 80.0)];
//    tableView.delegate = tableDelegate;
//    tableView.dataSource = tableDelegate;
//    tableView.tag = BILLING_INFO_UI_TAG;
//    [tableView reloadData];
//    [self addSubview:tableView];
}

- (void)getTokenAndSubmitPayment
{
    [self.stripeView createToken:[^(STPToken *stripeToken, NSError *error) {
        if (error) {
            [self handleError:[error localizedDescription]];
        } else {
            NSDictionary *params = @{@"card_token": stripeToken.tokenId,
                                     @"bundle_sku": [self.selectedBundle objectForKey:@"sku"],
                                     @"email": self.email,
                                     @"username": self.username};
            [self.arbiter httpPost:APIDepositURL params:params isBlocking:YES handler:[^(NSDictionary *responseDict) {
                if ([[responseDict objectForKey:@"errors"] count]) {
                    [self handleError:[[responseDict objectForKey:@"errors"] objectAtIndex:0]];
                } else {
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
        [self.delegate handleBackButton];
    } copy]];
    
    ArbiterUITableView *tableView = [[ArbiterUITableView alloc] initWithFrame:CGRectMake(0.0, 60.0, self.frame.size.width, 140.0)];
    tableView.delegate = tableDelegate;
    tableView.dataSource = tableDelegate;
    tableView.tag = SUCCESS_MESSAGE_UI_TAG;
    [tableView reloadData];
    [self addSubview:tableView];
    [self.backButton removeFromSuperview];
    self.nextButton.titleLabel.text = @"Close";
}

- (void)renderNextButton
{
    self.nextButton = [UIButton buttonWithType:UIButtonTypeSystem];
    float btnWidth = 80.0;
    float btnHeight = 50.0;
    [self.nextButton setFrame:CGRectMake(self.bounds.size.width - btnWidth, 5.0, btnWidth, btnHeight)];
    [self.nextButton setTitle:@"Submit" forState:UIControlStateNormal];
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

@end
