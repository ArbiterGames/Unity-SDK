//
//  ARBSCOfficialRules.h
//  Unity-iPhone
//
//  Created by Andy Zinsser on 10/16/14.
//
//

#import "ARBPanelView.h"

@interface ARBSCOfficialRules : ARBPanelView <UITableViewDataSource, UITableViewDelegate>

@property (strong) void (^callback)(void);
@property (strong) NSString *challengeId;
@property (strong) NSString *rules;

- (id)initWithChallengeId:(NSString *)challengeId arbiterInstance:(Arbiter *)arbiterInstance;
- (void)backButtonClicked:(id)sender;

@end
