//
//  ARBTournamentResultsView.m
//  Unity-iPhone
//
//  Created by Andy Zinsser on 9/2/14.
//
//

#import "ARBTournamentResultsView.h"
#import "ARBUITableView.h"

#define CELL_LABEL_TAG 1
#define CELL_VALUE_TAG 2

@implementation ARBTournamentResultsView

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
    title.text = @"Results";
    title.textAlignment = NSTextAlignmentCenter;
    title.numberOfLines = 0;
    [self addSubview:title];
    
    CALayer *topBorder = [CALayer layer];
    topBorder.frame = CGRectMake(0.0, self.titleYPos + self.titleHeight + 10.0,
                                 self.frame.size.width, 0.5f);
    topBorder.backgroundColor = [[UIColor whiteColor] CGColor];
    topBorder.opacity = 0.2;
    [self.layer addSublayer:topBorder];
    
    UILabel *message = [[UILabel alloc] initWithFrame:CGRectMake(0.0, topBorder.frame.origin.y + 10.0, self.frame.size.width, 80.0)];
    message.textColor = [UIColor whiteColor];
    message.textAlignment = NSTextAlignmentCenter;
    message.numberOfLines = 0;
    [self addSubview:message];

    if ( [status isEqualToString:@"initializing"] || [status isEqualToString:@"inprogress"] ) {
        message.text = @"Your opponent has not reported their score yet. Check back later using the 'Previous Tournaments' button in the main menu.";
        message.textAlignment = NSTextAlignmentLeft;
    }
    else if ( [[self.tournament objectForKey:@"winners"] containsObject:[self.arbiter.user objectForKey:@"id"]] ) {
        message.text = [NSString stringWithFormat:@"You won %@ credits!", [self.tournament objectForKey:@"payout"]];
        message.font = [UIFont boldSystemFontOfSize:23.0];
    } else {
        message.text = @"You have been defeated.";
        message.font = [UIFont boldSystemFontOfSize:23.0];
    }
    
    ARBUITableView *tableView = [[ARBUITableView alloc] initWithFrame:CGRectMake(0.0, message.frame.origin.y + message.frame.size.height - 40.0,
                                                                                         self.frame.size.width, 160.0)];
    tableView.delegate = self;
    tableView.dataSource = self;
    [tableView reloadData];
    [self addSubview:tableView];
    [super renderLayout];
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
    return 3;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *i = @"TournamentResultsCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:i];
    UILabel *label, *value;
    NSDictionary *opponent;
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:i];
        cell.backgroundColor = [UIColor clearColor];
        
        label = [[UILabel alloc] initWithFrame:CGRectMake(0.0, 0.0, cell.frame.size.width / 2, cell.frame.size.height)];
        label.tag = CELL_LABEL_TAG;
        label.textColor = [UIColor whiteColor];
        label.textAlignment = NSTextAlignmentLeft;
        [cell.contentView addSubview:label];
        
        value = [[UILabel alloc] initWithFrame:CGRectMake(cell.frame.size.width / 2, 0.0, cell.frame.size.width / 2 - 20.0, cell.frame.size.height)];
        value.tag = CELL_VALUE_TAG;
        value.textColor = [UIColor whiteColor];
        value.textAlignment = NSTextAlignmentRight;
        [cell.contentView addSubview:value];
    } else {
        label = (UILabel *)[cell.contentView viewWithTag:CELL_LABEL_TAG];
        value = (UILabel *)[cell.contentView viewWithTag:CELL_VALUE_TAG];
    }
    
    CALayer *topBorder = [CALayer layer];
    topBorder.frame = CGRectMake(0.0, 0.0, cell.frame.size.width, 0.5f);
    topBorder.backgroundColor = [[UIColor whiteColor] CGColor];
    topBorder.opacity = 0.2;
    
    if ( indexPath.row == 0 ) {
        label.text = @"Your score";
        value.text = [[self.arbiter getCurrentUserFromTournament:self.tournament] objectForKey:@"score"];
    } else if ( indexPath.row == 1 ) {
        opponent = [self.arbiter getOpponentFromTournament:self.tournament];
        if ( opponent ) {
            label.text = [NSString stringWithFormat:@"%@'s score", [opponent objectForKey:@"username"]];
            value.text = [opponent objectForKey:@"score"];
        } else {
            label.text = @"Opponent score";
            value.text = @"...";
        }
        [cell.contentView.layer addSublayer:topBorder];
    } else if ( indexPath.row == 2 ) {
        NSString *status = [self.tournament objectForKey:@"status"];
        if ( ([status  isEqualToString:@"initializing"] || [status isEqualToString:@"inprogress"]) || [[self.tournament objectForKey:@"winners"] containsObject:[self.arbiter.user objectForKey:@"id"]] ) {
            label.text = @"Prize";
            value.text = [NSString stringWithFormat:@"%@ credits", [self.tournament objectForKey:@"payout"]];
            [cell.contentView.layer addSublayer:topBorder];
        }
    }

    return cell;
}


@end
