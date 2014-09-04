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

- (id)init:(Arbiter *)arbiterInstance;
- (void)renderLayout;
- (void)closeButtonClicked:(id)sender;

@end
