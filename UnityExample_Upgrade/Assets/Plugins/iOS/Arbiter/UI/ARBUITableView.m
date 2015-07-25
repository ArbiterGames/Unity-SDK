//
//  ARBUITableView.m
//  Unity-iPhone
//
//  Created by Andy Zinsser on 9/6/14.
//
//

#import "ARBUITableView.h"

@implementation ARBUITableView : UITableView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame style:UITableViewStyleGrouped];
    if ( self ) {
        self.backgroundColor = [UIColor clearColor];
        self.backgroundView = nil;
        self.separatorColor = [UIColor clearColor];
        self.scrollEnabled = NO;
        self.allowsSelection = NO;
        [[UILabel appearanceWhenContainedIn:[UITableViewHeaderFooterView class], nil] setFont:[UIFont boldSystemFontOfSize:17.0]];
        [[UILabel appearanceWhenContainedIn:[UITableViewHeaderFooterView class], nil] setTextColor:[UIColor whiteColor]];
    }
    return self;
}

- (void)setFrame:(CGRect)frame {
    BOOL IS_LESS_THAN_IOS8 = [[[UIDevice currentDevice] systemVersion] compare: @"7.9" options: NSNumericSearch] != NSOrderedDescending;
    if ( IS_LESS_THAN_IOS8 ) {
        // No-op. Only an iOS8 issue.
    } else {
        CGFloat inset = 20.0;
        frame.origin.x += inset;
        frame.size.width -= 2 * inset;
    }
    [super setFrame:frame];
}

@end
