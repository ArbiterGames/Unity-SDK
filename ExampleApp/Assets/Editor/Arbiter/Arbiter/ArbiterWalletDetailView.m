//
//  ArbiterWalletDetailView.m
//  Unity-iPhone
//
//  Created by Andy Zinsser on 9/4/14.
//
//

#import "ArbiterWalletDetailView.h"
#import "Arbiter.h"

#define CELL_LABEL_TAG 1
#define CELL_VALUE_TAG 2

@implementation ArbiterWalletDetailView
{
    Arbiter *_arbiter;
}

@synthesize delegate;

- (id)initWithFrame:(CGRect)frame andArbiterInstance:(Arbiter *)arbiterInstance
{
    self = [super initWithFrame:frame];
    if ( self ) {
        _arbiter = arbiterInstance;
        [self renderLayout];
    }
    return self;
}

- (void)renderLayout
{
    UITableView *tableView = [[UITableView alloc] initWithFrame:CGRectMake(0.0, 60.0, self.frame.size.width, 140.0) style:UITableViewStyleGrouped];
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
    
    // Close button
    UIButton *backButton = [UIButton buttonWithType:UIButtonTypeSystem];
    float btnWidth = 50.0;
    float btnHeight = 50.0;
    [backButton setFrame:CGRectMake(0.0, 5.0, btnWidth, btnHeight)];
    [backButton setTitle:@"Back" forState:UIControlStateNormal];
    [backButton.titleLabel setTextAlignment:NSTextAlignmentLeft];
    [backButton.titleLabel setFont:[UIFont systemFontOfSize:17.0]];
    [backButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [backButton addTarget:self action:@selector(backButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:backButton];
    
//    // TODO: Just using this for lining up the navigation buttons
//    CALayer *topBorder = [CALayer layer];
//    topBorder.frame = CGRectMake(0.0, -5.0, self.frame.size.width, 0.5f);
//    topBorder.backgroundColor = [[UIColor whiteColor] CGColor];
//    [self.layer addSublayer:topBorder];
//    
    // TODO: Just using this for lining up the navigation buttons
//    CALayer *sideBorder = [CALayer layer];
//    sideBorder.frame = CGRectMake(0.0, -55.0, 0.5, self.frame.size.height);
//    sideBorder.backgroundColor = [[UIColor whiteColor] CGColor];
//    [self.layer addSublayer:sideBorder];
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
        
        label = [[UILabel alloc] initWithFrame:CGRectMake(-80.0, 0.0, cell.frame.size.width / 2, cell.frame.size.height)];
        [label setTag:CELL_LABEL_TAG];
        [label setTextColor:[UIColor whiteColor]];
        [label setAutoresizingMask:UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleHeight];
        [label setBackgroundColor:[UIColor clearColor]];
        [cell.contentView addSubview:label];
        
        value = [[UILabel alloc] initWithFrame:CGRectMake(cell.frame.size.width / 2, 0.0, cell.frame.size.width / 2, cell.frame.size.height)];
        [value setTag:CELL_VALUE_TAG];
        [value setTextAlignment:NSTextAlignmentRight];
        [value setTextColor:[UIColor whiteColor]];
        [value setBackgroundColor:[UIColor clearColor]];
        [value setAutoresizingMask:UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleHeight];
        [cell.contentView addSubview:value];
    } else {
        label = (UILabel *)[cell.contentView viewWithTag:CELL_LABEL_TAG];
        value = (UILabel *)[cell.contentView viewWithTag:CELL_VALUE_TAG];
    }

    topBorder.frame = CGRectMake(0.0, 0.0, cell.frame.size.width + 80.0, 0.5f);
    topBorder.backgroundColor = [[UIColor whiteColor] CGColor];
    
    if ( indexPath.row == 0 ) {
        [label setText:@"Balance"];
        [label setFont:[UIFont boldSystemFontOfSize:17.0]];
        [value setText:[NSString stringWithFormat:@"%@ credits", [_arbiter.wallet objectForKey:@"balance"]]];
        [value setFont:[UIFont boldSystemFontOfSize:17.0]];
    } else {
        [label setText:@"Username"];
        [value setText:[_arbiter.user objectForKey:@"username"]];
        [cell.contentView.layer addSublayer:topBorder];
    }
    
    return cell;
}

#pragma mark Click Handlers

- (void)backButtonClicked:(id)sender
{
    // TODO: Figure out how this will know whether to go back to a previous view or to close the panel completely
    [self.delegate closePanel];
}


@end

