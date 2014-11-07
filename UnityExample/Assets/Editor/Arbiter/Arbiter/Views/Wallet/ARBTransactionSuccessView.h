//
//  ARBTransactionSuccessView.h
//  Unity-iPhone
//
//  Created by Andy Zinsser on 9/6/14.
//
//

#import <UIKit/UIKit.h>

@interface ARBTransactionSuccessView : UIView <UITableViewDataSource, UITableViewDelegate>

@property (strong) void (^callback)(void);

- (id)initWithCallback:(void(^)(void))callback;
- (void)backButtonClicked:(id)sender;

@end
