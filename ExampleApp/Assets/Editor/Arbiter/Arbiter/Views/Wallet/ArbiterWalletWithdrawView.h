//
//  ArbiterWalletWithdrawView.h
//  Unity-iPhone
//
//  Created by Andy Zinsser on 9/4/14.
//
//

#import <UIKit/UIKit.h>
#import "Arbiter.h"
#import "STPView.h"

@protocol WalletWithdrawViewDelegate

- (void)handleBackButton;

@end


@interface ArbiterWalletWithdrawView : UIView <STPViewDelegate, ArbiterWalletObserver>
{
    id <WalletWithdrawViewDelegate> delegate;
}

@property (strong) id delegate;
@property (strong) Arbiter *arbiter;
@property (strong) STPView *stripeView;
@property (strong) NSString *email;
@property (strong) NSString *fullName;
@property float withdrawAmount;
@property int activeViewIndex;
@property BOOL withdrawComplete;

@property (strong) IBOutlet UILabel *withdrawSelectionLabel;
@property (strong) IBOutlet UILabel *withdrawValueLabel;
@property (strong) IBOutlet UIButton *backButton;
@property (strong) IBOutlet UIButton *nextButton;

- (id)initWithFrame:(CGRect)frame andArbiterInstance:(Arbiter *)arbiterInstance;
- (void)nextButtonClicked:(id)sender;
- (void)backButtonClicked:(id)sender;

@end
