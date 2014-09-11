//
//  ArbiterWalletDashboardView.h
//  Unity-iPhone
//
//  Created by Andy Zinsser on 9/3/14.
//
//

#import <UIKit/UIKit.h>
#import "ArbiterPanelView.h"
#import "ArbiterWalletDetailView.h"
#import "ArbiterWalletDepositView.h"


@interface ArbiterWalletDashboardView : ArbiterPanelView <WalletDetailViewDelegate, WalletDepositViewDelegate>

@property (strong) UIView *activeView;
@property CGRect marginizedFrame;
@property (strong) void (^callback)(void);

- (void)segmentControlClicked:(UISegmentedControl *)segment;

@end
