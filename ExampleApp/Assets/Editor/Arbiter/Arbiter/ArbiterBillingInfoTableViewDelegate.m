//
//  ArbiterBillingInfoTableViewDelegate.m
//  Unity-iPhone
//
//  Created by Andy Zinsser on 9/4/14.
//
//

#import "ArbiterBillingInfoTableViewDelegate.h"
#import "STPView.h"


@implementation ArbiterBillingInfoTableViewDelegate
{
    STPView *_stripeView;
}

- (id)initWithStripeView:(STPView *)stripeView
{
    self = [super init];
    if ( self ) {
        _stripeView = stripeView;
    }
    return self;
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

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return @"Please enter your billing info";
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *i = @"BillingInfoCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:i];
    CALayer *topBorder = [CALayer layer];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:i];
        [cell setBackgroundColor:[UIColor clearColor]];
        [cell.contentView addSubview:_stripeView];
        [_stripeView.paymentView.cardNumberField becomeFirstResponder];
    }
    topBorder.frame = CGRectMake(0.0, 0.0, cell.frame.size.width + 80.0, 0.5f);
    topBorder.backgroundColor = [[UIColor whiteColor] CGColor];
    [cell.contentView.layer addSublayer:topBorder];
    return cell;
}

@end
