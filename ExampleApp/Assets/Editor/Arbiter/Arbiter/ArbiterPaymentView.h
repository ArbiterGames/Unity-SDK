//
//  ArbiterPaymentView.h
//  
//
//  Created by Andy Zinsser on 6/24/14.
//
//

#import <UIKit/UIKit.h>
#import "STPView.h"
#import "Arbiter.h"

@interface ArbiterPaymentView : UIView <STPViewDelegate, UIPickerViewDataSource, UIPickerViewDelegate, UITextFieldDelegate>

@property (strong, nonatomic) IBOutlet UIButton *purchaseButton;
@property (strong, nonatomic) IBOutlet UITextField *emailField;
@property (assign) STPView *stripeView;

- (id)initWithFrame:(CGRect)frame andCallback:(void(^)(void))callback arbiterInstance:(Arbiter *)arbiterInstance;
- (void)cancelButtonClicked: (id)sender;
- (void)selectBundleButtonClicked: (id)sender;
- (void)saveEmailButtonClicked: (id)sender;
- (void)purchaseButtonClicked: (id)sender;

@end
