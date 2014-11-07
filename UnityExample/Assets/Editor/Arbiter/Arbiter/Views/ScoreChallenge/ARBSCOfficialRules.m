//
//  ARBSCOfficialRules.m
//  Unity-iPhone
//
//  Created by Andy Zinsser on 10/16/14.
//
//

#import "ARBSCOfficialRules.h"
#import "ARBSCRulesTableViewDelegate.h"
#import "ARBConstants.h"
#import "ARBUITableView.h"

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
        NSString *message = [responseDict objectForKey:@"rules"];
        ARBSCRulesTableViewDelegate *tableDelegate = [[ARBSCRulesTableViewDelegate alloc] initWithMessage:message];
        ARBUITableView *tableView = [[ARBUITableView alloc] initWithFrame:CGRectMake(0.0, 60.0, self.frame.size.width, tableHeight)];
        tableView.delegate = tableDelegate;
        tableView.dataSource = tableDelegate;
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

@end
