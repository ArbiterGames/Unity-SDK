//
//  ARBPaymentOptionsView.m
//  Unity-iPhone
//
//  Created by Andy Zinsser on 9/20/14.
//
//

#import "ARBPaymentOptionsView.h"

#define BUTTON_TAG 1


@implementation ARBPaymentOptionsView

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
    return 2;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 70.0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 0.0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *i = @"PaymentOptionsCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:i];
    UIImage *applePayButton = [UIImage imageNamed:@"ApplePayBTN_32pt__white_textLogo_@3x"];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:i];
        [cell setBackgroundColor:[UIColor clearColor]];
        
        UIButton *button = [UIButton buttonWithType:UIButtonTypeSystem];
        [button setFrame:CGRectMake(cell.frame.size.width / 2 - 140, 0.0, 280.0, 64.0)];
        [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        button.tag = BUTTON_TAG;
        [cell.contentView addSubview:button];
        
        if ( indexPath.row == 0 ) {
            [button setTitle:@"" forState:UIControlStateNormal];
            [button setBackgroundImage:applePayButton forState:UIControlStateNormal];
            [button addTarget:self action:@selector(applePayClicked:) forControlEvents:UIControlEventTouchUpInside];
        } else if ( indexPath.row == 1 ) {
            [button setTitle:@"or buy with other payment methods" forState:UIControlStateNormal];
            button.titleLabel.textAlignment = NSTextAlignmentCenter;
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
