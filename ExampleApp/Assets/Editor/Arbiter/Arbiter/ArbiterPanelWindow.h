//
//  ArbiterPanelWindow.h
//  Unity-iPhone
//
//  Created by Andy Zinsser on 9/3/14.
//
//

#import <UIKit/UIKit.h>

@interface ArbiterPanelWindow : UIWindow

@property (strong) UIWindow *gameWindow;

- (id)initWithGameWindow:(UIWindow *)gameWindow;
- (void)show:(UIView *)view;
- (void)hide;


@end
