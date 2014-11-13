//
//  ARBSCOfficialRules.m
//  Unity-iPhone
//
//  Created by Andy Zinsser on 10/16/14.
//
//

#import "ARBSCOfficialRules.h"
#import "ARBConstants.h"
#import "ARBUITableView.h"

#define CELL_MESSAGE_TAG 1

@implementation ARBSCOfficialRules

- (id)initWithChallengeId:(NSString *)challengeId arbiterInstance:(Arbiter *)arbiterInstance
{
    self = [super init:arbiterInstance];
    if ( self ) {
        self.challengeId = challengeId;
    }
    [self renderMessage];
    return self;
}

- (void)renderLayout
{
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
    
    UILabel *title = [[UILabel alloc] initWithFrame:CGRectMake(50.0, self.titleYPos,
                                                               self.frame.size.width - 100.0, self.titleHeight)];
    title.font = [UIFont fontWithName:@"HelveticaNeue-UltraLight" size:38.0];
    title.textColor = [UIColor whiteColor];
    title.text = @"Rules";
    title.textAlignment = NSTextAlignmentCenter;
    title.numberOfLines = 0;
    [self addSubview:title];
    
    CALayer *topBorder = [CALayer layer];
    topBorder.frame = CGRectMake(0.0, self.titleYPos + self.titleHeight + 10.0,
                                 self.frame.size.width, 0.5f);
    topBorder.backgroundColor = [[UIColor whiteColor] CGColor];
    topBorder.opacity = 0.2;
    [self.layer addSublayer:topBorder];
}

- (void)renderMessage
{
    float tableYOrigin = self.titleYPos + self.titleHeight + 10;
    float tableHeight = self.frame.size.height - tableYOrigin - 40;
    BOOL IS_GREATER_THAN_IOS7 = [[[UIDevice currentDevice] systemVersion] compare: @"8.0" options: NSNumericSearch] != NSOrderedAscending;
    BOOL IS_LANDCAPE = UIDeviceOrientationIsLandscape([[UIApplication sharedApplication] statusBarOrientation]);
    if ( IS_GREATER_THAN_IOS7 && IS_LANDCAPE ) {
        tableHeight = self.frame.size.width - tableYOrigin - 40;
    }
    NSString *url = [NSString stringWithFormat:@"%@%@", APIScoreChallengeRulesURL, self.challengeId];
    
    [self.arbiter httpGet:url isBlocking:YES handler:[^(NSDictionary *responseDict) {
        self.rules = [responseDict objectForKey:@"rules"];
        ARBUITableView *tableView = [[ARBUITableView alloc] initWithFrame:CGRectMake(0.0, 60.0, self.frame.size.width, tableHeight)];
        tableView.delegate = self;
        tableView.dataSource = self;
        tableView.scrollEnabled = YES;
        [tableView reloadData];
        [self addSubview:tableView];
    } copy]];
}

#pragma mark Click Handlers

- (void)backButtonClicked:(id)sender
{
    if ( self.callback ) {
        self.callback();
    }
    [self.parentWindow hide];
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
    return 4760.0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *i = @"SCRulesTableCell";
    UILabel *message;
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:i];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:i];
        cell.backgroundColor = [UIColor clearColor];
        message = [[UILabel alloc] initWithFrame:CGRectMake(0.0, 0.0, cell.frame.size.width - 20, 4760.0)];
        message.textColor = [UIColor whiteColor];
        message.numberOfLines = 0;
        message.tag = CELL_MESSAGE_TAG;
        message.text = self.rules;
        [cell.contentView addSubview:message];
    }
    
    return cell;
}

@end
