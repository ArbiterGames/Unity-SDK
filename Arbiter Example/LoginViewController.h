//
//  LoginViewController.h
//  Arbiter Demo
//
//  Created by Andy Zinsser on 12/4/13.
//  Copyright (c) 2013 Arbiter. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LoginViewController : UIViewController <UITextFieldDelegate>
{
    void (^_completionHandler)(NSString *param);
}

@property (strong, nonatomic) IBOutlet UITextField *usernameField;
@property (strong, nonatomic) IBOutlet UITextField *passwordField;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *doneButton;

- (id)initWithCallback:(void(^)(NSString *))handler;
- (IBAction)done:(id)sender;
- (IBAction)cancel:(id)sender;

@end
