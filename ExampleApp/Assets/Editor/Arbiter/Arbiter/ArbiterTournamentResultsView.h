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
@property (strong) void (^callback)(void);

- (id)initWithTournament:(NSDictionary *)tournament arbiterInstance:(Arbiter *)arbiterInstance;
- (void)backButtonClicked:(id)sender;

@end