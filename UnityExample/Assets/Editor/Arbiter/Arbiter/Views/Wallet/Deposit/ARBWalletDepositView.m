//
//  ArbiterWalletDepsitView.m
//  Unity-iPhone
//
//  Created by Andy Zinsser on 9/4/14.
//
//

#import "ARBWalletDepositView.h"
#import "ARBConstants.h"
#import "ARBUITableView.h"
#import "ARBBundleSelectView.h"
#import "ARBDepositInfoView.h"
#import "ARBCardPaymentView.h"
#import "ARBTransactionSuccessView.h"
#import "ARBTracking.h"

#define BUNDLE_SELECT_VIEW_TAG 1
#define CONTACT_INFO_VIEW_TAG 2
#define PAYMENT_INFO_VIEW_TAG 3
#define SUCCESS_MESSAGE_VIEW_TAG 4

#define GET_BUNDLE_REQUEST_TAG 10
#define POST_DEPOSIT_REQUEST_TAG 11



@implementation ARBWalletDepositView

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
    [self removeUIWithTag:PAYMENT_INFO_VIEW_TAG];
    [self.nextButton removeFromSuperview];
    self.childDelegate = nil;
    
    if ( self.purchaseCompleted ) {
        [self.parentDelegate handleBackButton];
    } else if ( self.activeViewIndex == BUNDLE_SELECT_VIEW_TAG ) {
        [self setupBundleSelect];
    } else if ( self.activeViewIndex == CONTACT_INFO_VIEW_TAG ) {
        [self setupContactInfoLayout];
    } else if ( self.activeViewIndex == PAYMENT_INFO_VIEW_TAG ) {
        [self setupCreditCardInfoLayout];
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
        ARBUITableView *tableView = [[ARBUITableView alloc] initWithFrame:CGRectMake(0.0, 60.0, self.frame.size.width, 160.0)];
        NSMutableArray *availableBundles = [[NSMutableArray alloc] initWithArray:[responseDict objectForKey:@"bundles"]];
        ARBBundleSelectView *tableDelegate = [[ARBBundleSelectView alloc] initWithBundles:availableBundles andSelectionCallback:[^(NSDictionary *selectedBundle) {
            self.selectedBundle = selectedBundle;
            self.activeViewIndex++;
            [self navigateToActiveView];
        } copy]];
        
        tableView.delegate = tableDelegate;
        tableView.dataSource = tableDelegate;
        tableView.scrollEnabled = YES;
        tableView.allowsSelection = YES;
        tableView.tag = BUNDLE_SELECT_VIEW_TAG;
        self.childDelegate = tableDelegate;
        [tableView reloadData];
        [self addSubview:tableView];
    } copy]];
}

- (void)setupContactInfoLayout
{
    ARBUITableView *tableView = [[ARBUITableView alloc] initWithFrame:CGRectMake(0.0, 60.0, self.frame.size.width, 180.0)];
    ARBDepositInfoView *tableDelegate = [[ARBDepositInfoView alloc] initWithCallback:[^(NSDictionary *updatedFields) {
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
    ARBCardPaymentView *paymentView = [[ARBCardPaymentView alloc] init];
    ARBUITableView *tableView = [[ARBUITableView alloc] initWithFrame:CGRectMake(0.0, 60.0, self.frame.size.width, 80.0)];
    paymentView.bundle = self.selectedBundle;
    paymentView.email = self.email;
    paymentView.username = self.username;
    paymentView.arbiter = self.arbiter;
    paymentView.onAuthorizationSuccess = ^(void) {
        [self renderNextButtonWithText:@"Submit"];
    };
    paymentView.onPaymentSuccess = ^(void) {
        self.activeViewIndex++;
        [self navigateToActiveView];
    };
    self.childDelegate = paymentView;
    tableView.delegate = paymentView;
    tableView.dataSource = paymentView;
    tableView.tag = PAYMENT_INFO_VIEW_TAG;
    [tableView reloadData];
    [self addSubview:tableView];
    [[ARBTracking arbiterInstance] track:@"Displayed Credit Card View"];
}

- (void)setupSuccessMessage
{
    ARBTransactionSuccessView *tableDelegate = [[ARBTransactionSuccessView alloc]
                                                          initWithCallback:[^(void) {
        [self.parentDelegate handleBackButton];
    } copy]];
    
    ARBUITableView *tableView = [[ARBUITableView alloc] initWithFrame:CGRectMake(0.0, 60.0, self.frame.size.width, 140.0)];
    self.childDelegate = tableDelegate;
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

- (void)handleError:(NSString *)error
{
    UIAlertView *message = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error", @"Error")
                                                      message:error
                                                     delegate:nil
                                            cancelButtonTitle:NSLocalizedString(@"OK", @"OK")
                                            otherButtonTitles:nil];
    [message show];
}


# pragma mark Click Handlers

- (void)nextButtonClicked:(id)sender
{
    if ( [self.childDelegate respondsToSelector:@selector(handleNextButton)] ) {
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
        if ( [self.childDelegate respondsToSelector:@selector(handleBackButton)] ) {
            [self.childDelegate handleBackButton];
        }
        self.activeViewIndex--;
        [self navigateToActiveView];
    }
}



@end
