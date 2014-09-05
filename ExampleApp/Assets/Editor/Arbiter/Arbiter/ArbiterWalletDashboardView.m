//
//  ArbiterWalletDashboardView.m
//  Unity-iPhone
//
//  Created by Andy Zinsser on 9/3/14.
//
//

#import "ArbiterWalletDashboardView.h"
#import "Arbiter.h"
#import "ArbiterWalletDetailView.h"
#import "ArbiterWalletDepositView.h"
#import "ArbiterWalletWithdrawView.h"

@implementation ArbiterWalletDashboardView
{
    UIView *_activeView;
    CGRect _marginizedFrame;
}

- (void)renderLayout
{
    [super renderLayout];
    
    float segmentedControlHeight = 40.0;
    float titleYPos = 10.0;
    float titleHeight = 40.0;
    float segmentedControlYPosFromBottom = 30.0;
    
    _marginizedFrame = CGRectMake(0.0, 0.0,
                                  self.bounds.size.width, self.bounds.size.height - titleHeight - titleYPos - segmentedControlHeight - segmentedControlYPosFromBottom);
    if ( self.bounds.size.width > 400.0 ) {
        _marginizedFrame.size.width = 400.0;
        _marginizedFrame.origin.x = (self.bounds.size.width - _marginizedFrame.size.width) / 2;
    }
    
    UILabel *title = [[UILabel alloc] initWithFrame:CGRectMake(50.0, titleYPos, self.frame.size.width - 100.0, titleHeight)];
    [title setText:@"Wallet"];
    [title setFont:[UIFont fontWithName:@"HelveticaNeue-UltraLight" size:38.0]];
    [title setTextColor:[UIColor whiteColor]];
    [title setTextAlignment:NSTextAlignmentCenter];
    [self addSubview:title];
    
    CALayer *topBorder = [CALayer layer];
    topBorder.frame = CGRectMake(0.0, titleYPos + titleHeight + 10.0, self.frame.size.width, 0.5f);
    topBorder.backgroundColor = [[UIColor grayColor] CGColor];
    [self.layer addSublayer:topBorder];
    
    ArbiterWalletDetailView *detailView = [[ArbiterWalletDetailView alloc] initWithFrame:_marginizedFrame andArbiterInstance:self.arbiter];
    [detailView setDelegate:self];
    [self navigateToView:detailView];
    
    UISegmentedControl *segmentedControl = [[UISegmentedControl alloc] initWithItems:[NSArray arrayWithObjects: @"Overview", @"Deposit", @"Withdraw", nil]];
    [segmentedControl setFrame:CGRectMake(_marginizedFrame.origin.x, self.frame.size.height - segmentedControlHeight - segmentedControlYPosFromBottom,
                                          _marginizedFrame.size.width, segmentedControlHeight)];
    [segmentedControl addTarget:self action:@selector(segmentControlClicked:) forControlEvents: UIControlEventValueChanged];
    [segmentedControl setTintColor:[UIColor whiteColor]];
    segmentedControl.selectedSegmentIndex = 0;
    [self addSubview:segmentedControl];
}

- (void)navigateToView:(UIView *)subview
{
    if ( _activeView ) {
        [_activeView removeFromSuperview];
    }
    _activeView = subview;
    [self addSubview:_activeView];
}


# pragma mark click handlers

- (void)segmentControlClicked:(UISegmentedControl *)segment
{
    if ( segment.selectedSegmentIndex == 0 ) {
        ArbiterWalletDetailView *view = [[ArbiterWalletDetailView alloc] initWithFrame:_marginizedFrame
                                                                    andArbiterInstance:self.arbiter];
        [view setDelegate:self];
        [self navigateToView:view];
    } else if ( segment.selectedSegmentIndex == 1 ) {
        ArbiterWalletDepositView *view = [[ArbiterWalletDepositView alloc] initWithFrame:_marginizedFrame
                                                                      andArbiterInstance:self.arbiter];
        [view setDelegate:self];
        [self navigateToView:view];
    } else {
        ArbiterWalletWithdrawView *view = [[ArbiterWalletWithdrawView alloc] initWithFrame:_marginizedFrame
                                                                        andArbiterInstance:self.arbiter];
        [self navigateToView:view];
    }
}


# pragma mark Arbiter Dashboard Subvies Delegate Methods

- (void)handleBackButton
{
    [self animateOut];
}

@end
