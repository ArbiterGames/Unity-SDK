//
//  AccountDetailsViewController.m
//  Arbiter Example
//
//  Created by Andy Zinsser on 12/10/13.
//  Copyright (c) 2013 Arbiter. All rights reserved.
//

#import "WalletDetailsViewController.h"
#import "WelcomeViewController.h"
#import <Parse/Parse.h>
#import <Arbiter/Arbiter.h>
#import "GlobalData.h"

@interface WalletDetailsViewController ()

@end

@implementation WalletDetailsViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.retryVerificationButton setHidden:YES];
    [self.addressCopy setHidden:YES];
    [self.refreshBalanceButton setHidden:YES];
    
    self.title = @"Wallet Details";
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];

    GlobalData *globals = [GlobalData sharedInstance];
    
    if ([PFUser currentUser]) {
        self.exampleUsernameField.text = [PFUser currentUser].username;
        [self.loginButton setHidden:YES];
    } else {
        self.exampleUsernameField.text = @"Anon";
    }
    
    if (globals.arbiter.session.userId == nil) {
        self.status.text = @"Initializing Arbiter";
        globals.arbiter = [[Arbiter alloc] initWithAccessToken:[NSString stringWithFormat:@"94f08d4a4b7ef48cd0ff878f1d34b4eddcc93392"] gameAPIKey:[NSString stringWithFormat:@"212206ab31d94b4e88874fdec3a8111f"] callback:^(NSString *success){
            if ([success isEqual:@"true"]) {
                [self refreshArbiterUserData];
            } else {
                NSLog(@"Error initing arbiter");
            }
        }];
    }
    
    [self refreshArbiterUserData];
}

- (void)getWalletDetails {
    GlobalData *globals = [GlobalData sharedInstance];

    // TODO: Save the user_id with this user on the game server so the server can make calls on this users behalf
    
    self.status.text = @"Getting wallet details...";
    [globals.arbiter getWalletDetailsWithCallback:^(NSString *success){
        if ([success isEqual:@"true"]) {
            self.status.text = @"User is ready to deposit";
            [self refreshArbiterUserData];
        } else {
            self.status.text = @"Verify to receive a wallet";
            [self.retryVerificationButton setHidden:NO];
        }
    }];
}

- (void)refreshArbiterUserData
{
    GlobalData *globals = [GlobalData sharedInstance];
    self.walletBalanceField.text = globals.arbiter.wallet.balance;
    self.walletDepositAddressField.text = globals.arbiter.wallet.depositAddress;
    self.arbiterUserIdField.text = globals.arbiter.session.userId;
    self.arbiterUsernameField.text = globals.arbiter.session.username;
    
    if (globals.arbiter.wallet.balance.length == 0) {
        self.status.text = @"Verify to get wallet details";
        [self.retryVerificationButton setHidden:NO];
    } else {
        [self.addressCopy setHidden:NO];
        [self.refreshBalanceButton setHidden:NO];
    }
}

- (IBAction)copyAddressButtonPressed:(id)sender {
    GlobalData *globals = [GlobalData sharedInstance];
    UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
    pasteboard.string = globals.arbiter.wallet.depositAddress;
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Successfully copied wallet address" message:@"Send some Bitcoin to that address to start playing." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [alert show];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)retryVerificationButtonPressed:(id)sender {
    [self.retryVerificationButton setHidden:YES];
    [self getWalletDetails];
}

- (IBAction)refreshBalanceButtonPressed:(id)sender {
    GlobalData *globals = [GlobalData sharedInstance];
    [globals.arbiter getWalletDetailsWithCallback:^(NSString *success) {
        [self refreshArbiterUserData];
    }];
}

- (IBAction)loginButtonPressed:(id)sender {
    [self.loginButton setHidden:YES];
    WelcomeViewController *welcomeViewController = [[WelcomeViewController alloc] initWithNibName:@"WelcomeViewController" bundle:nil];
    UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:welcomeViewController];
    [self presentViewController:navController animated:YES completion:nil];

}
@end
