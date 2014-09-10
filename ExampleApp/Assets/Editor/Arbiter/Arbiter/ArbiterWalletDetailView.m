//
//  ArbiterWalletDetailView.m
//  Unity-iPhone
//
//  Created by Andy Zinsser on 9/4/14.
//
//

#import "ArbiterWalletDetailView.h"
#import "ArbiterUITableView.h"
#import "ArbiterWalletInfoTableViewDelegate.h"

#define CELL_LABEL_TAG 1
#define CELL_VALUE_TAG 2
#define INFO_UI_TAG 100
#define DETAIL_UI_TAG 101

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
    [self renderDetailLayout];
}

- (void)renderDetailLayout
{
    self.activeUI = DETAIL_UI_TAG;
    ArbiterUITableView *tableView = [[ArbiterUITableView alloc] initWithFrame:CGRectMake(0.0, 60.0, self.frame.size.width, 140.0)];
    tableView.delegate = self;
    tableView.dataSource = self;
    tableView.tag = DETAIL_UI_TAG;
    [tableView reloadData];
    [self addSubview:tableView];
    
    UIButton *backButton = [UIButton buttonWithType:UIButtonTypeSystem];
    float btnWidth = 50.0;
    float btnHeight = 50.0;
    [backButton setFrame:CGRectMake(0.0, 5.0, btnWidth, btnHeight)];
    [backButton setTitle:@"Back" forState:UIControlStateNormal];
    [backButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [backButton addTarget:self action:@selector(backButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    backButton.titleLabel.textAlignment = NSTextAlignmentLeft;
    backButton.titleLabel.font = [UIFont boldSystemFontOfSize:17.0];
    backButton.tag = DETAIL_UI_TAG;
    [self addSubview:backButton];
    
    UIButton *infoButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [infoButton setFrame:CGRectMake(self.frame.size.width - btnWidth, 5.0, btnWidth, btnHeight)];
    [infoButton setTitle:@"?" forState:UIControlStateNormal];
    [infoButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [infoButton addTarget:self action:@selector(infoButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    infoButton.titleLabel.textAlignment = NSTextAlignmentLeft;
    infoButton.titleLabel.font = [UIFont boldSystemFontOfSize:17.0];
    infoButton.tag = DETAIL_UI_TAG;
    [self addSubview:infoButton];

}

- (void)renderInfoLayout
{
    self.activeUI = INFO_UI_TAG;
    UIButton *backButton = [UIButton buttonWithType:UIButtonTypeSystem];
    float btnWidth = 50.0;
    float btnHeight = 50.0;
    [backButton setFrame:CGRectMake(0.0, 5.0, btnWidth, btnHeight)];
    [backButton setTitle:@"Back" forState:UIControlStateNormal];
    [backButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [backButton addTarget:self action:@selector(backButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    backButton.titleLabel.textAlignment = NSTextAlignmentLeft;
    backButton.titleLabel.font = [UIFont boldSystemFontOfSize:17.0];
    backButton.tag = INFO_UI_TAG;
    [self addSubview:backButton];
    
    ArbiterWalletInfoTableViewDelegate *tableDelegate = [[ArbiterWalletInfoTableViewDelegate alloc] init];
    ArbiterUITableView *tableView = [[ArbiterUITableView alloc] initWithFrame:CGRectMake(0.0, 60.0, self.frame.size.width, 160.0)];
    tableView.delegate = tableDelegate;
    tableView.dataSource = tableDelegate;
    tableView.tag = INFO_UI_TAG;
    tableView.scrollEnabled = YES;
    [tableView reloadData];
    [self addSubview:tableView];
}

- (void)removeUIWithTag:(int)tag
{
    for (UIView *view in [self subviews]) {
        if (view.tag == tag) {
            [view removeFromSuperview];
        }
    }
}


#pragma mark Click Handlers

- (void)backButtonClicked:(id)sender
{
    if ( self.activeUI == DETAIL_UI_TAG ) {
        [self.delegate handleBackButton];
    } else {
        [self removeUIWithTag:INFO_UI_TAG];
        [self renderDetailLayout];
    }
}

- (void)infoButtonClicked:(id)sender
{
    [self removeUIWithTag:DETAIL_UI_TAG];
    [self renderInfoLayout];
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
    
    if ( indexPath.row == 0 ) {
        [label setText:@"Balance"];
        [value setText:[NSString stringWithFormat:@"%@ credits", [self.arbiter.wallet objectForKey:@"balance"]]];
    } else {
        [label setText:@"Username"];
        [value setText:[self.arbiter.user objectForKey:@"username"]];
        CALayer *topBorder = [CALayer layer];
        topBorder.frame = CGRectMake(0.0, 0.0, cell.frame.size.width + 80.0, 0.5f);
        topBorder.backgroundColor = [[UIColor whiteColor] CGColor];
        topBorder.opacity = 0.2;
        [cell.contentView.layer addSublayer:topBorder];
    }
    
    return cell;
}

@end

