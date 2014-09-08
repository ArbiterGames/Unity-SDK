//
//  ArbiterTournamentResultsView.h
//  Unity-iPhone
//
//  Created by Andy Zinsser on 9/2/14.
//
//

#import "ArbiterPanelView.h"

@interface ArbiterTournamentResultsView : ArbiterPanelView <UITableViewDelegate, UITableViewDataSource>

@property (strong) NSDictionary *tournament;

- (id)initWithTournament:(NSDictionary *)tournament arbiterInstance:(Arbiter *)arbiterInstance;

@end