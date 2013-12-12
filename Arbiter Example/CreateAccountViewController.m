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
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self refreshArbiterUserData];
    [self refreshExampleUserData];
}

- (void)shouldEnableClaimButton
{
    if (self.arbiterEmailField.text.length > 0 && self.arbiterPasswordField.text.length > 0) {
        [self.claimAccountButton setEnabled:YES];
    } else {
        [self.claimAccountButton setEnabled:NO];
    }
}

- (void)shouldEnableLoginButton
{
    if (self.arbiterEmailLoginField.text.length > 0 && self.arbiterPasswordLoginField.text.length > 0) {
        [self.arbiterLoginButton setEnabled:YES];
    } else {
        [self.arbiterLoginButton setEnabled:NO];
    }
}

- (void)refreshArbiterUserData
{
    GlobalData *globals = [GlobalData sharedInstance];
    self.arbiterUsernameField.text = globals.arbiter.session.username;
    self.arbiterUserIdField.text = globals.arbiter.session.userId;
    
    if ([globals.arbiter.session.username isEqualToString:@"anonymous"]) {
        self.arbiterEmailField.placeholder = @"";
        [self.arbiterEmailField setEnabled:YES];
        [self.arbiterPasswordField setEnabled:YES];
        
        self.arbiterEmailLoginField.placeholder = @"";
        [self.arbiterEmailLoginField setEnabled:YES];
        [self.arbiterPasswordLoginField setEnabled:YES];
    } else {
        self.arbiterEmailField.placeholder = @"Account already claimed";
        [self.arbiterEmailField setEnabled:NO];
        [self.arbiterPasswordField setEnabled:NO];
        
        self.arbiterEmailLoginField.placeholder = @"Already logged in";
        [self.arbiterEmailLoginField setEnabled:NO];
        [self.arbiterPasswordLoginField setEnabled:NO];
    }
    
    [self shouldEnableClaimButton];
    [self shouldEnableLoginButton];
}

- (void)refreshExampleUserData
{
    GlobalData *globals = [GlobalData sharedInstance];
    if ([PFUser currentUser] || globals.arbiter.session.username.length != 0) {
        if ([PFUser currentUser]) {
            self.exampleUsernameField.text = [PFUser currentUser].username;
            [self.exampleLoginButton setHidden:YES];
        } else {
            self.exampleUsernameField.text = @"Anon";
            [self.exampleLoginButton setHidden:NO];
        }
        UIBarButtonItem *logoutButton = [[UIBarButtonItem alloc] initWithTitle:@"Log Out" style:UIBarButtonItemStyleBordered target:self action:@selector(logoutFromArbiterButtonTouchHandler:)];
        self.navigationItem.leftBarButtonItem = logoutButton;
    } else {
        self.exampleUsernameField.text = @"Anon";
    }
}

- (void)displayExampleLoginView
{
    WelcomeViewController *welcomeViewController = [[WelcomeViewController alloc] initWithNibName:@"WelcomeViewController" bundle:nil];
    UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:welcomeViewController];
    [self presentViewController:navController animated:YES completion:nil];
}

- (void)logoutFromArbiterButtonTouchHandler:(id)sender {
    GlobalData *globals = [GlobalData sharedInstance];
    [PFUser logOut];
    [globals.arbiter logout];
    globals.arbiter = nil;
    
    [self.tabBarController setSelectedIndex:0];
    [self displayExampleLoginView];
}

- (IBAction)claimAccountButtonPressed:(id)sender {
    GlobalData *globals = [GlobalData sharedInstance];
    NSDictionary *credentials = @{@"email": self.arbiterEmailField.text,
                                  @"password": self.arbiterPasswordField.text};
    [globals.arbiter claimAccountWithCredentials:credentials callback:^(NSString *success) {
        NSString *title = nil;
        NSString *message = nil;
        if ([success isEqual:@"true"]) {
            self.arbiterEmailField.text = @"";
            self.arbiterPasswordField.text = @"";
            title = @"Success";
            message = @"Account successfully claimed";
            [self shouldEnableClaimButton];
        } else {
            title = @"Error";
            message = success;
            [self.view endEditing:NO];
        }
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title message:message delegate:nil cancelButtonTitle:@"Close" otherButtonTitles:nil];
        [alert show];
    }];
}

- (IBAction)arbiterEmailFieldEditingChanged:(id)sender {
    [self shouldEnableClaimButton];
}

- (IBAction)arbiterPasswordFieldEditingChanged:(id)sender {
    [self shouldEnableClaimButton];
}

- (IBAction)arbiterEmailLoginFieldEditingChanged:(id)sender {
    [self shouldEnableLoginButton];
}

- (IBAction)arbiterPasswordLoginFieldEditingChanged:(id)sender {
    [self shouldEnableLoginButton];
}

- (IBAction)arbiterLoginButtonPressed:(id)sender {
    GlobalData *globals = [GlobalData sharedInstance];
    NSDictionary *credentials = @{@"email": self.arbiterEmailLoginField.text,
                                  @"password": self.arbiterPasswordLoginField.text};
    [globals.arbiter loginWithCredentials:credentials callback:^(NSString *success) {
        self.arbiterEmailLoginField.text = @"";
        self.arbiterPasswordLoginField.text = @"";
        [self shouldEnableLoginButton];
        [self.view endEditing:NO];
        [self refreshArbiterUserData];
    }];
}

- (IBAction)exampleLoginButtonPressed:(id)sender
{
    [self displayExampleLoginView];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
