//
//  ArbiterPaymentOptionsTableViewDelegate.m
//  Unity-iPhone
//
//  Created by Andy Zinsser on 9/20/14.
//
//

#import "ArbiterPaymentOptionsTableViewDelegate.h"

#define BUTTON_TAG 1


@implementation ArbiterPaymentOptionsTableViewDelegate

- (id)initWithCallback:(void(^)(NSString *))callback
{
    self = [super init];
    if ( self ) {
        self.callback = callback;
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
    return 4;
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
    label.text = @"Select payment method";
    UIView *headerView = [[UIView alloc] init];
    [headerView addSubview:label];
    return headerView;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *i = @"PaymentOptionsCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:i];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:i];
        [cell setBackgroundColor:[UIColor clearColor]];
        
        UIButton *button = [UIButton buttonWithType:UIButtonTypeSystem];
        [button setFrame:CGRectMake(0.0 , 0.0, cell.frame.size.width, cell.frame.size.height)];
        [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        button.tag = BUTTON_TAG;
        [cell.contentView addSubview:button];
        
        CALayer *topBorder = [CALayer layer];
        topBorder.frame = CGRectMake(0.0, 0.0, cell.frame.size.width, 0.5f);
        topBorder.backgroundColor = [[UIColor whiteColor] CGColor];
        topBorder.opacity = 0.2;
        [cell.contentView.layer addSublayer:topBorder];
        
        if ( indexPath.row == 0 ) {
            [button setTitle:@"ApplePay" forState:UIControlStateNormal];
            [button addTarget:self action:@selector(applePayClicked:) forControlEvents:UIControlEventTouchUpInside];
        } else if ( indexPath.row == 1 ) {
            [button setTitle:@"Credit or Debit Card" forState:UIControlStateNormal];
            [button addTarget:self action:@selector(creditCardClicked:) forControlEvents:UIControlEventTouchUpInside];
        }
    }
    
    return cell;
}


# pragma mark Click Handlers

- (void)applePayClicked:(id)sender
{
    self.callback(@"ApplePay");
}

- (void)creditCardClicked:(id)sender
{
    self.callback(@"CreditCard");
}

@end
