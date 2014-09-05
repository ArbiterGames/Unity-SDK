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


@interface ArbiterWalletDetailView : UIView <UITableViewDataSource, UITableViewDelegate>
{
    id <WalletDetailViewDelegate> delegate;
}

@property (nonatomic, assign) id delegate;

- (id)initWithFrame:(CGRect)frame andArbiterInstance:(Arbiter *)arbiterInstance;
- (void)backButtonClicked:(id)sender;

@end