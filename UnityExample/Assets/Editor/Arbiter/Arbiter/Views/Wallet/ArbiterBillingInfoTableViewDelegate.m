//
//  ArbiterBillingInfoTableViewDelegate.m
//  Unity-iPhone
//
//  Created by Andy Zinsser on 9/4/14.
//
//

#import "ArbiterBillingInfoTableViewDelegate.h"
#import "PTKView.h"
#import "PTKTextField.h"
#import "STPCard.h"
#import "Stripe.h"
#import "ArbiterTracking.h"
#import "ArbiterConstants.h"


@implementation ArbiterBillingInfoTableViewDelegate

@synthesize pkView;

- (id)init
{
    self = [super init];
    if ( self ) {
        PTKView *view = [[PTKView alloc] initWithFrame:CGRectMake(0.0, 0.0, 290.0, 55.0)];
        self.pkView = view;
        self.pkView.delegate = self;
    }
    return self;
}

- (void)handleNextButton
{
    [self submitPaymentTokenToServer];
}

- (void)submitPaymentTokenToServer
{
    NSDictionary *params = @{@"card_token": self.stpToken.tokenId,
                             @"bundle_sku": [self.bundle objectForKey:@"sku"],
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
            self.onPaymentSuccess();
        }
    } copy]];
}

# pragma mark Stripe View Delegate Methods

- (void)paymentView:(PTKView *)view withCard:(PTKCard *)card isValid:(BOOL)valid
{
    STPCard *stpCard = [[STPCard alloc] init];
    stpCard.number = card.number;
    stpCard.expMonth = card.expMonth;
    stpCard.expYear = card.expYear;
    stpCard.cvc = card.cvc;
    
    [Stripe createTokenWithCard:stpCard completion:[^(STPToken *stpToken, NSError *error) {
        if (error) {
            [self handleError:[error localizedDescription]];
        } else {
            self.stpToken = stpToken;
            self.onAuthorizationSuccess();
        }
        
    } copy]];
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


# pragma mark TableView Delegate Methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 40.0;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UILabel *label = [[UILabel alloc] init];
    label.frame = CGRectMake(0.0, 10.0, tableView.frame.size.width, 20.0);
    label.font = [UIFont boldSystemFontOfSize:17.0];
    label.textColor = [UIColor whiteColor];
    label.text = @"Please enter your billing information";
    UIView *headerView = [[UIView alloc] init];
    [headerView addSubview:label];
    return headerView;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *i = @"BillingInfoCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:i];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:i];
        [cell setBackgroundColor:[UIColor clearColor]];
        [cell.contentView addSubview:self.pkView];
        [self.pkView.cardNumberField becomeFirstResponder];
    }
    CALayer *topBorder = [CALayer layer];
    topBorder.frame = CGRectMake(0.0, 0.0, cell.frame.size.width + 80.0, 0.5f);
    topBorder.backgroundColor = [[UIColor whiteColor] CGColor];
    topBorder.opacity = 0.2;
    [cell.contentView.layer addSublayer:topBorder];
    return cell;
}

@end
