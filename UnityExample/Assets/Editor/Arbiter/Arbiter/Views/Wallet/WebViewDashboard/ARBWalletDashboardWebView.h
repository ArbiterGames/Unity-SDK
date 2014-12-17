//
//  ARBWalletDashboardWebView.h
//  Unity-iPhone
//
//  Created by Andy Zinsser on 12/16/14.
//
//

#import <UIKit/UIKit.h>
#import "ARBPanelView.h"

@interface ARBWalletDashboardWebView : ARBPanelView

@property (strong) void (^callback)(void);

- (void)backButtonClicked:(id)sender;

@end
