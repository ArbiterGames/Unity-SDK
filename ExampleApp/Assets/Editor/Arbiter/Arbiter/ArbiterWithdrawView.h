//
//  ArbiterWithdrawView.h
//  Unity-iPhone
//
//  Created by Andy Zinsser on 6/27/14.
//
//

#import <UIKit/UIKit.h>
#import "STPView.h"
#import "ArbiterAlertView.h"

@interface ArbiterWithdrawView : ArbiterAlertView <STPViewDelegate, UITextFieldDelegate>

@property (strong, nonatomic) IBOutlet UIButton *nextButton;
@property (strong, nonatomic) IBOutlet UITextField *nameField;
@property (strong, nonatomic) IBOutlet UITextField *emailField;
@property (assign) STPView *stripeView;

- (void)nextButtonClicked: (id)sender;

@end
