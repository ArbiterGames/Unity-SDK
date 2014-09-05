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
{
    void (^_callback)(NSString *email);
}

- (id)initWithCallback:(void(^)(NSString *))callback
{
    self = [super init];
    if ( self ) {
        _callback = callback;
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

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return @"Please enter your contact info";
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *i = @"ContactInfoCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:i];
    UITextField *emailField;
    CALayer *topBorder = [CALayer layer];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:i];
        [cell setBackgroundColor:[UIColor clearColor]];
        emailField = [[UITextField alloc] initWithFrame:cell.frame];
        emailField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"Email"
                                                                           attributes:@{NSForegroundColorAttributeName:[UIColor lightGrayColor]}];
        [emailField setTextColor:[UIColor whiteColor]];
        [emailField setAutocorrectionType:UITextAutocorrectionTypeNo];
        [emailField setKeyboardType:UIKeyboardTypeEmailAddress];
        [emailField setReturnKeyType:UIReturnKeyDone];
        [emailField setClearButtonMode:UITextFieldViewModeWhileEditing];
        [emailField setContentVerticalAlignment:UIControlContentVerticalAlignmentCenter];
        [emailField setAutocapitalizationType:UITextAutocapitalizationTypeNone];
        [emailField setDelegate:self];
        [emailField setTag:CELL_FIELD_TAG];
        [cell.contentView addSubview:emailField];
        [emailField becomeFirstResponder];
    } else {
        emailField = (UITextField *)[cell.contentView viewWithTag:CELL_FIELD_TAG];
    }
    
    topBorder.frame = CGRectMake(0.0, 0.0, cell.frame.size.width + 80.0, 0.5f);
    topBorder.backgroundColor = [[UIColor whiteColor] CGColor];
    [cell.contentView.layer addSublayer:topBorder];
    
    return cell;
}


#pragma mark TextField Delegates

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    _callback(textField.text);
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

@end
