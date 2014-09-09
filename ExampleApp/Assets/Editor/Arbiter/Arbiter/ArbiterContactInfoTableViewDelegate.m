//
//  ArbiterContactInfoTableViewDelegate.m
//  Unity-iPhone
//
//  Created by Andy Zinsser on 9/4/14.
//
//

#import "ArbiterContactInfoTableViewDelegate.h"

#define CELL_FIELD_TAG 1

@implementation ArbiterContactInfoTableViewDelegate

- (id)initWithCallback:(void(^)(NSString *))callbackBlock
{
    self = [super init];
    if ( self ) {
        self.callback = callbackBlock;
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
    return 1;
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
    UITextField *emailField;
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:i];
        [cell setBackgroundColor:[UIColor clearColor]];
        emailField = [[UITextField alloc] initWithFrame:cell.frame];
        if ( self.email != nil ) {
            emailField.text = self.email;
        }
        emailField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"Email"
                                                                           attributes:@{NSForegroundColorAttributeName:[UIColor lightGrayColor]}];
        emailField.textColor = [UIColor whiteColor];
        emailField.autocorrectionType = UITextAutocorrectionTypeNo;
        emailField.keyboardType = UIKeyboardTypeEmailAddress;
        emailField.returnKeyType = UIReturnKeyDone;
        emailField.clearButtonMode = UITextFieldViewModeWhileEditing;
        emailField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
        emailField.autocapitalizationType = UITextAutocapitalizationTypeNone;
        emailField.delegate = self;
        emailField.tag = CELL_FIELD_TAG;
        [cell.contentView addSubview:emailField];
        [emailField becomeFirstResponder];
    } else {
        emailField = (UITextField *)[cell.contentView viewWithTag:CELL_FIELD_TAG];
    }
    
    CALayer *topBorder = [CALayer layer];
    topBorder.frame = CGRectMake(0.0, 0.0, cell.frame.size.width + 80.0, 0.5f);
    topBorder.backgroundColor = [[UIColor whiteColor] CGColor];
    topBorder.opacity = 0.2;
    [cell.contentView.layer addSublayer:topBorder];
    
    return cell;
}


#pragma mark TextField Delegates

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    self.callback(textField.text);
    [textField resignFirstResponder];
    return YES;
}

@end
