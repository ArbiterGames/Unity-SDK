//
//  WithdrawViewController.h
//  Arbiter Example
//
//  Created by Andy Zinsser on 12/10/13.
//  Copyright (c) 2013 Arbiter. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WithdrawViewController : UITableViewController

@property (strong, nonatomic) IBOutlet UILabel *walletBalanceField;
@property (strong, nonatomic) IBOutlet UIButton *refreshBalanceButton;
@property (strong, nonatomic) IBOutlet UITextField *withdrawAmountField;
@property (strong, nonatomic) IBOutlet UITextField *withdrawAddressField;
@property (strong, nonatomic) IBOutlet UIButton *submitWithdrawButton;

- (IBAction)refreshBalanceButtonPressed:(id)sender;
- (void)refreshArbiterUserData;
- (void)shouldEnableSubmitButton;
- (IBAction)submitWithdrawButtonPressed:(id)sender;
- (IBAction)amountFieldEditingChanged:(id)sender;
- (IBAction)addressFieldEditingChanged:(id)sender;

@end
