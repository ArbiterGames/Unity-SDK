//
//  ArbiterWalletDetailView.h
//  Unity-iPhone
//
//  Created by Andy Zinsser on 9/4/14.
//
//

#import <UIKit/UIKit.h>
#import "Arbiter.h"


@interface ArbiterWalletDetailView : UIView <UITableViewDataSource, UITableViewDelegate>

- (id)initWithFrame:(CGRect)frame andArbiterInstance:(Arbiter *)arbiterInstance;

@end