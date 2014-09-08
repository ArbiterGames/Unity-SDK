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

- (void)renderLayout
{
    
//    if ( self.bounds.size.width > self.maxWidth ) {
//        self.marginizedFrame = CGRectMake((self.bounds.size.width - self.maxWidth) / 2, 0.0,
//                                          self.maxWidth, self.bounds.size.height - self.titleHeight - self.titleYPos - segmentedControlHeight - segmentedControlYPosFromBottom);
//    } else {
//        self.marginizedFrame = CGRectMake(0.0, 0.0, self.bounds.size.width, self.bounds.size.height - self.titleHeight - self.titleYPos - segmentedControlHeight - segmentedControlYPosFromBottom);
//    }
    
    UILabel *title = [[UILabel alloc] initWithFrame:CGRectMake(50.0, self.titleYPos, self.frame.size.width - 100.0, self.titleHeight)];
    title.text = @"Wallet";
    title.font = [UIFont fontWithName:@"HelveticaNeue-UltraLight" size:38.0];
    title.textColor = [UIColor whiteColor];
    title.textAlignment = NSTextAlignmentCenter;
    [self addSubview:title];
    
    CALayer *topBorder = [CALayer layer];
    topBorder.frame = CGRectMake(0.0, self.titleYPos + self.titleHeight + 10.0,
                                 self.frame.size.width, 0.5f);
    topBorder.backgroundColor = [[UIColor whiteColor] CGColor];
    topBorder.opacity = 0.2;
    [self.layer addSublayer:topBorder];
    
    ArbiterWalletDetailView *detailView = [[ArbiterWalletDetailView alloc] initWithFrame:CGRectMake(0.0, 0.0, self.frame.size.width, 220.0)
                                                                      andArbiterInstance:self.arbiter];
    detailView.delegate = self;
    [self navigateToView:detailView];
    
    UISegmentedControl *segmentedControl = [[UISegmentedControl alloc] initWithItems:[NSArray arrayWithObjects: @"Overview", @"Deposit", @"Withdraw", nil]];
    [segmentedControl setFrame:CGRectMake(0.0, detailView.frame.size.height + 40.0, self.frame.size.width, 40.0)];
    [segmentedControl addTarget:self action:@selector(segmentControlClicked:) forControlEvents: UIControlEventValueChanged];
    [segmentedControl setTintColor:[UIColor whiteColor]];
    segmentedControl.selectedSegmentIndex = 0;
    [self addSubview:segmentedControl];
    
    [super renderLayout];
}

- (void)navigateToView:(UIView *)subview
{
    if ( self.activeView ) {
        [self.activeView removeFromSuperview];
    }
    self.activeView = subview;
    [self addSubview:self.activeView];
}


# pragma mark click handlers

- (void)segmentControlClicked:(UISegmentedControl *)segment
{
    if ( segment.selectedSegmentIndex == 0 ) {
        ArbiterWalletDetailView *view = [[ArbiterWalletDetailView alloc] initWithFrame:CGRectMake(0.0, 0.0, self.frame.size.width, 220.0)
                                                                    andArbiterInstance:self.arbiter];
        view.delegate = self;
        [self navigateToView:view];
    } else if ( segment.selectedSegmentIndex == 1 ) {
        ArbiterWalletDepositView *view = [[ArbiterWalletDepositView alloc] initWithFrame:CGRectMake(0.0, 0.0, self.frame.size.width, 220.0)
                                                                      andArbiterInstance:self.arbiter];
        view.delegate = self;
        [self navigateToView:view];
    } else {
        ArbiterWalletWithdrawView *view = [[ArbiterWalletWithdrawView alloc] initWithFrame:CGRectMake(0.0, 0.0, self.frame.size.width, 220.0)
                                                                        andArbiterInstance:self.arbiter];
        view.delegate = self;
        [self navigateToView:view];
    }
}


# pragma mark Arbiter Dashboard Subviews Delegate Methods

- (void)handleBackButton
{
    [self animateOut];
}

@end
