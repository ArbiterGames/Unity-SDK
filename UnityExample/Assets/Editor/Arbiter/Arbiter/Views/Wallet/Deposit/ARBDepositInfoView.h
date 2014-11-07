//
//  ARBDepositInfoView.h
//  Unity-iPhone
//
//  Created by Andy Zinsser on 9/4/14.
//
//

#import <UIKit/UIKit.h>
#import "ARBWalletDepositView.h"


@interface ARBDepositInfoView : UIView <UITextFieldDelegate, UITableViewDataSource, UITableViewDelegate, WalletDepositViewDelegate>

@property (strong) NSString *email;
@property (strong) NSString *username;
@property (strong) void (^callback)(NSDictionary *);
@property (strong) UITableView *tableView;

@property (strong) IBOutlet UITextField *emailField;
@property (strong) IBOutlet UITextField *usernameField;

- (id)initWithCallback:(void(^)(NSDictionary *))callback;

- (void)handleNextButton;
- (void)handleBackButton;

@end
