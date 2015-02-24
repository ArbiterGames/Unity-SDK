//
//  ARBWalletDashboardWebView.h
//  Unity-iPhone
//
//  Created by Andy Zinsser on 12/16/14.
//
//

#import <UIKit/UIKit.h>
#import "ARBPanelView.h"

@interface ARBWalletDashboardWebView : ARBPanelView <UIWebViewDelegate>

@property (strong) NSString *tab;
@property (strong) void (^callback)(void);
@property (strong) UIActivityIndicatorView *spinnerView;


- (id)initOnTab:(NSString *)tab withArbiterInstance:(Arbiter *)arbiterInstance;
- (void)backButtonClicked;

@end
