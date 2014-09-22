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
    view.parentWindow = self;
    
    UIImage *image;
    UIGraphicsBeginImageContext(self.gameWindow.rootViewController.view.bounds.size);
    [self.gameWindow.rootViewController.view drawViewHierarchyInRect:self.gameWindow.rootViewController.view.bounds afterScreenUpdates:false];
    image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    self.rootViewController.view.backgroundColor = [UIColor colorWithPatternImage:[image applyDarkEffect]];
    [self.rootViewController.view addSubview:view];
    
    BOOL IS_LESS_THAN_IOS8 = [[[UIDevice currentDevice] systemVersion] compare: @"7.9" options: NSNumericSearch] != NSOrderedDescending;
    BOOL IS_LANDSCAPE = UIDeviceOrientationIsLandscape([[UIApplication sharedApplication] statusBarOrientation]);
    CGRect temp = self.frame;
    
    if ( IS_LESS_THAN_IOS8 && IS_LANDSCAPE ) {
        temp.origin.y = temp.size.width;
    } else {
        temp.origin.x = temp.size.width;
    }
    
    self.rootViewController.view.frame = temp;
    temp.origin.y = 0.0;
    temp.origin.x = 0.0;
    self.hidden = NO;
    [UIView animateWithDuration:0.3
                          delay:0.0
                        options: UIViewAnimationCurveEaseOut
                     animations:^{
                         self.rootViewController.view.frame = temp;
                     }
                     completion:nil];
    
    [self renderPoweredBy];
}

- (void)hide
{
    CGRect temp = self.rootViewController.view.frame;
    BOOL IS_LESS_THAN_IOS8 = [[[UIDevice currentDevice] systemVersion] compare: @"7.9" options: NSNumericSearch] != NSOrderedDescending;
    BOOL IS_LANDSCAPE = UIDeviceOrientationIsLandscape([[UIApplication sharedApplication] statusBarOrientation]);
    if ( IS_LESS_THAN_IOS8 && IS_LANDSCAPE ) {
        temp.origin.y = temp.size.width;
    } else {
        temp.origin.x = temp.size.width;
    }
    [UIView animateWithDuration:0.3
                          delay:0.0
                        options: UIViewAnimationCurveEaseOut
                     animations:^{
                         self.rootViewController.view.frame = temp;
                     }
                     completion:^(BOOL finished){
                         self.hidden = YES;
                         for ( UIWindow *window in [[UIApplication sharedApplication] windows] ) {
                             for ( UIView *view in [self.rootViewController.view subviews] ) {
                                 [view removeFromSuperview];
                             }
                             if ( window == self.gameWindow ) {
                                 [self.gameWindow makeKeyAndVisible];
                             }
                         }
                     }];
}

- (void)renderPoweredBy
{
    UILabel *poweredBy = [[UILabel alloc] initWithFrame:CGRectMake((self.rootViewController.view.frame.size.width - 100) / 2,
                                                                   self.rootViewController.view.frame.size.height - 40,
                                                                   100.0, 40.0)];
    poweredBy.text = @"powered by Arbiter";
    poweredBy.font = [UIFont systemFontOfSize:11.0];
    poweredBy.textColor = [UIColor whiteColor];
    poweredBy.alpha = 0.3;
    [self.rootViewController.view addSubview:poweredBy];
}

@end
