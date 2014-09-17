//
//  ArbiterWalkThrough.h
//  Unity-iPhone
//
//  Created by Andy Zinsser on 9/16/14.
//
//

#import "ArbiterPanelView.h"

@interface ArbiterWalkThrough : ArbiterPanelView

@property (strong) void (^callback)(void);
@property (strong) NSString *walkThroughId;

- (id)initWithWalkThroughId:(NSString *)walkThroughId arbiterInstance:(Arbiter *)arbiterInstance;
- (void)backButtonClicked:(id)sender;

@end
