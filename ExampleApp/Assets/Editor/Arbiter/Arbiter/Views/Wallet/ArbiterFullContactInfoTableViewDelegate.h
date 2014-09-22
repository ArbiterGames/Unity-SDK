//
//  ArbiterFullContactInfoTableViewDelegate.h
//  Unity-iPhone
//
//  Created by Andy Zinsser on 9/7/14.
//
//

#import <UIKit/UIKit.h>
#import "ArbiterWalletWithdrawView.h"

@interface ArbiterFullContactInfoTableViewDelegate : UIView <UITextFieldDelegate, UITableViewDataSource, UITableViewDelegate, WalletWithdrawViewDelegate>

@property (strong) NSString *email;
@property (strong) NSString *fullName;
@property (strong) UITableView *tableView;
@property (strong) void (^callback)(NSDictionary *);

@property (strong) IBOutlet UITextField *emailField;
@property (strong) IBOutlet UITextField *nameField;

- (id)initWithCallback:(void(^)(NSDictionary *))callbackBlock;

- (void)handleNextButton;
- (void)handleBackButton;

@end
