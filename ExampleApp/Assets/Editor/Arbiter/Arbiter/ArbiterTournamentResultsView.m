//
//  ArbiterTournamentResultsView.m
//  Unity-iPhone
//
//  Created by Andy Zinsser on 9/2/14.
//
//

#import "ArbiterTournamentResultsView.h"

@implementation ArbiterTournamentResultsView
{
    NSDictionary *_tournament;
}

- (id)initWithCallback:(void(^)(void))callback arbiterInstance:(Arbiter *)arbiterInstance andTournament:(NSDictionary*)tournament
{
    _tournament = tournament;
    self = [super initWithCallback:callback arbiterInstance:arbiterInstance];
    return self;
}

- (void)setupNextScreen
{
    UILabel *title = [[UILabel alloc] initWithFrame:CGRectMake(0.0f, 10.0f, self.frame.size.width, 20.0f)];
    [title setFont:[UIFont boldSystemFontOfSize:17]];
    [title setBackgroundColor:[UIColor grayColor]];
    [title setTextAlignment:NSTextAlignmentCenter];
    
    // TODO:
    // create your score label
    //      draw out and measure %'s for where this should be placed
    // create opponent score label
    //      draw out and measure %'s for where this should be placed
    // add 'vs'
    // add payout
    // add coin
    
    UILabel *scoreValues = [[UILabel alloc] initWithFrame:CGRectMake(0.0f, 40.0f, self.frame.size.width, 20.0f)];
    [scoreValues setNumberOfLines:0];
    [scoreValues setFont:[UIFont boldSystemFontOfSize:17]];
    [scoreValues setTextAlignment:NSTextAlignmentJustified];
    [scoreValues setBackgroundColor:[UIColor grayColor]];
    NSLog(@"tournament: %@", _tournament);
    [scoreValues setText:[NSString stringWithFormat:@"%@ %@", [self.arbiter getPlayerScoreFromTournament:_tournament], [self.arbiter getOpponentScoreFromTournament:_tournament]]];
    
    
    NSLog(@"Display results details");
    if ( [[_tournament objectForKey:@"winners"] containsObject:[self.arbiter.user objectForKey:@"id"]] ) {
        [title setText:@"YOU WON!"];
    } else {
        [title setText:@"You have been defeated"];
    }
                      
//                      [self.tournament objectForKey:@"payout"];
    
    [self addSubview:title];
    [self addSubview:scoreValues];
}


@end
