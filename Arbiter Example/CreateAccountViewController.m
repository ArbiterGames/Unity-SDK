//
//  CreateAccountViewController.m
//  Arbiter Example
//
//  Created by Andy Zinsser on 12/10/13.
//  Copyright (c) 2013 Arbiter. All rights reserved.
//

#import <Parse/Parse.h>
#import <GameKit/GameKit.h>
#import "CreateAccountViewController.h"
#import "WelcomeViewController.h"
#import "GlobalData.h"

@interface CreateAccountViewController ()

@end

@implementation CreateAccountViewController

@synthesize cachedController = _cachedController;

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
    
    if (globals.localPlayer.isAuthenticated) {
        self.gameCenterPlayerIdField.text = globals.localPlayer.playerID;
        [self.gameCenterLoginButton setHidden:YES];
    } else {
        self.gameCenterPlayerIdField.text = @"";
        [self.gameCenterLoginButton setHidden:NO];
    }
}

- (void)displayExampleLoginView
{
    WelcomeViewController *welcomeViewController = [[WelcomeViewController alloc] initWithNibName:@"WelcomeViewController" bundle:nil];
    UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:welcomeViewController];
    [self presentViewController:navController animated:YES completion:nil];
}

- (void)displayGameCenterLoginWithCallback:(void (^)(NSString *))handler
{
    GlobalData *globals = [GlobalData sharedInstance];
    _completionHandler = [handler copy];
    
    __weak GKLocalPlayer *blockLocalPlayer = globals.localPlayer;
    blockLocalPlayer.authenticateHandler = ^(UIViewController *viewController, NSError *error) {
        if (viewController != nil) {
            _cachedController = [[UIApplication sharedApplication] keyWindow].rootViewController;
            [[UIApplication sharedApplication] keyWindow].rootViewController = viewController;
        } else if (blockLocalPlayer.isAuthenticated) {
            if (_cachedController != nil) {
                [[UIApplication sharedApplication] keyWindow].rootViewController = _cachedController;
                _cachedController = nil;
            }
            
            _completionHandler(@"true");
            _completionHandler = nil;
            [self refreshExampleUserData];
        } else {
            [[UIApplication sharedApplication] keyWindow].rootViewController = _cachedController;
            _cachedController = nil;
            _completionHandler(@"true");
            _completionHandler = nil;
            [self refreshExampleUserData];
        }
    };
}

- (void)generateGameCenterSignature
{
    GlobalData *globals = [GlobalData sharedInstance];
    [globals.arbiter loginWithGameCenterPlayer:globals.localPlayer callback:^(NSString *success) {
        NSLog(@"handler.success: %@", success);
        NSLog(@"TODO: Once the arbiter account is linked to game center, be sure we are getting the user back, then refresh the arbiterUserData");
    }];
}

- (void)logoutFromArbiterButtonTouchHandler:(id)sender {
    GlobalData *globals = [GlobalData sharedInstance];
    // Logout of parse
    [PFUser logOut];
    
    // Logout of arbiter
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

- (IBAction)claimAccountUsingGameCenterButtonPressed:(id)sender {
    GlobalData *globals = [GlobalData sharedInstance];
    if (!globals.localPlayer.isAuthenticated) {
        [self displayGameCenterLoginWithCallback:^(NSString *success) {
            [self generateGameCenterSignature];
        }];
    }
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

- (IBAction)gameCenterLoginButtonPressed:(id)sender {
    [self displayGameCenterLoginWithCallback:^(NSString *success) {
        [self generateGameCenterSignature];
    }];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
