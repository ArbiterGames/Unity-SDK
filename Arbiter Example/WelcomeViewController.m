//
//  WelcomeViewController.m
//  Arbiter Demo
//
//  Created by Andy Zinsser on 12/4/13.
//  Copyright (c) 2013 Arbiter. All rights reserved.
//


#import "WelcomeViewController.h"

//#import "DashboardViewController.h"
#import "LoginViewController.h"
#import "NewUserViewController.h"

@implementation WelcomeViewController

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    self.title = @"Select method for login";
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - Transition methods

- (IBAction)loginButtonSelected:(id)sender {
	LoginViewController *loginViewController = [[LoginViewController alloc] initWithCallback:^(NSString *success) {
        [self dismissViewControllerAnimated:NO completion:nil];
    }];
    [self.navigationController presentViewController:loginViewController animated:YES completion:nil];
}

- (IBAction)createButtonSelected:(id)sender {
    NewUserViewController *newUserViewController = [[NewUserViewController alloc] initWithCallback:^(NSString *success) {
        [self dismissViewControllerAnimated:NO completion:nil];
    }];
	[self.navigationController presentViewController:newUserViewController animated:YES completion:nil];
}

- (IBAction)anonymousButtonSelected:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - View lifecycle

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end

