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
        self.requestQueue = [[NSMutableDictionary alloc] init];
        self.rootViewController = [[ArbiterAlertViewController alloc] initWithSupportedOrientations:[[gameWindow rootViewController] supportedInterfaceOrientations]];
        self.rootViewController.view.autoresizesSubviews = YES;
        self.spinnerView = [[UIActivityIndicatorView alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
        self.spinnerView.activityIndicatorViewStyle = UIActivityIndicatorViewStyleWhiteLarge;
        self.spinnerView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.5f];
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

- (void)addRequestToQueue:(int)key
{
    NSString *stringKey = [NSString stringWithFormat:@"%d", key];
    if ( [self.requestQueue objectForKey:stringKey] ) {
        [self.requestQueue setObject:@([[self.requestQueue objectForKey:stringKey] intValue] + 1) forKey:stringKey];
    } else {
        [self.requestQueue setObject:@1 forKey:stringKey];
    }
    if ( [self.requestQueue count] > 0 ) {
        UIView *keyRVCV = [[UIApplication sharedApplication] keyWindow].rootViewController.view;
        [self.spinnerView setFrame:keyRVCV.bounds];
        [keyRVCV addSubview:self.spinnerView];
        [self.spinnerView startAnimating];
    }
}

- (void)removeRequestFromQueue:(int)key
{
    NSString *stringKey = [NSString stringWithFormat:@"%d", key];
    [self.requestQueue setObject:@([[self.requestQueue objectForKey:stringKey] intValue] - 1) forKey:stringKey];

    if ( [[self.requestQueue objectForKey:stringKey] intValue] <= 0 ) {
        [self.requestQueue removeObjectForKey:stringKey];
    }
    if ( [self.requestQueue count] == 0 ) {
        [self.spinnerView stopAnimating];
        [self.spinnerView removeFromSuperview];
    } else {
        NSLog(@"Open requests still out: %@", self.requestQueue);
    }
}

@end
