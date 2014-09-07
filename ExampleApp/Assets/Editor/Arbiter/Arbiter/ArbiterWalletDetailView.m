//
//  ArbiterWalletDetailView.m
//  Unity-iPhone
//
//  Created by Andy Zinsser on 9/4/14.
//
//

#import "ArbiterWalletDetailView.h"
#import "ArbiterUITableView.h"

#define CELL_LABEL_TAG 1
#define CELL_VALUE_TAG 2

@implementation ArbiterWalletDetailView

@synthesize delegate = _delegate;

- (id)initWithFrame:(CGRect)frame andArbiterInstance:(Arbiter *)arbiterInstance
{
    self = [super initWithFrame:frame];
    if ( self ) {
        self.arbiter = arbiterInstance;
        [self renderLayout];
    }
    return self;
}

- (void)renderLayout
{
    ArbiterUITableView *tableView = [[ArbiterUITableView alloc] initWithFrame:CGRectMake(0.0, 60.0, self.frame.size.width, 140.0)];
    tableView.delegate = self;
    tableView.dataSource = self;
    [tableView reloadData];
    [self addSubview:tableView];
    
    UIButton *backButton = [UIButton buttonWithType:UIButtonTypeSystem];
    float btnWidth = 50.0;
    float btnHeight = 50.0;
    [backButton setFrame:CGRectMake(0.0, 5.0, btnWidth, btnHeight)];
    [backButton setTitle:@"Back" forState:UIControlStateNormal];
    [backButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [backButton addTarget:self action:@selector(backButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    backButton.titleLabel.textAlignment = NSTextAlignmentCenter;
    backButton.titleLabel.font = [UIFont boldSystemFontOfSize:17.0];
    [self addSubview:backButton];
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
        [value setText:[NSString stringWithFormat:@"%@ credits", [self.arbiter.wallet objectForKey:@"balance"]]];
    } else {
        [label setText:@"Username"];
        [value setText:[self.arbiter.user objectForKey:@"username"]];
        [cell.contentView.layer addSublayer:topBorder];
    }
    
    return cell;
}

#pragma mark Click Handlers

- (void)backButtonClicked:(id)sender
{
    [self.delegate handleBackButton];
}

@end

