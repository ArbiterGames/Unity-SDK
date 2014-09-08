//
//  ArbiterTournamentResultsView.m
//  Unity-iPhone
//
//  Created by Andy Zinsser on 9/2/14.
//
//

#import "ArbiterTournamentResultsView.h"

@implementation ArbiterTournamentResultsView

- (id)initWithCallback:(void(^)(void))callback arbiterInstance:(Arbiter *)arbiterInstance andTournament:(NSDictionary*)tournament
{
    self = [super init:arbiterInstance];
    if ( self ) {
        self.tournament = tournament;
    }
    return self;
}

- (void)renderLayout
{
    [super renderLayout];
    
    float segmentedControlHeight = 40.0;
    float titleYPos = 10.0;
    float titleHeight = 40.0;
    float segmentedControlYPosFromBottom = 30.0;
    float maxWidth = 400.0;
    
    if ( self.bounds.size.width > maxWidth ) {
        self.marginizedFrame = CGRectMake((self.bounds.size.width - maxWidth) / 2, 0.0,
                                          maxWidth, self.bounds.size.height - titleHeight - titleYPos - segmentedControlHeight - segmentedControlYPosFromBottom);
    } else {
        self.marginizedFrame = CGRectMake(0.0, 0.0, self.bounds.size.width, self.bounds.size.height - titleHeight - titleYPos - segmentedControlHeight - segmentedControlYPosFromBottom);
    }
    
    UILabel *title = [[UILabel alloc] initWithFrame:CGRectMake(50.0, titleYPos, self.frame.size.width - 100.0, titleHeight)];
    title.font = [UIFont fontWithName:@"HelveticaNeue-UltraLight" size:38.0];
    title.textColor = [UIColor whiteColor];
    title.textAlignment = NSTextAlignmentCenter;
    if ( [[self.tournament objectForKey:@"winners"] containsObject:[self.arbiter.user objectForKey:@"id"]] ) {
        [title setText:@"You Won!"];
    } else {
        [title setText:@"You Lost"];
    }
    [self addSubview:title];
    
    CALayer *topBorder = [CALayer layer];
    topBorder.frame = CGRectMake(0.0, titleYPos + titleHeight + 10.0, self.frame.size.width, 0.5f);
    topBorder.backgroundColor = [[UIColor grayColor] CGColor];
    [self.layer addSublayer:topBorder];
    
    UILabel *playerScore = [[UILabel alloc] initWithFrame:CGRectMake(self.frame.size.width / 2, 60.0f, self.frame.size.width / 4, 20.0f)];
    [playerScore setFont:[UIFont boldSystemFontOfSize:23]];
    [playerScore setTextAlignment:NSTextAlignmentCenter];
    [playerScore setText:[self.arbiter getPlayerScoreFromTournament:self.tournament]];
    
    UILabel *playerLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.frame.size.width / 2, 80.0f, self.frame.size.width / 4, 40.0f)];
    [playerLabel setNumberOfLines:0];
    [playerLabel setFont:[UIFont systemFontOfSize:14]];
    [playerLabel setTextAlignment:NSTextAlignmentCenter];
    [playerLabel setText:@"your\nscore"];
    
    UILabel *opponentScore = [[UILabel alloc] initWithFrame:CGRectMake(self.frame.size.width / 4 * 3, 60.0f, self.frame.size.width / 4, 20.0f)];
    [opponentScore setFont:[UIFont boldSystemFontOfSize:23]];
    [opponentScore setTextAlignment:NSTextAlignmentCenter];
    [opponentScore setText:[self.arbiter getOpponentScoreFromTournament:self.tournament]];
    
    UILabel *opponentLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.frame.size.width / 4 * 3, 80.0f, self.frame.size.width / 4, 40.0f)];
    [opponentLabel setNumberOfLines:0];
    [opponentLabel setFont:[UIFont systemFontOfSize:12]];
    [opponentLabel setTextAlignment:NSTextAlignmentCenter];
    [opponentLabel setText:@"opponent\nscore"];
    
    UILabel *scoreDivider = [[UILabel alloc] initWithFrame:CGRectMake(self.frame.size.width / 48 * 35, 80.0f, self.frame.size.width / 40, 35.0f)];
    [scoreDivider setNumberOfLines:0];
    [scoreDivider setFont:[UIFont systemFontOfSize:14]];
    [scoreDivider setTextAlignment:NSTextAlignmentCenter];
    [scoreDivider setTextColor:[UIColor grayColor]];
    [scoreDivider setText:@"vs"];
    
    UILabel *payout = [[UILabel alloc] initWithFrame:CGRectMake(0.0f, 55.0f, self.frame.size.width / 2, 40.0f)];
    [payout setFont:[UIFont boldSystemFontOfSize:40]];
    [payout setTextAlignment:NSTextAlignmentCenter];
    [payout setText:[self.tournament objectForKey:@"payout"]];
    
    
    UILabel *payoutLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0f, 65.0f, self.frame.size.width / 2, 70.0f)];
    [payoutLabel setFont:[UIFont systemFontOfSize:14]];
    [payoutLabel setTextAlignment:NSTextAlignmentCenter];
    [payoutLabel setText:@"credits"];
    
    [self addSubview:title];
    [self addSubview:payout];
    [self addSubview:payoutLabel];
    [self addSubview:playerScore];
    [self addSubview:playerLabel];
    [self addSubview:scoreDivider];
    [self addSubview:opponentScore];
    [self addSubview:opponentLabel];

}

//- (void)setupNextScreen
//{
//    UILabel *title = [[UILabel alloc] initWithFrame:CGRectMake(0.0f, 10.0f, self.frame.size.width, 20.0f)];
//    [title setFont:[UIFont boldSystemFontOfSize:21]];
//    [title setTextAlignment:NSTextAlignmentCenter];
//    if ( [[_tournament objectForKey:@"winners"] containsObject:[self.arbiter.user objectForKey:@"id"]] ) {
//        [title setText:@"You Won!"];
//    } else {
//        [title setText:@"You Lost"];
//    }
//    
//    UILabel *playerScore = [[UILabel alloc] initWithFrame:CGRectMake(self.frame.size.width / 2, 60.0f, self.frame.size.width / 4, 20.0f)];
//    [playerScore setFont:[UIFont boldSystemFontOfSize:23]];
//    [playerScore setTextAlignment:NSTextAlignmentCenter];
//    [playerScore setText:[self.arbiter getPlayerScoreFromTournament:_tournament]];
//
//    UILabel *playerLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.frame.size.width / 2, 80.0f, self.frame.size.width / 4, 40.0f)];
//    [playerLabel setNumberOfLines:0];
//    [playerLabel setFont:[UIFont systemFontOfSize:14]];
//    [playerLabel setTextAlignment:NSTextAlignmentCenter];
//    [playerLabel setText:@"your\nscore"];
//    
//    UILabel *opponentScore = [[UILabel alloc] initWithFrame:CGRectMake(self.frame.size.width / 4 * 3, 60.0f, self.frame.size.width / 4, 20.0f)];
//    [opponentScore setFont:[UIFont boldSystemFontOfSize:23]];
//    [opponentScore setTextAlignment:NSTextAlignmentCenter];
//    [opponentScore setText:[self.arbiter getOpponentScoreFromTournament:_tournament]];
//    
//    UILabel *opponentLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.frame.size.width / 4 * 3, 80.0f, self.frame.size.width / 4, 40.0f)];
//    [opponentLabel setNumberOfLines:0];
//    [opponentLabel setFont:[UIFont systemFontOfSize:12]];
//    [opponentLabel setTextAlignment:NSTextAlignmentCenter];
//    [opponentLabel setText:@"opponent\nscore"];
//    
//    UILabel *scoreDivider = [[UILabel alloc] initWithFrame:CGRectMake(self.frame.size.width / 48 * 35, 80.0f, self.frame.size.width / 40, 35.0f)];
//    [scoreDivider setNumberOfLines:0];
//    [scoreDivider setFont:[UIFont systemFontOfSize:14]];
//    [scoreDivider setTextAlignment:NSTextAlignmentCenter];
//    [scoreDivider setTextColor:[UIColor grayColor]];
//    [scoreDivider setText:@"vs"];
//    
//    UILabel *payout = [[UILabel alloc] initWithFrame:CGRectMake(0.0f, 55.0f, self.frame.size.width / 2, 40.0f)];
//    [payout setFont:[UIFont boldSystemFontOfSize:40]];
//    [payout setTextAlignment:NSTextAlignmentCenter];
//    [payout setText:[_tournament objectForKey:@"payout"]];
//    
//    
//    UILabel *payoutLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0f, 65.0f, self.frame.size.width / 2, 70.0f)];
//    [payoutLabel setFont:[UIFont systemFontOfSize:14]];
//    [payoutLabel setTextAlignment:NSTextAlignmentCenter];
//    [payoutLabel setText:@"credits"];
//    
//    [self addSubview:title];
////    [self addSubview:coinImage];
//    [self addSubview:payout];
//    [self addSubview:payoutLabel];
//    [self addSubview:playerScore];
//    [self addSubview:playerLabel];
//    [self addSubview:scoreDivider];
//    [self addSubview:opponentScore];
//    [self addSubview:opponentLabel];
//}


@end
