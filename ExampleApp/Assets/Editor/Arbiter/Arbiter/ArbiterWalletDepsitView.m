//
//  ArbiterWalletDepsitView.m
//  Unity-iPhone
//
//  Created by Andy Zinsser on 9/4/14.
//
//

#import "ArbiterWalletDepsitView.h"
#import "Arbiter.h"
#import "ArbiterConstants.h"
#import "ArbiterBundleSelectTableViewDelegate.h"
#import "ArbiterContactInfoTableViewDelegate.h"
#import "ArbiterBillingInfoTableViewDelegate.h"

#define BUNDLE_SELECT_TAG 667
#define EMAIL_FIELD_TAG 668
#define GET_BUNDLE_REQUEST_TAG 671
#define POST_DEPOSIT_REQUEST_TAG 672


@implementation ArbiterWalletDepsitView
{
    Arbiter *_arbiter;
    NSDictionary *_selectedBundle;
    NSString *_email;
}


- (id)initWithFrame:(CGRect)frame andArbiterInstance:(Arbiter *)arbiterInstance
{
    self = [super initWithFrame:frame];
    if ( self ) {
        _arbiter = arbiterInstance;
        _email = [NSString stringWithFormat:@"%@", [_arbiter.user objectForKey:@"email"]];
        [self setupNextScreen];
    }
    return self;
}

- (void)setupNextScreen
{
    [self.nextButton removeFromSuperview];
    [self.cancelButton removeFromSuperview];
    
    [self hideBundleSelectUI];
    [self hideEmailFieldUI];
    
    if ( [_selectedBundle count] == 0 ) {
        [self setupBundleSelect];
    } else if ( _email == nil ) {
        [self setupEmailFieldLayout];
    } else if ( self.stripeView == nil ) {
        [self setupBillingInfoLayout];
    } else {
        [self getTokenAndSubmitPayment];
    }
}


# pragma mark Rendering methods

- (void)setupBundleSelect
{
    [self renderNextButton:NO];
    [_arbiter.alertWindow addRequestToQueue:GET_BUNDLE_REQUEST_TAG];
    [_arbiter httpGet:BundleURL handler:[^(NSDictionary *responseDict) {
        NSMutableArray *availableBundles = [[NSMutableArray alloc] initWithArray:[responseDict objectForKey:@"bundles"]];
        ArbiterBundleSelectView *selectView = [[ArbiterBundleSelectView alloc] initWithBundles:availableBundles andSelectionCallback:[^(NSDictionary *selectedBundle) {
            _selectedBundle = selectedBundle;
            [self setupNextScreen];
        } copy]];
        
        // TODO: Take this out once I get the button feeling right
        [self.nextButton setEnabled:YES];
        
        UITableView *tableView = [[UITableView alloc] initWithFrame:CGRectMake(0.0, 60.0, self.frame.size.width, 180.0) style:UITableViewStyleGrouped];
        [tableView setAutoresizingMask:UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth];
        [tableView setDelegate:selectView];
        [tableView setDataSource:selectView];
        [tableView setBackgroundColor:[UIColor clearColor]];
        [tableView setBackgroundView:nil];
        [tableView setSeparatorColor:[UIColor clearColor]];
        [tableView reloadData];
        [tableView setTag:BUNDLE_SELECT_TAG];
        [self addSubview:tableView];
        [[UILabel appearanceWhenContainedIn:[UITableViewHeaderFooterView class], nil] setFont:[UIFont boldSystemFontOfSize:17.0]];
        [[UILabel appearanceWhenContainedIn:[UITableViewHeaderFooterView class], nil] setTextColor:[UIColor whiteColor]];
        [_arbiter.alertWindow removeRequestFromQueue:GET_BUNDLE_REQUEST_TAG];
    } copy]];
}

- (void)setupEmailFieldLayout
{
    ArbiterContactInfoTableViewDelegate *delegate = [[ArbiterContactInfoTableViewDelegate alloc] initWithCallback:[^(NSString *email) {
        NSLog(@"setting _email to: %@", email);
        _email = email;
        [self setupNextScreen];
    } copy]];
    UITableView *tableView = [[UITableView alloc] initWithFrame:CGRectMake(0.0, 60.0, self.frame.size.width, 80.0) style:UITableViewStyleGrouped];
    [tableView setAutoresizingMask:UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth];
    [tableView setDelegate:delegate];
    [tableView setDataSource:delegate];
    [tableView setBackgroundColor:[UIColor clearColor]];
    [tableView setBackgroundView:nil];
    [tableView setSeparatorColor:[UIColor clearColor]];
    [tableView reloadData];
    [tableView setAllowsSelection:false];
    [tableView setScrollEnabled:false];
    [tableView setTag:EMAIL_FIELD_TAG];
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
    ArbiterBillingInfoTableViewDelegate *delegate = [[ArbiterBillingInfoTableViewDelegate alloc] initWithStripeView:self.stripeView];
    
    UITableView *tableView = [[UITableView alloc] initWithFrame:CGRectMake(0.0, 60.0, self.frame.size.width, 80.0) style:UITableViewStyleGrouped];
    [tableView setAutoresizingMask:UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth];
    [tableView setDelegate:delegate];
    [tableView setDataSource:delegate];
    [tableView setBackgroundColor:[UIColor clearColor]];
    [tableView setBackgroundView:nil];
    [tableView setSeparatorColor:[UIColor clearColor]];
    [tableView reloadData];
    [tableView setAllowsSelection:false];
    [tableView setScrollEnabled:false];
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

- (void)renderCancelButton
{
    self.cancelButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [self.cancelButton setFrame:CGRectMake(0, self.bounds.size.height, self.bounds.size.width / 2, 50)];
    [self.cancelButton setTitle:@"Cancel" forState:UIControlStateNormal];
    [self.cancelButton.titleLabel setFont:[UIFont systemFontOfSize:17]];
    [self.cancelButton addTarget:self action:@selector(cancelButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    
    CALayer *topBorder = [CALayer layer];
    topBorder.frame = CGRectMake(0, 0, self.cancelButton.frame.size.width, 0.5f);
    topBorder.backgroundColor = [[UIColor lightGrayColor] CGColor];
    [self.cancelButton.layer addSublayer:topBorder];
    
    CALayer *rightBorder = [CALayer layer];
    rightBorder.frame = CGRectMake(self.cancelButton.frame.size.width - 0.5f, 0, 0.5f, self.cancelButton.frame.size.height);
    rightBorder.backgroundColor = [[UIColor lightGrayColor] CGColor];
    [self.cancelButton.layer addSublayer:rightBorder];
    
    [self addSubview:self.cancelButton];
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


# pragma mark Click Handlers

- (void)nextButtonClicked:(id)sender
{
    [self setupNextScreen];
}

- (void)backButtonClicked:(id)sender
{
    NSLog(@"TODO: backButtonClicked");
//    [self animateOut];
//    [self endEditing:YES];
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
                                     @"email": _email};
            
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
