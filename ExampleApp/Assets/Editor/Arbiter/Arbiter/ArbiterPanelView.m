//
//  ArbiterPanelView.m
//  Unity-iPhone
//
//  Created by Andy Zinsser on 9/3/14.
//
//

#import "ArbiterPanelView.h"

@implementation ArbiterPanelView

- (id)init:(Arbiter *)arbiterInstance
{
    CGRect frame = CGRectMake(0.0f, 0.0f, [[UIScreen mainScreen] bounds].size.width, [[UIScreen mainScreen] bounds].size.height);
    if ( UIDeviceOrientationIsLandscape([[UIApplication sharedApplication] statusBarOrientation]) ) {
        frame = CGRectMake(0.0f, 0.0f, [[UIScreen mainScreen] bounds].size.height, [[UIScreen mainScreen] bounds].size.width);
    }
    self = [super initWithFrame:frame];
    if ( self ) {
        self.arbiter = arbiterInstance;
        [self renderLayout];
    }
    return self;
}

- (void)renderLayout
{
    [self renderCloseButton];
}

- (void)renderCloseButton
{
    UIButton *closeButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [closeButton setFrame:CGRectMake(self.bounds.size.width - 74.0, 0.0f, 74.0, 23.0)];
    [closeButton setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"close_arrow"]]];
    [closeButton addTarget:self action:@selector(closeButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:closeButton];
}


# pragma mark Click Handlers

- (void)closeButtonClicked:(id)sender
{
    [self.parentWindow hide];
}


# pragma mark TableView Delegate Methods


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 0;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return nil;
}


@end
