//
//  ArbiterAlertWindow.m
//  Unity-iPhone
//
//  Created by Andy Zinsser on 8/6/14.
//
//

#import "ArbiterAlertWindow.h"
#import "ArbiterAlertViewController.h"


@implementation ArbiterAlertWindow

- (id)initWithGameWindow:(UIWindow *)gameWindow
{
    self = [super initWithFrame:[[UIScreen mainScreen] bounds]];
    if ( self ) {
        self.gameWindow = gameWindow;
        self.rootViewController = [[ArbiterAlertViewController alloc] init];
    }
    return self;
}

- (void)show:(UIView *)view
{
    [self makeKeyAndVisible];
    [self addSubview:view];
}

- (void)hide
{
    for ( UIView *view in [self.rootViewController.view subviews] ) {
        [view removeFromSuperview];
    }
    
    for ( UIWindow *window in [[UIApplication sharedApplication] windows] ) {
        if ( window == self.gameWindow ) {
            [self.gameWindow makeKeyAndVisible];
        }
    }
}

@end
