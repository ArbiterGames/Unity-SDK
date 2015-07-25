//
//  ARBWalkThrough.m
//  Unity-iPhone
//
//  Created by Andy Zinsser on 9/16/14.
//
//

#import "ARBWalkThrough.h"

@implementation ARBWalkThrough

- (id)initWithWalkThroughId:(NSString *)walkThroughId arbiterInstance:(Arbiter *)arbiterInstance
{
    self = [super init:arbiterInstance];
    if ( self ) {
        self.walkThroughId = walkThroughId;
    }
    return self;
}

- (void)renderLayout
{
    UIButton *backButton = [UIButton buttonWithType:UIButtonTypeSystem];
    float btnWidth = 50.0;
    float btnHeight = 50.0;
    [backButton setFrame:CGRectMake(0.0, 5.0, btnWidth, btnHeight)];
    [backButton setTitle:@"Back" forState:UIControlStateNormal];
    [backButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [backButton addTarget:self action:@selector(backButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    backButton.titleLabel.textAlignment = NSTextAlignmentCenter;
    backButton.titleLabel.font = [UIFont boldSystemFontOfSize:17.0];
    [self addSubview:backButton];
    
    UILabel *title = [[UILabel alloc] initWithFrame:CGRectMake(50.0, self.titleYPos,
                                                               self.frame.size.width - 100.0, self.titleHeight)];
    title.font = [UIFont fontWithName:@"HelveticaNeue-UltraLight" size:38.0];
    title.textColor = [UIColor whiteColor];
    title.text = @"Play For Cash";
    title.textAlignment = NSTextAlignmentCenter;
    title.numberOfLines = 0;
    [self addSubview:title];
    
    CALayer *topBorder = [CALayer layer];
    topBorder.frame = CGRectMake(0.0, self.titleYPos + self.titleHeight + 10.0,
                                 self.frame.size.width, 0.5f);
    topBorder.backgroundColor = [[UIColor whiteColor] CGColor];
    topBorder.opacity = 0.2;
    [self.layer addSublayer:topBorder];
    
    UILabel *message = [[UILabel alloc] initWithFrame:CGRectMake(0.0, topBorder.frame.origin.y, self.frame.size.width, 160.0)];
    message.textColor = [UIColor whiteColor];
    message.textAlignment = NSTextAlignmentLeft;
    message.numberOfLines = 0;
    message.text = @"Pay an entry fee to compete in cash tournaments against other players. The player with the highest score wins the prize. \n\nAccess your wallet in the main menu to deposit and withdraw your tournament credits for cash.";
    [self addSubview:message];
}

#pragma mark Click Handlers

- (void)backButtonClicked:(id)sender
{
    if ( self.callback ) {
        self.callback();
    }
    [self.parentWindow hide];
}

@end
