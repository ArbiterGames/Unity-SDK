//
//  ArbiterWalletDashboardView.m
//  Unity-iPhone
//
//  Created by Andy Zinsser on 9/3/14.
//
//

#import "ArbiterWalletDashboardView.h"
#import "Arbiter.h"

#define CELL_LABEL_TAG 1
#define CELL_VALUE_TAG 2

@implementation ArbiterWalletDashboardView

- (void)renderLayout
{
    [super renderLayout];
    UILabel *title = [[UILabel alloc] initWithFrame:CGRectMake(10.0f, 20.0f, self.frame.size.width - 20.0f, 40.0f)];
    [title setText:@"Wallet Dashboard"];
    [title setFont:[UIFont fontWithName:@"HelveticaNeue-UltraLight" size:38.0f]];
    [title setTextColor:[UIColor whiteColor]];
    [title setTextAlignment:NSTextAlignmentCenter];
    [self addSubview:title];
    
    CGRect tableFrame = self.frame;
    tableFrame.origin.y = 80.0f;
    if ( tableFrame.size.width > 400.0f ) {
        tableFrame.size.width = 400.0f;
        tableFrame.origin.x = (self.frame.size.width - tableFrame.size.width) / 2;
        tableFrame.origin.y = 60.0;
        tableFrame.size.height = 140.0;
    }
    UITableView *tableView = [[UITableView alloc] initWithFrame:tableFrame style:UITableViewStyleGrouped];
    [tableView setAutoresizingMask:UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth];
    [tableView setDelegate:self];
    [tableView setDataSource:self];
    [tableView setBackgroundColor:[UIColor clearColor]];
    [tableView setBackgroundView:nil];
    [tableView setSeparatorColor:[UIColor clearColor]];
    [tableView reloadData];
    [tableView setScrollEnabled:false];
    [tableView setAllowsSelection:false];
    [self addSubview:tableView];
    
    // TODO:
    //  add deposit / withdraw
    UISegmentedControl *segmentedControl = [[UISegmentedControl alloc] initWithItems:[NSArray arrayWithObjects: @"Deposit", @"Withdraw", nil]];
    [segmentedControl setFrame:CGRectMake(tableFrame.origin.x + 20.0, self.frame.size.height - 120.0, tableFrame.size.width - 40.0, 50.0)];
    [segmentedControl addTarget:self action:@selector(depositOrWithdrawClicked:) forControlEvents: UIControlEventValueChanged];
    [segmentedControl setTintColor:[UIColor whiteColor]];
    [self addSubview:segmentedControl];
}

# pragma mark click handlers

- (void)depositOrWithdrawClicked:(UISegmentedControl *)segment
{
    NSLog(@"CLICKED");
    if(segment.selectedSegmentIndex == 0)
    {
        // code for the first button
    }
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
    static NSString *i = @"WalletTableCell";
    UILabel *label, *value;
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:i];
    CALayer *topBorder = [CALayer layer];

    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:i];
        [cell setBackgroundColor:[UIColor clearColor]];
        
        // TODO: Why am I pulling from the frame?
        label = [[UILabel alloc] initWithFrame:CGRectMake(-60.0, 0.0, self.frame.size.width / 2, cell.frame.size.height)];
        [label setTag:CELL_LABEL_TAG];
        [label setTextColor:[UIColor whiteColor]];
        [label setAutoresizingMask:UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleHeight];
        [label setBackgroundColor:[UIColor clearColor]];
        [cell.contentView addSubview:label];
        
        value = [[UILabel alloc] initWithFrame:CGRectMake(cell.frame.size.width / 2 - 20.0, 0.0, cell.frame.size.width / 2, cell.frame.size.height)];
        [value setTag:CELL_VALUE_TAG];
        [value setTextAlignment:NSTextAlignmentRight];
        [value setTextColor:[UIColor grayColor]];
        [value setBackgroundColor:[UIColor clearColor]];
        [value setAutoresizingMask:UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleHeight];
        [cell.contentView addSubview:value];
    } else {
        label = (UILabel *)[cell.contentView viewWithTag:CELL_LABEL_TAG];
        value = (UILabel *)[cell.contentView viewWithTag:CELL_VALUE_TAG];
    }
    
    topBorder.frame = CGRectMake(20.0, 0.0, cell.frame.size.width + 40.0, 0.5f);
    topBorder.backgroundColor = [[UIColor whiteColor] CGColor];
    
    if ( indexPath.row == 0 ) {
        [label setText:@"Balance"];
        [label setFont:[UIFont boldSystemFontOfSize:17.0]];
        [value setText:[NSString stringWithFormat:@"%@ credits", [self.arbiter.wallet objectForKey:@"balance"]]];
    } else {
        [label setText:@"Username"];
        [value setText:[self.arbiter.user objectForKey:@"username"]];
        [cell.contentView.layer addSublayer:topBorder];
    }

    return cell;
}

@end
