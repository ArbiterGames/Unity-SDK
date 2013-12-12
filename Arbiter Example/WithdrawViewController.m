//
//  WithdrawViewController.m
//  Arbiter Example
//
//  Created by Andy Zinsser on 12/10/13.
//  Copyright (c) 2013 Arbiter. All rights reserved.
//

#import "WithdrawViewController.h"
#import "GlobalData.h"

@interface WithdrawViewController ()

@end

@implementation WithdrawViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.submitWithdrawButton setEnabled:NO];
    self.title = @"Withdraw";
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self refreshArbiterUserData];
}

- (void)refreshArbiterUserData
{
    GlobalData *globals = [GlobalData sharedInstance];
    self.walletBalanceField.text = globals.arbiter.wallet.balance;
    
    if (globals.arbiter.wallet.previousWithdrawAddress) {
        self.withdrawAddressField.text = globals.arbiter.wallet.previousWithdrawAddress;
    }
    
    if (globals.arbiter.wallet.depositAddress) {
        [self.refreshBalanceButton setHidden:NO];
    }
}

- (void)shouldEnableSubmitButton
{
    if (self.withdrawAmountField.text.length > 0 && self.withdrawAddressField.text.length > 0) {
        [self.submitWithdrawButton setEnabled:YES];
    } else {
        [self.submitWithdrawButton setEnabled:NO];
    }
}

- (IBAction)submitWithdrawButtonPressed:(id)sender {
    [self.view endEditing:YES];
    GlobalData *globals = [GlobalData sharedInstance];
    NSDictionary *settings = @{@"amount": self.withdrawAmountField.text,
                               @"address": self.withdrawAddressField.text};
    [globals.arbiter withdrawWithSettings:settings callback:^(NSString *success) {
        self.withdrawAmountField.text = @"";
        [self refreshArbiterUserData];
        [self shouldEnableSubmitButton];
    }];
}


- (IBAction)amountFieldEditingChanged:(id)sender {
    [self shouldEnableSubmitButton];
}

- (IBAction)addressFieldEditingChanged:(id)sender {
    [self shouldEnableSubmitButton];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)refreshBalanceButtonPressed:(id)sender {
    GlobalData *globals = [GlobalData sharedInstance];
    [globals.arbiter getWalletDetailsWithCallback:^(NSString *success) {
        [self refreshArbiterUserData];
    }];
}
@end
