//
//  ARBPanelView.h
//  Unity-iPhone
//
//  Created by Andy Zinsser on 9/3/14.
//
//

#import <UIKit/UIKit.h>
#import "Arbiter.h"
#import "ARBPanelWindow.h"

@interface ARBPanelView : UIView <UITableViewDelegate, UITableViewDataSource>

@property (strong) Arbiter *arbiter;
@property (strong) ARBPanelWindow *parentWindow;

@property float maxWidth;
@property float maxHeight;
@property float availableHeight;
@property float titleYPos;
@property float titleHeight;

- (id)init:(Arbiter *)arbiterInstance;
- (void)renderLayout;
- (void)closeButtonClicked:(id)sender;

@end
