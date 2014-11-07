//
//  ARBPreviousTournamentsView.m
//  Unity-iPhone
//
//  Created by Andy Zinsser on 9/9/14.
//
//

#import "ARBPreviousTournamentsView.h"
#import "ARBUITableView.h"

#define CELL_DATE_TAG 1
#define CELL_OUTCOME_TAG 2
#define CELL_PAYOUT_TAG 3
#define CELL_PLAYER_LABEL_TAG 4
#define CELL_PLAYER_SCORE_TAG 5
#define CELL_OPPONENT_LABEL_TAG 6
#define CELL_OPPONENT_SCORE_TAG 7
#define LINE_HEIGHT 24.0

@implementation ARBPreviousTournamentsView

- (id)init:(Arbiter *)arbiter excludeViewed:(BOOL)excludeViewed
{
    self = [super init:arbiter];
    if ( self ) {
        self.currentPage = 0;
        self.currentHead = 0;
        self.currentTail = 0;
        self.markAsViewedQueue = [[NSMutableArray alloc] init];
        self.excludeViewed = excludeViewed;
        [self renderTournamentTable];
        [self getNextPage];
    }
    return self;
}

- (void)getNextPage
{
    self.currentPage++;
    [self.nextButton removeFromSuperview];
    NSString *nextPage = (self.currentPage == 1) ? nil : @"next";
    [self.arbiter fetchTournaments:[^(NSDictionary (*responseDict)) {
        NSDictionary *tournamentSerializer = [responseDict objectForKey:@"tournaments"];
        self.tournaments = [tournamentSerializer objectForKey:@"results"];
        if ( [self.tournaments count] > 0 ) {
            if ( self.excludeViewed ) {
                [self addCurrentSetToMarkAsViewedQueue];
            }
            self.total = self.arbiter.previousTournamentsCount;
            if ( self.currentHead == 0 ) {
                self.currentHead = 1;
            } else {
                self.currentHead += 10;
            }
            if ( self.currentTail == 0 && [self.tournaments count] == self.total ) {
                self.currentTail = self.total;
            } else {
                if ( self.currentTail + 10 > self.total ) {
                    self.currentTail = self.total;
                } else {
                    [self renderNextButton];
                    self.currentTail += 10;
                }
            }
            self.title.text = [NSString stringWithFormat:@"%d-%d of %d", self.currentHead, self.currentTail, self.total];
        } else {
            self.title.text = @"No Updates";
        }
        [self.tournamentTable reloadData];
        
    } copy] page:nextPage isBlocking:YES excludeViewed:self.excludeViewed];
}

- (void)renderLayout
{
    self.title = [[UILabel alloc] initWithFrame:CGRectMake(50.0, self.titleYPos, self.frame.size.width - 100.0, self.titleHeight)];
    self.title.font = [UIFont fontWithName:@"HelveticaNeue-UltraLight" size:38.0];
    self.title.textColor = [UIColor whiteColor];
    self.title.textAlignment = NSTextAlignmentCenter;
    [self addSubview:self.title];
    
    CALayer *topBorder = [CALayer layer];
    topBorder.frame = CGRectMake(0.0, self.titleYPos + self.titleHeight + 10.0,
                                 self.frame.size.width, 0.5f);
    topBorder.backgroundColor = [[UIColor whiteColor] CGColor];
    topBorder.opacity = 0.2;
    [self.layer addSublayer:topBorder];
    
    float btnWidth = 50.0;
    float btnHeight = 50.0;
    self.backButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [self.backButton setFrame:CGRectMake(0.0, 5.0, btnWidth, btnHeight)];
    [self.backButton setTitle:@"Back" forState:UIControlStateNormal];
    [self.backButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.backButton addTarget:self action:@selector(backButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    self.backButton.titleLabel.textAlignment = NSTextAlignmentCenter;
    self.backButton.titleLabel.font = [UIFont boldSystemFontOfSize:17.0];
    [self addSubview:self.backButton];
}

- (void)renderNextButton
{
    float btnWidth = 50.0;
    float btnHeight = 50.0;
    self.nextButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [self.nextButton setFrame:CGRectMake(self.frame.size.width - btnWidth, 5.0, btnWidth, btnHeight)];
    [self.nextButton setTitle:@"Next" forState:UIControlStateNormal];
    [self.nextButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.nextButton addTarget:self action:@selector(nextButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    self.nextButton.titleLabel.textAlignment = NSTextAlignmentRight;
    self.nextButton.titleLabel.font = [UIFont boldSystemFontOfSize:17.0];
    [self addSubview:self.nextButton];
}

- (void)renderTournamentTable
{
    float tableYOrigin = self.titleYPos + self.titleHeight + 10;
    float tableHeight = self.frame.size.height - tableYOrigin - 40;
    BOOL IS_GREATER_THAN_IOS7 = [[[UIDevice currentDevice] systemVersion] compare: @"8.0" options: NSNumericSearch] != NSOrderedAscending;
    BOOL IS_LANDCAPE = UIDeviceOrientationIsLandscape([[UIApplication sharedApplication] statusBarOrientation]);
    if ( IS_GREATER_THAN_IOS7 && IS_LANDCAPE ) {
        tableHeight = self.frame.size.width - tableYOrigin - 40;
    }
    self.tournamentTable = [[ARBUITableView alloc] initWithFrame:CGRectMake(0.0, tableYOrigin, self.frame.size.width, tableHeight)];
    self.tournamentTable.delegate = self;
    self.tournamentTable.dataSource = self;
    self.tournamentTable.scrollEnabled = YES;
    [self.tournamentTable reloadData];
    [self addSubview:self.tournamentTable];
    [super renderLayout];
}

- (void)addCurrentSetToMarkAsViewedQueue
{
    for ( NSDictionary *tournament in self.tournaments ) {
        [self.markAsViewedQueue addObject:[tournament objectForKey:@"id"]];
    }
}


# pragma mark TableView Delegate Methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 0.1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.tournaments count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return LINE_HEIGHT * 4;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *i = @"PreviousTournamentCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:i];
    float adjustedWidth;
    UILabel *date;
    UILabel *outcome;
    UILabel *playerScoreLabel;
    UILabel *playerScoreValue;
    UILabel *opponentScoreLabel;
    UILabel *opponentScoreValue;
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:i];
        cell.backgroundColor = [UIColor clearColor];
        adjustedWidth = (cell.frame.size.width) / 2 - 20.0;
        
        date = [[UILabel alloc] initWithFrame:CGRectMake(adjustedWidth, 10.0, adjustedWidth, LINE_HEIGHT)];
        date.textAlignment = NSTextAlignmentRight;
        date.textColor = [UIColor lightGrayColor];
        date.tag = CELL_DATE_TAG;
        [cell.contentView addSubview:date];

        outcome = [[UILabel alloc] initWithFrame:CGRectMake(0.0, 10, adjustedWidth, LINE_HEIGHT)];
        outcome.tag = CELL_OUTCOME_TAG;
        outcome.textColor = [UIColor whiteColor];
        outcome.font = [UIFont boldSystemFontOfSize:17.0];
        [cell.contentView addSubview:outcome];
        
        playerScoreLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0, LINE_HEIGHT + 10, adjustedWidth, LINE_HEIGHT)];
        playerScoreLabel.tag = CELL_PLAYER_LABEL_TAG;
        playerScoreLabel.textColor = [UIColor whiteColor];
        playerScoreLabel.textAlignment = NSTextAlignmentLeft;
        [cell.contentView addSubview:playerScoreLabel];
        
        playerScoreValue = [[UILabel alloc] initWithFrame:CGRectMake(adjustedWidth, LINE_HEIGHT + 10, adjustedWidth, LINE_HEIGHT)];
        playerScoreValue.tag = CELL_PLAYER_SCORE_TAG;
        playerScoreValue.textColor = [UIColor whiteColor];
        playerScoreValue.textAlignment = NSTextAlignmentRight;
        [cell.contentView addSubview:playerScoreValue];
        
        opponentScoreLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0, LINE_HEIGHT * 2 + 10, adjustedWidth, LINE_HEIGHT)];
        opponentScoreLabel.tag = CELL_OPPONENT_LABEL_TAG;
        opponentScoreLabel.textColor = [UIColor whiteColor];
        opponentScoreLabel.textAlignment = NSTextAlignmentLeft;
        [cell.contentView addSubview:opponentScoreLabel];
        
        opponentScoreValue = [[UILabel alloc] initWithFrame:CGRectMake(adjustedWidth, LINE_HEIGHT * 2 + 10, adjustedWidth, LINE_HEIGHT)];
        opponentScoreValue.tag = CELL_OPPONENT_SCORE_TAG;
        opponentScoreValue.textColor = [UIColor whiteColor];
        opponentScoreValue.textAlignment = NSTextAlignmentRight;
        [cell.contentView addSubview:opponentScoreValue];
        
        CALayer *topBorder = [CALayer layer];
        topBorder.frame = CGRectMake(0.0, 0.0, cell.frame.size.width, 0.5f);
        topBorder.backgroundColor = [[UIColor whiteColor] CGColor];
        topBorder.opacity = 0.2;
        [cell.contentView.layer addSublayer:topBorder];
    } else {
        date = (UILabel *)[cell.contentView viewWithTag:CELL_DATE_TAG];
        outcome = (UILabel *)[cell.contentView viewWithTag:CELL_OUTCOME_TAG];
        playerScoreLabel = (UILabel *)[cell.contentView viewWithTag:CELL_PLAYER_LABEL_TAG];
        playerScoreValue = (UILabel *)[cell.contentView viewWithTag:CELL_PLAYER_SCORE_TAG];
        opponentScoreLabel = (UILabel *)[cell.contentView viewWithTag:CELL_OPPONENT_LABEL_TAG];
        opponentScoreValue = (UILabel *)[cell.contentView viewWithTag:CELL_OPPONENT_SCORE_TAG];
    }

    NSDictionary *tournament = [self.tournaments objectAtIndex:indexPath.row];
    NSString *status = [tournament objectForKey:@"status"];
    NSDictionary *opponent = [self.arbiter getOpponentFromTournament:tournament];
    NSString *createdOn = [tournament objectForKey:@"created_on"];
    NSTimeInterval seconds = [createdOn doubleValue] / 1000;
    NSDate *unFormattedDate = [NSDate dateWithTimeIntervalSince1970:seconds];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"EEE, MMM d"];
    date.text = [dateFormatter stringFromDate:unFormattedDate];
    
    playerScoreLabel.text = @"Your score";
    if ( [[NSString stringWithFormat:@"%@", [[self.arbiter getCurrentUserFromTournament:tournament] objectForKey:@"score"]] isEqualToString:@"<null>"] ) {
        playerScoreValue.text = @"...";
    } else {
        playerScoreValue.text = [[self.arbiter getCurrentUserFromTournament:tournament] objectForKey:@"score"];
    }
    
    if ( opponent ) {
        opponentScoreLabel.text = [NSString stringWithFormat:@"%@'s score", [opponent objectForKey:@"username"]];
        if ( [[NSString stringWithFormat:@"%@", [[self.arbiter getOpponentFromTournament:tournament] objectForKey:@"score"]] isEqualToString:@"<null>"] ) {
            opponentScoreValue.text = @"...";
        } else {
            opponentScoreValue.text = [[self.arbiter getOpponentFromTournament:tournament] objectForKey:@"score"];
        }
    } else {
        opponentScoreLabel.text = @"Opponent score";
        opponentScoreValue.text = @"waiting ...";
    }
    
    if ( [status isEqualToString:@"initializing"] || [status isEqualToString:@"inprogress"] ) {
        outcome.text = @"In-progress";
    }
    else if ( [[tournament objectForKey:@"winners"] containsObject:[self.arbiter.user objectForKey:@"id"]] ) {
        outcome.text = [NSString stringWithFormat:@"You won %@ credits!", [tournament objectForKey:@"payout"]];
    } else {
        outcome.text = @"You lost";
    }
    return cell;
}


# pragma mark Arbiter Dashboard Subviews Delegate Methods

- (void)backButtonClicked:(id)sender
{
    if ( [self.markAsViewedQueue count] > 0 ) {
        [self.arbiter markViewedTournament:^(void) {
            NSLog(@"Tournaments marked as viewed");
        } tournamentIds:self.markAsViewedQueue];
    }
    if ( self.callback ) {
        self.callback();
    }
    [self.parentWindow hide];
}

- (void)nextButtonClicked:(id)sender
{
    [self getNextPage];
}


@end
