//
//  ArbiterAlertViewController.m
//  Unity-iPhone
//
//  Created by Andy Zinsser on 8/6/14.
//
//

#import "ArbiterAlertViewController.h"

@implementation ArbiterAlertViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view = [[UIView alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.view.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.3f];
    
    // TODO: Animate in
}

- (BOOL)prefersStatusBarHidden
{
    return YES;
}

@end
