//
//  ArbiterWalletDepsitView.h
//  Unity-iPhone
//
//  Created by Andy Zinsser on 9/4/14.
//
//

#import <UIKit/UIKit.h>
#import "Arbiter.h"
#import "STPView.h"


@protocol WalletDepositViewDelegate

- (void)handleBackButton;

@end

@interface ArbiterWalletDepositView : UIView <STPViewDelegate, ArbiterWalletObserver>
{
    id <WalletDepositViewDelegate> delegate;
}

@property (strong) id delegate;
@property (strong) Arbiter *arbiter;
@property (strong) STPView *stripeView;
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
