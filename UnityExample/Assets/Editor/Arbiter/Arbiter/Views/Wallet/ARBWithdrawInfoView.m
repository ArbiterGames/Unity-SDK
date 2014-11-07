//
//  ARBWithdrawInfoView.m
//  Unity-iPhone
//
//  Created by Andy Zinsser on 9/7/14.
//
//

#import "ARBWithdrawInfoView.h"
#import "ARBTracking.h"

#define EMAIL_FIELD_TAG 1
#define NAME_FIELD_TAG 2


@implementation ARBWithdrawInfoView

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
        self.emailField.tag = EMAIL_FIELD_TAG;
        self.emailField.text = self.email;
        self.emailField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"Email"
                                                                                attributes:@{NSForegroundColorAttributeName:[UIColor lightGrayColor]}];
        self.nameField = [[UITextField alloc] init];
        self.nameField.textColor = [UIColor whiteColor];
        self.nameField.autocorrectionType = UITextAutocorrectionTypeNo;
        self.nameField.keyboardType = UIKeyboardTypeEmailAddress;
        self.nameField.returnKeyType = UIReturnKeyDone;
        self.nameField.returnKeyType = UIReturnKeyDone;
        self.nameField.clearButtonMode = UITextFieldViewModeWhileEditing;
        self.nameField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
        self.nameField.autocapitalizationType = UITextAutocapitalizationTypeNone;
        self.nameField.delegate = self;
        self.nameField.tag = NAME_FIELD_TAG;
        self.nameField.text = self.fullName;
        self.nameField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"Name"
                                                                               attributes:@{NSForegroundColorAttributeName:[UIColor lightGrayColor]}];
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
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
    cell.backgroundColor = [UIColor clearColor];
    CALayer *topBorder = [CALayer layer];
    topBorder.frame = CGRectMake(0.0, 0.0, cell.frame.size.width + 80.0, 0.5f);
    topBorder.backgroundColor = [[UIColor whiteColor] CGColor];
    topBorder.opacity = 0.2;
    
    if ( self.tableView == nil ) {
        self.tableView = tableView;
    }
    
    if ( indexPath.row == 0 ) {
        self.emailField.text = self.email;
        [self.emailField setFrame:cell.frame];
        [cell.contentView.layer addSublayer:topBorder];
        [cell.contentView addSubview:self.emailField];
        [self.emailField becomeFirstResponder];
    } else if ( indexPath.row == 1 ) {
        self.nameField.text = self.fullName;
        [self.nameField setFrame:cell.frame];
        [cell.contentView.layer addSublayer:topBorder];
        [cell.contentView addSubview:self.nameField];
    }
    
    return cell;
}


#pragma mark TextField Delegates

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


#pragma mark WalletWithdrawView delegate methods

- (void)handleBackButton
{
    // No-op, unless we want to have this start toggling backwards through the fields.
    // Not doing that now to simplify to parentView navigation logic
}

- (void)handleNextButton
{
    if ( [self.emailField isFirstResponder] ) {
        [self.nameField becomeFirstResponder];
    } else {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@""
                                                        message:@""
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        if ( [self.emailField.text isEqualToString:@""] ) {
            alert.title = @"We need your email";
            alert.message = @"Please enter your email before continuing.";
            [alert show];
        } else if ( [self.nameField.text isEqualToString:@""] ) {
            alert.title = @"We need your name";
            alert.message = @"Please enter your full name as it appears on your debit card before continuing.";
            [alert show];
        } else {
            [[ARBTracking arbiterInstance] track:@"Submitted Withdraw Info" properties:@{@"email": self.emailField.text,
                                                                                     @"fullName": self.nameField.text}];
            self.callback(@{@"email": self.emailField.text, @"fullName": self.nameField.text});
        }
    }
}


@end
