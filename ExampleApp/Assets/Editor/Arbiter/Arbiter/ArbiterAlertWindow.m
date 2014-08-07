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

- (id)init
{
    self = [super initWithFrame:[[UIScreen mainScreen] bounds]];
    if ( self ) {
        self.rootViewController = [[ArbiterAlertViewController alloc] init];
    }
    return self;
}

- (void)show:(UIView *)view
{
    [self makeKeyAndVisible];
    [self addSubview:view];
}

- (void)hide:(UIView *)view
{
    if ( view ) {
        [view removeFromSuperview];
    } else {
        [self setHidden:YES];
    }
}

@end
