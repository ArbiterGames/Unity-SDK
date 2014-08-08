//
//  ArbiterPaymentView.h
//  
//
//  Created by Andy Zinsser on 6/24/14.
//
//

#import <UIKit/UIKit.h>
#import "STPView.h"
#import "ArbiterAlertView.h"

@interface ArbiterPaymentView : ArbiterAlertView <STPViewDelegate, UIPickerViewDataSource, UIPickerViewDelegate, UITextFieldDelegate>

@property (strong, nonatomic) IBOutlet UIButton *purchaseButton;
@property (strong, nonatomic) IBOutlet UITextField *emailField;
@property (assign) STPView *stripeView;


- (void)selectBundleButtonClicked: (id)sender;
- (void)saveEmailButtonClicked: (id)sender;
- (void)purchaseButtonClicked: (id)sender;

@end
