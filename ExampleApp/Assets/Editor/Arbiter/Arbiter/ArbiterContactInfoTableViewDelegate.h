//
//  ArbiterContactInfoTableViewDelegate.h
//  Unity-iPhone
//
//  Created by Andy Zinsser on 9/4/14.
//
//

#import <UIKit/UIKit.h>

@interface ArbiterContactInfoTableViewDelegate : UIView <UITextFieldDelegate, UITableViewDataSource, UITableViewDelegate>

- (id)initWithCallback:(void(^)(NSString *))callback;

@end
