//
//  ArbiterPanelWindow.m
//  Unity-iPhone
//
//  Created by Andy Zinsser on 9/3/14.
//
//

#import "ArbiterPanelWindow.h"
#import "ArbiterPanelViewController.h"
#import "UIImage+ImageEffects.h"
#import "ArbiterPanelView.h"

@implementation ArbiterPanelWindow

- (id)initWithGameWindow:(UIWindow *)gameWindow
{
    self = [super initWithFrame:[[UIScreen mainScreen] bounds]];
    if ( self ) {
        self.gameWindow = gameWindow;
        self.rootViewController = [[ArbiterPanelViewController alloc] initWithSupportedOrientations:[[gameWindow rootViewController] supportedInterfaceOrientations]];
        self.rootViewController.view.autoresizesSubviews = YES;
    }
    return self;
}

- (void)show:(ArbiterPanelView *)view
{
    [self makeKeyAndVisible];
    
    UIImage *image;
    UIGraphicsBeginImageContext(self.gameWindow.rootViewController.view.bounds.size);
    [self.gameWindow.rootViewController.view drawViewHierarchyInRect:self.gameWindow.rootViewController.view.bounds afterScreenUpdates:true];
    image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    view.parentWindow = self;
    self.rootViewController.view.backgroundColor = [UIColor colorWithPatternImage:[image applyDarkEffect]];
    [self.rootViewController.view addSubview:view];
}

- (void)hide
{
    NSLog(@"window.hide!!!!!");
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
