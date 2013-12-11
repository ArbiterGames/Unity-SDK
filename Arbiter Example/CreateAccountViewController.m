//
//  CreateAccountViewController.m
//  Arbiter Example
//
//  Created by Andy Zinsser on 12/10/13.
//  Copyright (c) 2013 Arbiter. All rights reserved.
//

#import "CreateAccountViewController.h"
#import "WelcomeViewController.h"
#import <Parse/Parse.h>
#import "GlobalData.h"

@interface CreateAccountViewController ()

@end

@implementation CreateAccountViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = @"Arbiter Account";
    NSLog(@"TODO: Display create account info");
    
    // Add logout navigation bar button
    if ([PFUser currentUser]) {
        UIBarButtonItem *logoutButton = [[UIBarButtonItem alloc] initWithTitle:@"Log Out" style:UIBarButtonItemStyleBordered target:self action:@selector(logoutFromArbiterButtonTouchHandler:)];
        self.navigationItem.leftBarButtonItem = logoutButton;
    }
}

- (void)logoutFromArbiterButtonTouchHandler:(id)sender {
    GlobalData *globals = [GlobalData sharedInstance];
    [PFUser logOut];
    [globals.arbiter logout];
    globals.arbiterUserId = nil;
    globals.arbiter = nil;
    
    [self.tabBarController setSelectedIndex:0];

    WelcomeViewController *welcomeViewController = [[WelcomeViewController alloc] initWithNibName:@"WelcomeViewController" bundle:nil];
    UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:welcomeViewController];
    [self presentViewController:navController animated:YES completion:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
