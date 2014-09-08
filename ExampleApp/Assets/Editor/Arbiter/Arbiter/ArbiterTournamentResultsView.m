//
//  ArbiterTournamentResultsView.m
//  Unity-iPhone
//
//  Created by Andy Zinsser on 9/2/14.
//
//

#import "ArbiterTournamentResultsView.h"
#import "ArbiterUITableView.h"

#define CELL_LABEL_TAG 1
#define CELL_VALUE_TAG 2

@implementation ArbiterTournamentResultsView

- (id)initWithTournament:(NSDictionary *)tournament arbiterInstance:(Arbiter *)arbiterInstance
{
    self = [super init:arbiterInstance];
    if ( self ) {
        self.tournament = tournament;
        [self renderTournamentDetails];
    }
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
}

- (void)renderTournamentDetails
{
    NSString *status = [self.tournament objectForKey:@"status"];
    UILabel *title = [[UILabel alloc] initWithFrame:CGRectMake(50.0, self.titleYPos,
                                                               self.frame.size.width - 100.0, self.titleHeight)];
    title.font = [UIFont fontWithName:@"HelveticaNeue-UltraLight" size:38.0];
    title.textColor = [UIColor whiteColor];
    title.textAlignment = NSTextAlignmentCenter;
    title.numberOfLines = 0;
    
    if ( [status isEqualToString:@"initializing"] || [status isEqualToString:@"inprogress"] ) {
        self.titleHeight = 100.0;
        [title setFrame:CGRectMake(0.0, self.titleYPos,
                                   self.frame.size.width, self.titleHeight)];
        title.text = @"Waiting for\nopponent to finish";
    }
    else if ( [[self.tournament objectForKey:@"winners"] containsObject:[self.arbiter.user objectForKey:@"id"]] ) {
        self.titleHeight = 100.0;
        [title setFrame:CGRectMake(0.0, self.titleYPos,
                                   self.frame.size.width, self.titleHeight)];
        title.text = [NSString stringWithFormat:@"You won\n%@ credits!", [self.tournament objectForKey:@"payout"]];
    } else {
        title.text = @"You lost";
    }
    [self addSubview:title];
    
    CALayer *topBorder = [CALayer layer];
    topBorder.frame = CGRectMake(0.0, self.titleYPos + self.titleHeight + 10.0,
                                 self.frame.size.width, 0.5f);
    topBorder.backgroundColor = [[UIColor whiteColor] CGColor];
    topBorder.opacity = 0.2;
    [self.layer addSublayer:topBorder];
    
    ArbiterUITableView *tableView = [[ArbiterUITableView alloc] initWithFrame:CGRectMake(0.0, topBorder.frame.origin.y - 20.0,
                                                                                         self.frame.size.width, 200.0)];
    tableView.delegate = self;
    tableView.dataSource = self;
    [tableView reloadData];
    [self addSubview:tableView];
    [super renderLayout];
}


#pragma mark Click Handlers

- (void)backButtonClicked:(id)sender
{
    [self animateOut];
}


# pragma mark TableView Delegate Methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 3;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *i = @"TournamentResultsCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:i];
    UILabel *label, *value;
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:i];
        cell.backgroundColor = [UIColor clearColor];
        float adjustedWidth = (cell.frame.size.width + 80.0) / 2;
        
        label = [[UILabel alloc] initWithFrame:CGRectMake(0.0, 0.0, adjustedWidth, cell.frame.size.height)];
        label.tag = CELL_LABEL_TAG;
        label.textColor = [UIColor whiteColor];
        label.textAlignment = NSTextAlignmentLeft;
        [cell.contentView addSubview:label];
        
        value = [[UILabel alloc] initWithFrame:CGRectMake(adjustedWidth, 0.0, adjustedWidth, cell.frame.size.height)];
        value.tag = CELL_VALUE_TAG;
        value.textColor = [UIColor whiteColor];
        value.textAlignment = NSTextAlignmentRight;
        [cell.contentView addSubview:value];
    } else {
        label = (UILabel *)[cell.contentView viewWithTag:CELL_LABEL_TAG];
        value = (UILabel *)[cell.contentView viewWithTag:CELL_VALUE_TAG];
    }
    
    CALayer *topBorder = [CALayer layer];
    topBorder.frame = CGRectMake(0.0, 0.0, cell.frame.size.width + 80.0, 0.5f);
    topBorder.backgroundColor = [[UIColor whiteColor] CGColor];
    topBorder.opacity = 0.2;
    
    if ( indexPath.row == 0 ) {
        label.text = @"Your score";
        value.text = [self.arbiter getPlayerScoreFromTournament:self.tournament];
    } else if ( indexPath.row == 1 ) {
        label.text = @"Opponent score";
        value.text = [self.arbiter getOpponentScoreFromTournament:self.tournament];
        [cell.contentView.layer addSublayer:topBorder];
    } else if ( indexPath.row == 2 ) {
        label.text = @"Payout";
        value.text = [NSString stringWithFormat:@"%@ credits", [self.tournament objectForKey:@"payout"]];
        [cell.contentView.layer addSublayer:topBorder];
    }

    return cell;
}


@end
