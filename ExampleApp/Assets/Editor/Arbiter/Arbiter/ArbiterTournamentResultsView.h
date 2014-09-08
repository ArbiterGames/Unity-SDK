//
//  ArbiterTournamentResultsView.h
//  Unity-iPhone
//
//  Created by Andy Zinsser on 9/2/14.
//
//

//#import "ArbiterAlertView.h"

//@interface ArbiterTournamentResultsView : ArbiterAlertView
//
//- (id)initWithCallback:(void(^)(void))callback arbiterInstance:(Arbiter *)arbiterInstance andTournament:(NSDictionary*)tournament;
//
//@end

#import "ArbiterPanelView.h"

@interface ArbiterTournamentResultsView : ArbiterPanelView

@property CGRect marginizedFrame;
@property (strong) NSDictionary *tournament;

@end