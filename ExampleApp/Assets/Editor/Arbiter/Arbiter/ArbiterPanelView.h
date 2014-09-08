//
//  ArbiterPanelView.h
//  Unity-iPhone
//
//  Created by Andy Zinsser on 9/3/14.
//
//

#import <UIKit/UIKit.h>
#import "Arbiter.h"
#import "ArbiterPanelWindow.h"

@interface ArbiterPanelView : UIView <UITableViewDelegate, UITableViewDataSource>

@property (assign) Arbiter *arbiter;
@property (assign) ArbiterPanelWindow *parentWindow;

@property CGRect marginizedFrame;
@property float maxWidth;
@property float maxHeight;
@property float availableHeight;
@property float titleYPos;
@property float titleHeight;

- (id)init:(Arbiter *)arbiterInstance;
- (void)renderLayout;
- (void)animateOut;
- (void)closeButtonClicked:(id)sender;

@end
