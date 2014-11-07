//
//  ArbiterCORulesTableViewDelegate.h
//  Unity-iPhone
//
//  Created by Andy Zinsser on 10/16/14.
//
//

#import <UIKit/UIKit.h>

@interface ARBSCRulesView : UIView <UITableViewDataSource, UITableViewDelegate>

@property (strong) NSString *rulesBody;

- (id)initWithMessage:(NSString *)message;

@end
