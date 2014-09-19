//
//  ArbiterBillingInfoTableViewDelegate.h
//  Unity-iPhone
//
//  Created by Andy Zinsser on 9/4/14.
//
//

#import <UIKit/UIKit.h>
#import "PTKView.h"


@interface ArbiterBillingInfoTableViewDelegate : UIView <UITableViewDataSource, UITableViewDelegate>

- (id)initWithStripeView:(STPView *)stripeView;

@end
