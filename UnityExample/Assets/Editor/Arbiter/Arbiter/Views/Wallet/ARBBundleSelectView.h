//
//  ARBBundleSelectView.h
//  Unity-iPhone
//
//  Created by Andy Zinsser on 9/4/14.
//
//

#import <UIKit/UIKit.h>

@interface ARBBundleSelectView : UIView <UITableViewDataSource, UITableViewDelegate>

@property (strong) NSMutableArray *availableBundles;
@property (strong) void (^selectionCallback)(NSDictionary *selectedBundle);

- (id)initWithBundles:(NSMutableArray *)availableBundles andSelectionCallback:(void(^)(NSDictionary *))selectionCallback;

@end
