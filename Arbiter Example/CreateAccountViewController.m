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

    GlobalData *globals = [GlobalData sharedInstance];
    [self shouldEnableSubmitButton];
    self.title = @"Arbiter Account";
    self.arbiterUserIdField.text = globals.arbiter.session.userId;
    self.arbiterUsernameField.text = globals.arbiter.session.username;
    
    // Add logout navigation bar button
    if ([PFUser currentUser]) {
        self.exampleUsernameField.text = [PFUser currentUser].username;
        UIBarButtonItem *logoutButton = [[UIBarButtonItem alloc] initWithTitle:@"Log Out" style:UIBarButtonItemStyleBordered target:self action:@selector(logoutFromArbiterButtonTouchHandler:)];
        self.navigationItem.leftBarButtonItem = logoutButton;
    } else {
        self.exampleUsernameField.text = @"Anonymous";
    }
    
    if (![globals.arbiter.session.username isEqual:@"anonymous"]) {
        self.arbiterEmailField.placeholder = @"Account already claimed";
        self.arbiterPasswordField.placeholder = @"Account already claimed";
        [self.arbiterEmailField setEnabled:NO];
        [self.arbiterPasswordField setEnabled:NO];
    }
}

- (void)shouldEnableSubmitButton
{
    if (self.arbiterEmailField.text.length > 0 && self.arbiterPasswordField.text.length > 0) {
        [self.claimAccountButton setEnabled:YES];
    } else {
        [self.claimAccountButton setEnabled:NO];
    }
}

- (void)logoutFromArbiterButtonTouchHandler:(id)sender {
    GlobalData *globals = [GlobalData sharedInstance];
    [PFUser logOut];
    [globals.arbiter logout];
    globals.arbiter = nil;
    
    [self.tabBarController setSelectedIndex:0];

    WelcomeViewController *welcomeViewController = [[WelcomeViewController alloc] initWithNibName:@"WelcomeViewController" bundle:nil];
    UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:welcomeViewController];
    [self presentViewController:navController animated:YES completion:nil];
}

- (IBAction)claimAccountButtonPressed:(id)sender {
    NSLog(@"Claim account");
    GlobalData *globals = [GlobalData sharedInstance];
    NSDictionary *credentials = @{@"email": self.arbiterEmailField.text,
                                  @"password": self.arbiterPasswordField.text};
    [globals.arbiter claimAccountWithCredentials:credentials callback:^(NSString *success) {
        self.arbiterEmailField.text = @"";
        self.arbiterPasswordField.text = @"";
        [self shouldEnableSubmitButton];
    }];
}

- (IBAction)arbiterEmailFieldEditingChanged:(id)sender {
    [self shouldEnableSubmitButton];
}

- (IBAction)arbiterPasswordFieldEditingChanged:(id)sender {
    [self shouldEnableSubmitButton];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
@end
