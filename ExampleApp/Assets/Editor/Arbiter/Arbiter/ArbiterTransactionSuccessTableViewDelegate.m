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
            UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(-80.0, 0.0, cell.frame.size.width / 2, cell.frame.size.height)];
            [label setTag:CELL_LABEL_TAG];
            [label setTextColor:[UIColor whiteColor]];
            [label setAutoresizingMask:UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleHeight];
            [label setBackgroundColor:[UIColor clearColor]];
            [label setText:@"Your deposit was successfull"];

            [cell.contentView addSubview:label];
        } else if ( indexPath.row == 1 ) {
            UIButton *backButton = [UIButton buttonWithType:UIButtonTypeSystem];
            [backButton setFrame:CGRectMake(0.0, 5.0, 50.0, 50.0)];
            [backButton setTitle:@"Back" forState:UIControlStateNormal];
            [backButton.titleLabel setTextAlignment:NSTextAlignmentLeft];
            [backButton.titleLabel setFont:[UIFont systemFontOfSize:17.0]];
            [backButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            [backButton addTarget:self action:@selector(backButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
            [cell.contentView addSubview:backButton];
        }

        CALayer *topBorder = [CALayer layer];
        topBorder.frame = CGRectMake(0.0, 0.0, cell.frame.size.width + 80.0, 0.5f);
        topBorder.backgroundColor = [[UIColor whiteColor] CGColor];
        [cell.contentView.layer addSublayer:topBorder];
    }
    
    return cell;
}

- (void)backButtonClicked:(id)sender
{
    self.callback();
}


@end
