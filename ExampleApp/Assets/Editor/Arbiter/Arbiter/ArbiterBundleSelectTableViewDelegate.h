//
//  ArbiterBundleSelectView.h
//  Unity-iPhone
//
//  Created by Andy Zinsser on 9/4/14.
//
//

#import <UIKit/UIKit.h>

@interface ArbiterBundleSelectView : UIView <UITableViewDataSource, UITableViewDelegate>

- (id)initWithBundles:(NSMutableArray *)availableBundles andSelectionCallback:(void(^)(NSDictionary *))selectionCallback;

@end
