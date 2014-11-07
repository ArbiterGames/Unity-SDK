//
//  ARBWalletWithdrawView.h
//  Unity-iPhone
//
//  Created by Andy Zinsser on 9/4/14.
//
//

#import <UIKit/UIKit.h>
#import "Arbiter.h"
#import "PTKView.h"

@protocol WalletWithdrawViewDelegate

- (void)handleBackButton;
- (void)handleNextButton;

@end


@interface ARBWalletWithdrawView : UIView <PTKViewDelegate, ARBWalletObserver>
{
    id <WalletWithdrawViewDelegate> parentDelegate;
    id <WalletWithdrawViewDelegate> childDelegate;
}

@property (strong) id parentDelegate;
@property (strong) id childDelegate;
@property (strong) Arbiter *arbiter;
@property (strong) PTKView *pkView;
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
