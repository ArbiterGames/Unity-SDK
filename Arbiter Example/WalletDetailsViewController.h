//
//  AccountDetailsViewController.h
//  Arbiter Example
//
//  Created by Andy Zinsser on 12/10/13.
//  Copyright (c) 2013 Arbiter. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WalletDetailsViewController : UITableViewController

@property (strong, nonatomic) IBOutlet UILabel *exampleUsernameField;
@property (strong, nonatomic) IBOutlet UILabel *arbiterUsernameField;
@property (strong, nonatomic) IBOutlet UILabel *arbiterUserIdField;
@property (strong, nonatomic) IBOutlet UILabel *walletBalanceField;
@property (strong, nonatomic) IBOutlet UILabel *walletDepositAddressField;
@property (strong, nonatomic) IBOutlet UILabel *status;
@property (strong, nonatomic) IBOutlet UIButton *retryVerificationButton;
@property (strong, nonatomic) IBOutlet UIButton *refreshBalanceButton;
@property (strong, nonatomic) IBOutlet UIButton *addressCopy;

- (void)refreshArbiterUserData;
- (IBAction)copyAddressButtonPressed:(id)sender;
- (IBAction)retryVerificationButtonPressed:(id)sender;
- (IBAction)refreshBalanceButtonPressed:(id)sender;

@end
