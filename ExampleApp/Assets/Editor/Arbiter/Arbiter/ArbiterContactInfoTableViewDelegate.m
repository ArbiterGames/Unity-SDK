//
//  ArbiterContactInfoTableViewDelegate.m
//  Unity-iPhone
//
//  Created by Andy Zinsser on 9/4/14.
//
//

#import "ArbiterContactInfoTableViewDelegate.h"

#define CELL_EMAIL_FIELD_TAG 1
#define CELL_USERNAME_FIELD_TAG 2

@implementation ArbiterContactInfoTableViewDelegate

- (id)initWithCallback:(void(^)(NSDictionary *))callbackBlock
{
    self = [super init];
    if ( self ) {
        self.callback = callbackBlock;

        self.emailField = [[UITextField alloc] init];
        self.emailField.textColor = [UIColor whiteColor];
        self.emailField.autocorrectionType = UITextAutocorrectionTypeNo;
        self.emailField.keyboardType = UIKeyboardTypeEmailAddress;
        self.emailField.returnKeyType = UIReturnKeyNext;
        self.emailField.clearButtonMode = UITextFieldViewModeWhileEditing;
        self.emailField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
        self.emailField.autocapitalizationType = UITextAutocapitalizationTypeNone;
        self.emailField.delegate = self;
        self.emailField.tag = CELL_EMAIL_FIELD_TAG;
        self.emailField.text = self.email;
        self.emailField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"Email"
                                                                      attributes:@{NSForegroundColorAttributeName:[UIColor lightGrayColor]}];
        
        self.usernameField = [[UITextField alloc] init];
        self.usernameField.textColor = [UIColor whiteColor];
        self.usernameField.autocorrectionType = UITextAutocorrectionTypeNo;
        self.usernameField.keyboardType = UIKeyboardTypeEmailAddress;
        self.usernameField.returnKeyType = UIReturnKeyDone;
        self.usernameField.clearButtonMode = UITextFieldViewModeWhileEditing;
        self.usernameField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
        self.usernameField.autocapitalizationType = UITextAutocapitalizationTypeNone;
        self.usernameField.delegate = self;
        self.usernameField.tag = CELL_USERNAME_FIELD_TAG;
        self.usernameField.text = self.username;
        self.usernameField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"Username"
                                                                      attributes:@{NSForegroundColorAttributeName:[UIColor lightGrayColor]}];
        self.usernameField.returnKeyType = UIReturnKeyDone;
    }
    return self;
}


# pragma mark TableView Delegate Methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 2;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 40.0;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UILabel *label = [[UILabel alloc] init];
    label.frame = CGRectMake(0.0, 10.0, tableView.frame.size.width, 20.0);
    label.font = [UIFont boldSystemFontOfSize:17.0];
    label.textColor = [UIColor whiteColor];
    label.text = @"Please enter your contact info";
    UIView *headerView = [[UIView alloc] init];
    [headerView addSubview:label];
    return headerView;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *i = @"ContactInfoCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:i];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:i];
        [cell setBackgroundColor:[UIColor clearColor]];
        
        CALayer *topBorder = [CALayer layer];
        topBorder.frame = CGRectMake(0.0, 0.0, cell.frame.size.width + 80.0, 0.5f);
        topBorder.backgroundColor = [[UIColor whiteColor] CGColor];
        topBorder.opacity = 0.2;
        [cell.contentView.layer addSublayer:topBorder];
        
        if ( indexPath.row == 0 ) {
            [self.emailField setFrame:cell.frame];
            self.emailField.text = self.email;
            [cell.contentView addSubview:self.emailField];
            [self.emailField becomeFirstResponder];
        } else {
            [self.usernameField setFrame:cell.frame];
            self.usernameField.text = self.username;
            [cell.contentView addSubview:self.usernameField];
        }
    } else {
        self.emailField = (UITextField *)[cell.contentView viewWithTag:CELL_EMAIL_FIELD_TAG];
        self.usernameField = (UITextField *)[cell.contentView viewWithTag:CELL_USERNAME_FIELD_TAG];
    }
    
    return cell;
}


#pragma mark TextField Delegates

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    self.callback(@{@"email": self.emailField.text,
                    @"username": self.usernameField.text});
    [textField resignFirstResponder];
    return YES;
}

@end
