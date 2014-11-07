//
//  ARBWalletInfoView.m
//  Unity-iPhone
//
//  Created by Andy Zinsser on 9/10/14.
//
//

#import "ARBWalletInfoView.h"

#define CELL_MESSAGE_TAG 1


@implementation ARBWalletInfoView


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
    return 0.1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 180.0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *i = @"WalletInfoTableCell";
    UILabel *message;
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:i];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:i];
        cell.backgroundColor = [UIColor clearColor];
        message = [[UILabel alloc] initWithFrame:CGRectMake(0.0, 0.0, cell.frame.size.width - 20.0, 180.0)];
        message.textColor = [UIColor whiteColor];
        message.numberOfLines = 0;
        [cell.contentView addSubview:message];
    } else {
        message = (UILabel *)[cell.contentView viewWithTag:CELL_MESSAGE_TAG];
    }
    
    message.text = @"Your wallet stores your entry fee credits.\n\nYou can purchase credits using the BUY CREDITS button below.\n\nUse the CASH OUT button to withdraw your credits to a debit card.";
    
    return cell;
}

@end
