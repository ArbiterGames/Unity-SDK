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
{
    BOOL spinnerIsOn;
}

- (id)initWithGameWindow:(UIWindow *)gameWindow
{
    self = [super initWithFrame:[[UIScreen mainScreen] bounds]];
    if ( self ) {
        self.gameWindow = gameWindow;
        self.rootViewController = [[ArbiterAlertViewController alloc] init];
        self.requestQueue = [[NSMutableDictionary alloc] init];
        spinnerIsOn = false;
    }
    return self;
}

- (void)show:(UIView *)view
{
    [self makeKeyAndVisible];
    [self.rootViewController.view addSubview:view];
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

- (void)showSpinner
{
    if ( spinnerIsOn == false ) {
        self.spinnerView = [[UIView alloc] initWithFrame:[[UIScreen mainScreen] bounds]];

        // TODO: Make this an actually spinner instead of white screen
        self.spinnerView.backgroundColor = [UIColor whiteColor];
        
        [[[UIApplication sharedApplication] keyWindow].rootViewController.view addSubview:self.spinnerView];
        
        spinnerIsOn = true;
    }
}

- (void)hideSpinner
{
    if ( spinnerIsOn == true ) {
        [self.spinnerView removeFromSuperview];
        spinnerIsOn = false;
    }
}

- (void)addRequestToQueue:(int)key
{
    NSString *stringKey = [NSString stringWithFormat:@"%d", key];
    if ( [self.requestQueue objectForKey:stringKey] ) {
        [self.requestQueue setObject:@([[self.requestQueue objectForKey:stringKey] intValue] + 1) forKey:stringKey];
    } else {
        [self.requestQueue setObject:@1 forKey:stringKey];
    }
    if ( [self.requestQueue count] > 0 ) {
        [self showSpinner];
    }
}

- (void)removeRequestFromQueue:(int)key
{
    NSString *stringKey = [NSString stringWithFormat:@"%d", key];
    [self.requestQueue setObject:@([[self.requestQueue objectForKey:stringKey] intValue] - 1) forKey:stringKey];

    if ( [[self.requestQueue objectForKey:stringKey] intValue] == 0 ) {
        [self.requestQueue removeObjectForKey:stringKey];
    }

    if ( [self.requestQueue count] == 0 ) {
        [self hideSpinner];
    }
}

@end
