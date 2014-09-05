//
//  ArbiterWalletDetailView.h
//  Unity-iPhone
//
//  Created by Andy Zinsser on 9/4/14.
//
//

#import <UIKit/UIKit.h>
#import "Arbiter.h"


@protocol ArbiterWalletDetailViewDelegate

- (void)closePanel;

@end


@interface ArbiterWalletDetailView : UIView <UITableViewDataSource, UITableViewDelegate>
{
    id <ArbiterWalletDetailViewDelegate> delegate;
}

@property (nonatomic, assign) id delegate;

- (id)initWithFrame:(CGRect)frame andArbiterInstance:(Arbiter *)arbiterInstance;
- (void)backButtonClicked:(id)sender;

@end