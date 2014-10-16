//
//  ArbiterWalletDetailView.h
//  Unity-iPhone
//
//  Created by Andy Zinsser on 9/4/14.
//
//

#import <UIKit/UIKit.h>
#import "Arbiter.h"


@protocol WalletDetailViewDelegate

- (void)handleBackButton;

@end


@interface ArbiterWalletDetailView : UIView <UITableViewDataSource, UITableViewDelegate, ArbiterWalletObserver>
{
    id <WalletDetailViewDelegate> delegate;
}

@property (strong) Arbiter *arbiter;
@property (strong) id delegate;
@property int activeUI;
@property (strong) UILabel* activeWalletField;

- (id)initWithFrame:(CGRect)frame andArbiterInstance:(Arbiter *)arbiterInstance;
- (void)backButtonClicked:(id)sender;

@end