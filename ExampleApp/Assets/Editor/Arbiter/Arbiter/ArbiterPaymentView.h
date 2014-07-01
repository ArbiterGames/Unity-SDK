//
//  ArbiterPaymentView.h
//  
//
//  Created by Andy Zinsser on 6/24/14.
//
//

#import <UIKit/UIKit.h>
#import "STPView.h"

@interface ArbiterPaymentView : UIView <STPViewDelegate, UIPickerViewDataSource, UIPickerViewDelegate>

@property (strong, nonatomic) IBOutlet UIButton *purchaseButton;
@property (assign) STPView *stripeView;

- (id)initWithFrame:(CGRect)frame andCallback:(void(^)(void))callback forUser:(NSDictionary *)userDict;
- (void)cancelButtonClicked: (id)sender;
- (void)selectButtonClicked: (id)sender;
- (void)purchaseButtonClicked: (id)sender;

@end
