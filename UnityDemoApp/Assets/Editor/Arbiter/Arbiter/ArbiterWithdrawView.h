//
//  ArbiterWithdrawView.h
//  Unity-iPhone
//
//  Created by Andy Zinsser on 6/27/14.
//
//

#import <UIKit/UIKit.h>
#import "STPView.h"

@interface ArbiterWithdrawView : UIView <STPViewDelegate, UITextFieldDelegate>

@property (strong, nonatomic) IBOutlet UIButton *submitButton;
@property (strong, nonatomic) IBOutlet UITextField *nameField;
@property (assign) STPView *stripeView;

- (id)initWithFrame:(CGRect)frame andCallback:(void(^)(void))handler forUser:(NSDictionary *)userDict andWallet:(NSDictionary *)walletDict;
- (void)cancelButtonClicked: (id)sender;
- (void)selectButtonClicked: (id)sender;

@end
