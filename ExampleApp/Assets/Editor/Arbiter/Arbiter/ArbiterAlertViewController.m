//
//  ArbiterAlertViewController.m
//  Unity-iPhone
//
//  Created by Andy Zinsser on 8/6/14.
//
//

#import "ArbiterAlertViewController.h"
#import "ArbiterAlertView.h"

@implementation ArbiterAlertViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view = [[UIView alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.view.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.3f];
    
    // TODO: Animate in
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    for ( UIView *view in self.view.subviews ) {
        NSLog(@"setting frame from rotation");
        [view setFrame:[[UIScreen mainScreen] bounds]];
    }
}

- (BOOL)prefersStatusBarHidden
{
    return YES;
}

- (BOOL)shouldAutorotate
{
    return YES;
}

@end
