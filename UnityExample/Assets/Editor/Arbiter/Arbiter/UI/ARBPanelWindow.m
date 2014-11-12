//
//  ARBPanelWindow.m
//  Unity-iPhone
//
//  Created by Andy Zinsser on 9/3/14.
//
//

#import "ARBPanelWindow.h"
#import "ARBPanelViewController.h"
#import "UIImage+ImageEffects.h"
#import "ARBPanelView.h"
#import "ARBTracking.h"

@implementation ARBPanelWindow

- (id)initWithGameWindow:(UIWindow *)gameWindow
{
    self = [super initWithFrame:[[UIScreen mainScreen] bounds]];
    if ( self ) {
        self.gameWindow = gameWindow;
        self.rootViewController = [[ARBPanelViewController alloc] initWithSupportedOrientations:[[gameWindow rootViewController] supportedInterfaceOrientations]];
        self.rootViewController.view.autoresizesSubviews = YES;
    }
    return self;
}

- (void)show:(ARBPanelView *)view
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
    CGFloat POWERED_BY_WIDTH = 100.0;
    CGFloat HELP_BTN_WIDTH =70.0;
    CGFloat BTN_HEIGHT = 40.0;
    CGFloat PADDING = 5.0;
    
    BOOL IS_LESS_THAN_IOS8 = [[[UIDevice currentDevice] systemVersion] compare: @"7.9" options: NSNumericSearch] != NSOrderedDescending;
    BOOL IS_LANDSCAPE = UIDeviceOrientationIsLandscape([[UIApplication sharedApplication] statusBarOrientation]);
    float yOrigin = self.rootViewController.view.frame.size.height - BTN_HEIGHT;
    float xOrigin = (self.rootViewController.view.frame.size.width - POWERED_BY_WIDTH - HELP_BTN_WIDTH) / 2;
    if ( IS_LESS_THAN_IOS8 && IS_LANDSCAPE ) {
        yOrigin = self.rootViewController.view.frame.size.width - BTN_HEIGHT;
        xOrigin = (self.rootViewController.view.frame.size.height - POWERED_BY_WIDTH - HELP_BTN_WIDTH) / 2;
    }
    
    UILabel *poweredBy = [[UILabel alloc] initWithFrame:CGRectMake(xOrigin, yOrigin, POWERED_BY_WIDTH, BTN_HEIGHT)];
    poweredBy.text = @"Powered by Arbiter";
    poweredBy.font = [UIFont systemFontOfSize:11.0];
    poweredBy.textColor = [UIColor whiteColor];
    poweredBy.alpha = 0.3;
    [self.rootViewController.view addSubview:poweredBy];
    
    UIButton *helpBtn = [[UIButton alloc] initWithFrame:CGRectMake(xOrigin + POWERED_BY_WIDTH + PADDING, yOrigin,
                                                                 HELP_BTN_WIDTH, BTN_HEIGHT)];
    [helpBtn setTitle:@"Need help?" forState:UIControlStateNormal];
    helpBtn.titleLabel.font = [UIFont systemFontOfSize:11.0];
    helpBtn.titleLabel.textColor = [UIColor whiteColor];
    helpBtn.alpha = 0.5;
    [helpBtn addTarget:self action:@selector(helpButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self.rootViewController.view addSubview:helpBtn];

}

#pragma mark Click Handlers

- (void)helpButtonClicked:(id)sender
{
    NSString *title = @"Arbiter Cash Challenges";
    NSString *message = @"This game is using Arbiter to power the Cash Challenges offered in-game. If you have any questions or experience any issues, don't hesitate to reach out to Arbiter at support@arbiter.me";
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title
                                                      message:message
                                                     delegate:self
                                            cancelButtonTitle:@"Close"
                                            otherButtonTitles:@"Visit Arbiter Support", nil];
    [alert show];
}

#pragma mark UIAlertView Delegate Methods

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{

    if ( buttonIndex == 1 ) {
        [[ARBTracking arbiterInstance] track:@"Opened Support Link"];
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://support.arbiter.me/"]];
    }
}

@end
