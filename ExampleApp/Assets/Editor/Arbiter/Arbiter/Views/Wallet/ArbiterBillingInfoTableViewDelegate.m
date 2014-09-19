//
//  ArbiterBillingInfoTableViewDelegate.m
//  Unity-iPhone
//
//  Created by Andy Zinsser on 9/4/14.
//
//

#import "ArbiterBillingInfoTableViewDelegate.h"
#import "PTKView.h"


@implementation ArbiterBillingInfoTableViewDelegate

- (id)initWithStripeView:(PTKView *)stripeView
{
    self = [super init];
    if ( self ) {
        self.stripeView = stripeView;
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
        [cell.contentView addSubview:self.stripeView];
        [self.stripeView.cardNumberField becomeFirstResponder];
    }
    CALayer *topBorder = [CALayer layer];
    topBorder.frame = CGRectMake(0.0, 0.0, cell.frame.size.width + 80.0, 0.5f);
    topBorder.backgroundColor = [[UIColor whiteColor] CGColor];
    topBorder.opacity = 0.2;
    [cell.contentView.layer addSublayer:topBorder];
    return cell;
}

@end
