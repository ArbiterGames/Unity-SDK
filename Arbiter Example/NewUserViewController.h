//
//  NewUserViewController.h
//  Arbiter Demo
//
//  Created by Andy Zinsser on 12/4/13.
//  Copyright (c) 2013 Arbiter. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NewUserViewController : UIViewController <UITextFieldDelegate>
{
    void (^_completionHandler)(NSString *param);
}

@property (nonatomic, strong) IBOutlet UIBarButtonItem *doneButton;
@property (nonatomic, strong) IBOutlet UITextField *usernameField;
@property (nonatomic, strong) IBOutlet UITextField *passwordField;
@property (nonatomic, strong) IBOutlet UITextField *passwordAgainField;

- (id)initWithCallback:(void(^)(NSString *))handler;
- (IBAction)cancel:(id)sender;
- (IBAction)done:(id)sender;

@end

