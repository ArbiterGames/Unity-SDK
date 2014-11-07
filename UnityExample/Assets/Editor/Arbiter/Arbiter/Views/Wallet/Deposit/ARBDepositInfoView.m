//
//  ARBDepositInfoView.m
//  Unity-iPhone
//
//  Created by Andy Zinsser on 9/4/14.
//
//

#import "ARBTracking.h"
#import "ARBDepositInfoView.h"

#define CELL_EMAIL_FIELD_TAG 1
#define CELL_USERNAME_FIELD_TAG 2

@implementation ARBDepositInfoView


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
    return 4;
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
    if ( self.tableView == nil ) {
        self.tableView = tableView;
    }
    static NSString *i = @"ContactInfoCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:i];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:i];
        [cell setBackgroundColor:[UIColor clearColor]];
        
        CALayer *topBorder = [CALayer layer];
        topBorder.frame = CGRectMake(0.0, 0.0, cell.frame.size.width + 80.0, 0.5f);
        topBorder.backgroundColor = [[UIColor whiteColor] CGColor];
        topBorder.opacity = 0.2;
        
        if ( indexPath.row == 0 ) {
            [self.emailField setFrame:cell.frame];
            self.emailField.text = self.email;
            [cell.contentView addSubview:self.emailField];
            [self.emailField becomeFirstResponder];
            [cell.contentView.layer addSublayer:topBorder];
        } else if ( indexPath.row == 1 ) {
            [self.usernameField setFrame:cell.frame];
            self.usernameField.text = self.username;
            [cell.contentView addSubview:self.usernameField];
            [cell.contentView.layer addSublayer:topBorder];
        }
    }
    
    return cell;
}


#pragma mark WalletDepositView delegate methods

- (void)handleBackButton
{
    // No-op, unless we want to have this start toggling backwards through the fields.
    // Not doing that now to simplify the parentView navigation logic
}

- (void)handleNextButton
{
    if ( [self.emailField isFirstResponder] ) {
        [self.usernameField becomeFirstResponder];
    } else {
        [[ARBTracking arbiterInstance] track:@"Submitted Deposit Info" properties:@{@"email": self.emailField.text,
                                                                                @"username": self.usernameField.text}];
        self.callback(@{@"email": self.emailField.text,
                        @"username": self.usernameField.text});
    }
}


#pragma mark TextField Delegate methods

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    UITableViewCell *cell = [self getCellFromTextField:textField];
    [self.tableView scrollToRowAtIndexPath:[self.tableView indexPathForCell:cell] atScrollPosition:UITableViewScrollPositionTop animated:YES];
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [self handleNextButton];
    return YES;
}


// iOS 7 renders the cells 1 class deeper than iOS 8.
- (UITableViewCell*)getCellFromTextField:(UITextField *)textField
{
    UITableViewCell *cell = (UITableViewCell *)textField.superview.superview;
    if ( [cell isKindOfClass:[UITableViewCell class]] == NO ) {
        cell = (UITableViewCell *)textField.superview.superview.superview;
    }
    return cell;

}


@end
