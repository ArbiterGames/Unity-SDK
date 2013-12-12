//
//  CreateAccountViewController.h
//  Arbiter Example
//
//  Created by Andy Zinsser on 12/10/13.
//  Copyright (c) 2013 Arbiter. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CreateAccountViewController : UITableViewController

@property (strong, nonatomic) IBOutlet UILabel *exampleUsernameField;
@property (strong, nonatomic) IBOutlet UILabel *arbiterUsernameField;
@property (strong, nonatomic) IBOutlet UILabel *arbiterUserIdField;
@property (strong, nonatomic) IBOutlet UIButton *claimAccountButton;
@property (strong, nonatomic) IBOutlet UITextField *arbiterEmailField;
@property (strong, nonatomic) IBOutlet UITextField *arbiterPasswordField;
@property (strong, nonatomic) IBOutlet UITextField *arbiterEmailLoginField;
@property (strong, nonatomic) IBOutlet UITextField *arbiterPasswordLoginField;
@property (strong, nonatomic) IBOutlet UIButton *arbiterLoginButton;
@property (strong, nonatomic) IBOutlet UIButton *exampleLoginButton;

- (void)shouldEnableClaimButton;
- (void)shouldEnableLoginButton;
- (void)refreshArbiterUserData;
- (void)refreshExampleUserData;
- (void)displayExampleLoginView;
- (void)logoutFromArbiterButtonTouchHandler:(id)sender;
- (IBAction)claimAccountButtonPressed:(id)sender;
- (IBAction)arbiterEmailFieldEditingChanged:(id)sender;
- (IBAction)arbiterPasswordFieldEditingChanged:(id)sender;
- (IBAction)arbiterEmailLoginFieldEditingChanged:(id)sender;
- (IBAction)arbiterPasswordLoginFieldEditingChanged:(id)sender;
- (IBAction)arbiterLoginButtonPressed:(id)sender;
- (IBAction)exampleLoginButtonPressed:(id)sender;

@end
