//
//  ArbiterWalletDepsitView.m
//  Unity-iPhone
//
//  Created by Andy Zinsser on 9/4/14.
//
//

#import "ArbiterWalletDepositView.h"
#import "Arbiter.h"
#import "ArbiterConstants.h"
#import "ArbiterBundleSelectTableViewDelegate.h"
#import "ArbiterContactInfoTableViewDelegate.h"
#import "ArbiterBillingInfoTableViewDelegate.h"

#define BUNDLE_SELECT_UI_TAG 667
#define CONTACT_INFO_UI_TAG 668
#define BILLING_INFO_UI_TAG 669
#define GET_BUNDLE_REQUEST_TAG 671
#define POST_DEPOSIT_REQUEST_TAG 672


@implementation ArbiterWalletDepositView
{
    Arbiter *_arbiter;
    NSDictionary *_selectedBundle;
    int _activeViewIndex;
}

@synthesize email;
@synthesize delegate;


- (id)initWithFrame:(CGRect)frame andArbiterInstance:(Arbiter *)arbiterInstance
{
    self = [super initWithFrame:frame];
    if ( self ) {
        _arbiter = arbiterInstance;
        _activeViewIndex = 0;
        [self renderBackButton];
    }
    return self;
}

- (void)navigateToActiveView
{
    self.stripeView = nil;
    [self.nextButton removeFromSuperview];
    [self removeBundleSelectUI];
    [self removeContactInfoUI];
    [self removeBillingInfoUI];
    
    if ( _activeViewIndex == 0 ) {
        [self setupBundleSelect];
    } else if ( _activeViewIndex == 1 ) {
        [self setupEmailFieldLayout];
    } else if ( _activeViewIndex == 2 ) {
        [self setupBillingInfoLayout];
    } else {
        [self getTokenAndSubmitPayment];
    }
}


# pragma mark Rendering methods

- (void)setupBundleSelect
{
    [_arbiter.alertWindow addRequestToQueue:GET_BUNDLE_REQUEST_TAG];
    [_arbiter httpGet:BundleURL handler:[^(NSDictionary *responseDict) {
        NSMutableArray *availableBundles = [[NSMutableArray alloc] initWithArray:[responseDict objectForKey:@"bundles"]];
        ArbiterBundleSelectView *selectView = [[ArbiterBundleSelectView alloc] initWithBundles:availableBundles
                                                                          andSelectionCallback:[^(NSDictionary *selectedBundle) {
            _selectedBundle = selectedBundle;
            _activeViewIndex++;
            [self navigateToActiveView];
        } copy]];
        
        UITableView *tableView = [[UITableView alloc] initWithFrame:CGRectMake(0.0, 60.0, self.frame.size.width, 180.0) style:UITableViewStyleGrouped];
        [tableView setAutoresizingMask:UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth];
        [tableView setDelegate:selectView];
        [tableView setDataSource:selectView];
        [tableView setBackgroundColor:[UIColor clearColor]];
        [tableView setBackgroundView:nil];
        [tableView setSeparatorColor:[UIColor clearColor]];
        [tableView reloadData];
        [tableView setTag:BUNDLE_SELECT_UI_TAG];
        [self addSubview:tableView];
        [[UILabel appearanceWhenContainedIn:[UITableViewHeaderFooterView class], nil] setFont:[UIFont boldSystemFontOfSize:17.0]];
        [[UILabel appearanceWhenContainedIn:[UITableViewHeaderFooterView class], nil] setTextColor:[UIColor whiteColor]];
        [_arbiter.alertWindow removeRequestFromQueue:GET_BUNDLE_REQUEST_TAG];
    } copy]];
}

- (void)setupEmailFieldLayout
{
    ArbiterContactInfoTableViewDelegate *tableDelegate = [[ArbiterContactInfoTableViewDelegate alloc]
                                                          initWithCallback:[^(NSString *updatedEmail) {
        self.email = updatedEmail;
        _activeViewIndex++;
        [self navigateToActiveView];
    } copy]];
    tableDelegate.email = [_arbiter.user objectForKey:@"email"];
    
    UITableView *tableView = [[UITableView alloc] initWithFrame:CGRectMake(0.0, 60.0, self.frame.size.width, 80.0) style:UITableViewStyleGrouped];
    [tableView setAutoresizingMask:UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth];
    [tableView setDelegate:tableDelegate];
    [tableView setDataSource:tableDelegate];
    [tableView setBackgroundColor:[UIColor clearColor]];
    [tableView setBackgroundView:nil];
    [tableView setSeparatorColor:[UIColor clearColor]];
    [tableView reloadData];
    [tableView setAllowsSelection:false];
    [tableView setScrollEnabled:false];
    [tableView setTag:CONTACT_INFO_UI_TAG];
    [self addSubview:tableView];
    [[UILabel appearanceWhenContainedIn:[UITableViewHeaderFooterView class], nil] setFont:[UIFont boldSystemFontOfSize:17.0]];
    [[UILabel appearanceWhenContainedIn:[UITableViewHeaderFooterView class], nil] setTextColor:[UIColor whiteColor]];
}

- (void)setupBillingInfoLayout
{
    NSString *stripePublishableKey;
    [self renderNextButton:NO];

    if ( [[[_arbiter game] objectForKey:@"is_live"] boolValue] == true ) {
        stripePublishableKey = StripeLivePublishableKey;
    } else {
        stripePublishableKey = StripeTestPublishableKey;
    }
    self.stripeView = [[STPView alloc] initWithFrame:self.frame andKey:stripePublishableKey];
    self.stripeView.delegate = self;
    ArbiterBillingInfoTableViewDelegate *tableDelegate = [[ArbiterBillingInfoTableViewDelegate alloc]
                                                          initWithStripeView:self.stripeView];
    
    UITableView *tableView = [[UITableView alloc] initWithFrame:CGRectMake(0.0, 60.0, self.frame.size.width, 80.0) style:UITableViewStyleGrouped];
    [tableView setAutoresizingMask:UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth];
    [tableView setDelegate:tableDelegate];
    [tableView setDataSource:tableDelegate];
    [tableView setBackgroundColor:[UIColor clearColor]];
    [tableView setBackgroundView:nil];
    [tableView setSeparatorColor:[UIColor clearColor]];
    [tableView reloadData];
    [tableView setAllowsSelection:false];
    [tableView setScrollEnabled:false];
    [tableView setTag:BILLING_INFO_UI_TAG];
    [self addSubview:tableView];
    [[UILabel appearanceWhenContainedIn:[UITableViewHeaderFooterView class], nil] setFont:[UIFont boldSystemFontOfSize:17.0]];
    [[UILabel appearanceWhenContainedIn:[UITableViewHeaderFooterView class], nil] setTextColor:[UIColor whiteColor]];
}

- (void)renderNextButton:(BOOL)enabled
{
    // TODO: Put this and the back button at the top of the window
    self.nextButton = [UIButton buttonWithType:UIButtonTypeSystem];
    float btnWidth = 50.0;
    float btnHeight = 50.0;
    [self.nextButton setFrame:CGRectMake(self.bounds.size.width - btnWidth, 5.0, btnWidth, btnHeight)];
    [self.nextButton setTitle:@"Next" forState:UIControlStateNormal];
    [self.nextButton.titleLabel setFont:[UIFont boldSystemFontOfSize:17]];
    [self.nextButton addTarget:self action:@selector(nextButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self.nextButton setEnabled:enabled];
    [self addSubview:self.nextButton];
}

- (void)renderBackButton
{
    UIButton *backButton = [UIButton buttonWithType:UIButtonTypeSystem];
    float btnWidth = 50.0;
    float btnHeight = 50.0;
    [backButton setFrame:CGRectMake(0.0, 5.0, btnWidth, btnHeight)];
    [backButton setTitle:@"Back" forState:UIControlStateNormal];
    [backButton.titleLabel setTextAlignment:NSTextAlignmentLeft];
    [backButton.titleLabel setFont:[UIFont systemFontOfSize:17.0]];
    [backButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [backButton addTarget:self action:@selector(backButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:backButton];
    [self navigateToActiveView];
}

- (void)removeBundleSelectUI
{
    for (UIView *view in [self subviews]) {
        if (view.tag == BUNDLE_SELECT_UI_TAG) {
            [view removeFromSuperview];
        }
    }
}

- (void)removeContactInfoUI
{
    for ( UIView *view in [self subviews] ) {
        if ( view.tag == CONTACT_INFO_UI_TAG ) {
            [view removeFromSuperview];
        }
    }
}

- (void)removeBillingInfoUI
{
    for ( UIView *view in [self subviews] ) {
        if ( view.tag == BILLING_INFO_UI_TAG ) {
            [view removeFromSuperview];
        }
    }
}


# pragma mark Click Handlers

- (void)nextButtonClicked:(id)sender
{
    _activeViewIndex++;
    [self navigateToActiveView];
}

- (void)backButtonClicked:(id)sender
{
    if ( _activeViewIndex == 0 ) {
        [self.delegate handleBackButton];
    } else {
        _activeViewIndex--;
        [self navigateToActiveView];
    }
}

- (void)getTokenAndSubmitPayment
{
    [_arbiter.alertWindow addRequestToQueue:POST_DEPOSIT_REQUEST_TAG];
    [self.stripeView createToken:^(STPToken *token, NSError *error) {
        if (error) {
            [_arbiter.alertWindow removeRequestFromQueue:POST_DEPOSIT_REQUEST_TAG];
            [self handleError:[error localizedDescription]];
        } else {
            NSDictionary *params = @{@"card_token": token.tokenId,
                                     @"bundle_sku": [_selectedBundle objectForKey:@"sku"],
                                     @"email": self.email};
            
            [_arbiter httpPost:APIDepositURL params:params handler:[^(NSDictionary *responseDict) {
                [_arbiter.alertWindow removeRequestFromQueue:POST_DEPOSIT_REQUEST_TAG];
                if ([[responseDict objectForKey:@"errors"] count]) {
                    [self handleError:[[responseDict objectForKey:@"errors"] objectAtIndex:0]];
                } else {
                    NSLog(@"Plan out how to hide panel view");
                }
            } copy]];
        }
    }];
}


# pragma mark Stripe View Delegate Methods

- (void)stripeView:(STPView *)view withCard:(PKCard *)card isValid:(BOOL)valid
{
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

@end
