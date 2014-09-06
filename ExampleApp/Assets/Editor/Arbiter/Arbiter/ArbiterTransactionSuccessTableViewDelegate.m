//
//  ArbiterTransactionSuccessTableViewDelegate.m
//  Unity-iPhone
//
//  Created by Andy Zinsser on 9/6/14.
//
//

#import "ArbiterTransactionSuccessTableViewDelegate.h"

#define CELL_LABEL_TAG 1
#define CELL_BUTTON_TAG 2


@implementation ArbiterTransactionSuccessTableViewDelegate

- (id)initWithCallback:(void(^)(void))callback
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

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *i = @"TransactionSuccessCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:i];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:i];
        [cell setBackgroundColor:[UIColor clearColor]];
        
        if ( indexPath.row == 0 ) {
            UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0.0, 0.0, cell.frame.size.width + 80.0, cell.frame.size.height)];
            [label setTag:CELL_LABEL_TAG];
            [label setTextColor:[UIColor whiteColor]];
            [label setTextAlignment:NSTextAlignmentCenter];
            [label setText:@"Your deposit was successful!"];
            [cell.contentView addSubview:label];
        } else if ( indexPath.row == 1 ) {
            UIButton *backButton = [UIButton buttonWithType:UIButtonTypeSystem];
            [backButton setFrame:CGRectMake(0.0 , 0.0, cell.frame.size.width + 80.0, cell.frame.size.height)];
            [backButton setTitle:@"Back to your Game" forState:UIControlStateNormal];
            [backButton.titleLabel setTextAlignment:NSTextAlignmentCenter];
            [backButton.titleLabel setFont:[UIFont boldSystemFontOfSize:17.0]];
            [backButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            [backButton addTarget:self action:@selector(backButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
            [cell.contentView addSubview:backButton];
        }
    }
    
    return cell;
}

- (void)backButtonClicked:(id)sender
{
    self.callback();
}


@end
