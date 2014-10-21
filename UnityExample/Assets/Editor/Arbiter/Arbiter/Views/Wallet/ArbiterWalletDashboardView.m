//
//  ArbiterWalletDashboardView.m
//  Unity-iPhone
//
//  Created by Andy Zinsser on 9/3/14.
//
//

#import "Mixpanel.h"
#import "ArbiterWalletDashboardView.h"
#import "Arbiter.h"
#import "ArbiterWalletDetailView.h"
#import "ArbiterWalletDepositView.h"
#import "ArbiterWalletWithdrawView.h"

@implementation ArbiterWalletDashboardView

- (void)renderLayout
{
    float segmentedControlHeight = 40.0;
    
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
    
    ArbiterWalletDetailView *detailView = [[ArbiterWalletDetailView alloc] initWithFrame:CGRectMake(0.0, 0.0, self.frame.size.width, self.maxHeight - segmentedControlHeight - self.titleHeight - self.titleYPos)
                                                                      andArbiterInstance:self.arbiter];
    detailView.delegate = self;
    self.activeWalletObserver = detailView;
    [self navigateToView:detailView];
    
    UISegmentedControl *segmentedControl = [[UISegmentedControl alloc] initWithItems:[NSArray arrayWithObjects: @"Overview", @"Deposit", @"Withdraw", nil]];
    [segmentedControl setFrame:CGRectMake(0.0, detailView.frame.origin.y + detailView.frame.size.height + 10, self.frame.size.width, segmentedControlHeight)];
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

- (void)onWalletUpdated:(NSDictionary *)wallet
{
    [self.activeWalletObserver onWalletUpdated:wallet];
}


# pragma mark click handlers

- (void)segmentControlClicked:(UISegmentedControl *)segment
{
    if ( segment.selectedSegmentIndex == 0 ) {
        ArbiterWalletDetailView *view = [[ArbiterWalletDetailView alloc] initWithFrame:CGRectMake(0.0, 0.0, self.frame.size.width, 220.0)
                                                                    andArbiterInstance:self.arbiter];
        view.delegate = self;
        self.activeWalletObserver = view;
        [self navigateToView:view];
    } else if ( segment.selectedSegmentIndex == 1 ) {
        [[Mixpanel sharedInstance] track:@"Clicked Deposit"];
        ArbiterWalletDepositView *view = [[ArbiterWalletDepositView alloc] initWithFrame:CGRectMake(0.0, 0.0, self.frame.size.width, 220.0)
                                                                      andArbiterInstance:self.arbiter];
        view.parentDelegate = self;
        self.activeWalletObserver = view;
        [self navigateToView:view];
    } else {
        [[Mixpanel sharedInstance] track:@"Clicked Withdraw"];
        ArbiterWalletWithdrawView *view = [[ArbiterWalletWithdrawView alloc] initWithFrame:CGRectMake(0.0, 0.0, self.frame.size.width, 220.0)
                                                                        andArbiterInstance:self.arbiter];
        view.parentDelegate = self;
        self.activeWalletObserver = view;
        [self navigateToView:view];
    }
}


# pragma mark Arbiter Dashboard Subviews Delegate Methods

- (void)handleBackButton
{
    if ( self.callback ) {
        [self callback];
    }
    [self.parentWindow hide];
}

- (void)handleNextButton
{
    if ( self.callback ) {
        [self callback];
    }
    [self.parentWindow hide];
}

@end