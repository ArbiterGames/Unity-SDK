//
//  ArbiterWalletInfoTableViewDelegate.m
//  Unity-iPhone
//
//  Created by Andy Zinsser on 9/10/14.
//
//

#import "ArbiterWalletInfoTableViewDelegate.h"

#define CELL_MESSAGE_TAG 1


@implementation ArbiterWalletInfoTableViewDelegate


# pragma mark TableView Delegate Methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 0.1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 200.0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *i = @"WalletInfoTableCell";
    UILabel *message;
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:i];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:i];
        cell.backgroundColor = [UIColor clearColor];
        message = [[UILabel alloc] initWithFrame:CGRectMake(0.0, 0.0, cell.frame.size.width, 220.0)];
        message.textColor = [UIColor whiteColor];
        message.numberOfLines = 0;
        [cell.contentView addSubview:message];
    } else {
        message = (UILabel *)[cell.contentView viewWithTag:CELL_MESSAGE_TAG];
    }
    
    message.text = @"Your wallet stores your tournament credits.\n\nYou can purchase credits using the DEPOSIT button below. Next time you play, you will be able to use credits to enter tournaments against other players.\n\nUse the WITHDRAW button to exchange your credits for cash.";
    
    return cell;
}

@end
