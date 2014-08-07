//
//  ArbiterAlertWindow.h
//  Unity-iPhone
//
//  Created by Andy Zinsser on 8/6/14.
//
//

#import <UIKit/UIKit.h>
#import "ArbiterAlertViewController.h"


@interface ArbiterAlertWindow : UIWindow

@property (retain) UIWindow *gameWindow;

- (id)initWithGameWindow:(UIWindow *)gameWindow;
- (void)show:(UIView *)view;
- (void)hide;

@end
