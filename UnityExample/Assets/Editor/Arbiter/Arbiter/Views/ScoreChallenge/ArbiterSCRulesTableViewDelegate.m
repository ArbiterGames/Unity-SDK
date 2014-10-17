//
//  ArbiterCORulesTableViewDelegate.m
//  Unity-iPhone
//
//  Created by Andy Zinsser on 10/16/14.
//
//

#import "ArbiterSCRulesTableViewDelegate.h"
#import "ArbiterConstants.h"

#define CELL_MESSAGE_TAG 1

@implementation ArbiterSCRulesTableViewDelegate

- (id)initWithMessage:(NSString *)message
{
    self = [super init];
    if ( self ) {
        self.rulesBody = message;
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

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 0.1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 5000.0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *i = @"SCRulesTableCell";
    UILabel *message;
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:i];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:i];
        cell.backgroundColor = [UIColor clearColor];
        message = [[UILabel alloc] initWithFrame:CGRectMake(0.0, 0.0, cell.frame.size.width - 20, 5000.0)];
        message.textColor = [UIColor whiteColor];
        message.numberOfLines = 0;
        [cell.contentView addSubview:message];
    } else {
        message = (UILabel *)[cell.contentView viewWithTag:CELL_MESSAGE_TAG];
    }
    message.text = self.rulesBody;
    
    return cell;
}

@end
