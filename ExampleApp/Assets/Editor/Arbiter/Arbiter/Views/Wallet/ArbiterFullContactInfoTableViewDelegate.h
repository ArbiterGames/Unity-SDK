//
//  ArbiterFullContactInfoTableViewDelegate.h
//  Unity-iPhone
//
//  Created by Andy Zinsser on 9/7/14.
//
//

#import <UIKit/UIKit.h>

@interface ArbiterFullContactInfoTableViewDelegate : UIView <UITextFieldDelegate, UITableViewDataSource, UITableViewDelegate>

@property (strong) NSString *email;
@property (strong) NSString *fullName;
@property (strong) void (^callback)(NSDictionary *);

@property (strong) IBOutlet UITextField *emailField;
@property (strong) IBOutlet UITextField *nameField;

- (id)initWithCallback:(void(^)(NSDictionary *))callbackBlock;

@end
