//
//  ArbiterContactInfoTableViewDelegate.h
//  Unity-iPhone
//
//  Created by Andy Zinsser on 9/4/14.
//
//

#import <UIKit/UIKit.h>


@interface ArbiterContactInfoTableViewDelegate : UIView <UITextFieldDelegate, UITableViewDataSource, UITableViewDelegate>

@property (strong) NSString *email;
@property (strong) NSString *username;
@property (strong) void (^callback)(NSDictionary *);
@property (strong) UITableView *tableView;
@property (strong) IBOutlet UITextField *emailField;
@property (strong) IBOutlet UITextField *usernameField;

- (id)initWithCallback:(void(^)(NSDictionary *))callback;

@end
