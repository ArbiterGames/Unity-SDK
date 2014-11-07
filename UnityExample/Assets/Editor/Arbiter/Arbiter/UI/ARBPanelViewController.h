//
//  ARBPanelViewController.h
//  Unity-iPhone
//
//  Created by Andy Zinsser on 9/3/14.
//
//

#import <UIKit/UIKit.h>
#import "ARBWalletDetailView.h"


@interface ARBPanelViewController : UIViewController

@property (assign) NSUInteger *orientations;

- (id)initWithSupportedOrientations:(NSUInteger)orientations;

@end
