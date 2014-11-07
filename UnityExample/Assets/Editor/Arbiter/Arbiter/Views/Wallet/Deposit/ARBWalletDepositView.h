//
//  ArbiterWalletDepsitView.h
//  Unity-iPhone
//
//  Created by Andy Zinsser on 9/4/14.
//
//

#import <UIKit/UIKit.h>
#import "Arbiter.h"


@protocol WalletDepositViewDelegate

- (void)handleBackButton;
- (void)handleNextButton;

@end

@interface ARBWalletDepositView : UIView <ARBWalletObserver>
{
    id <WalletDepositViewDelegate> parentDelegate;
    id <WalletDepositViewDelegate> childDelegate;
}

@property (strong) id parentDelegate;
@property (strong) id childDelegate;
@property (strong) Arbiter *arbiter;
@property (strong) NSDictionary *selectedBundle;
@property (strong) NSString *email;
@property (strong) NSString *username;
@property int activeViewIndex;
@property BOOL purchaseCompleted;

@property (strong) IBOutlet UIButton *backButton;
@property (strong) IBOutlet UIButton *nextButton;

- (id)initWithFrame:(CGRect)frame andArbiterInstance:(Arbiter *)arbiterInstance;
- (void)nextButtonClicked:(id)sender;
- (void)backButtonClicked:(id)sender;

@end
