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
    self.rootViewController.view.backgroundColor = [UIColor colorWithPatternImage:[image applyLightEffect]];
    [self.rootViewController.view addSubview:view];
    [self renderPoweredBy];
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

- (void)renderPoweredBy
{
    UILabel *poweredBy = [[UILabel alloc] initWithFrame:CGRectMake((self.rootViewController.view.bounds.size.width - 100) / 2,
                                                                   self.rootViewController.view.bounds.size.height - 40,
                                                                   100.0, 40.0)];
    poweredBy.text = @"powered by Arbiter";
    poweredBy.font = [UIFont systemFontOfSize:11.0];
    poweredBy.textColor = [UIColor whiteColor];
    poweredBy.alpha = 0.3;
    [self.rootViewController.view addSubview:poweredBy];
}

@end
