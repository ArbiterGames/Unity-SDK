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


@interface ArbiterWalletDashboardView : ArbiterPanelView <ArbiterWalletDetailViewDelegate>

- (void)segmentControlClicked:(UISegmentedControl *)segment;

@end
