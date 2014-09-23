//
//  ArbiterPaymentOptionsTableViewDelegate.h
//  Unity-iPhone
//
//  Created by Andy Zinsser on 9/20/14.
//
//

#import <UIKit/UIKit.h>

@interface ArbiterPaymentOptionsTableViewDelegate : UIView <UITableViewDataSource, UITableViewDelegate>

@property (strong) void (^callback)(NSString*);

- (id)initWithCallback:(void(^)(NSString *))callback;

@end
