//
//  ArbiterSCOfficialRules.h
//  Unity-iPhone
//
//  Created by Andy Zinsser on 10/16/14.
//
//

#import "ArbiterPanelView.h"

@interface ArbiterSCOfficialRules : ArbiterPanelView

@property (strong) void (^callback)(void);
@property (strong) NSString *challengeId;

- (id)initWithChallengeId:(NSString *)challengeId arbiterInstance:(Arbiter *)arbiterInstance;
- (void)backButtonClicked:(id)sender;

@end
