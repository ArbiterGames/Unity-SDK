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
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidShow:) name:UIKeyboardDidShowNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidHide:) name:UIKeyboardDidHideNotification object:nil];
        
        self.arbiter = arbiterInstance;
        self.maxWidth = 400.0;
        self.maxHeight = 320.0;
        self.availableHeight = self.frame.size.height;
        self.titleHeight = 40.0;
        self.titleYPos = 10.0;
        if ( frame.size.width > self.maxWidth ) {
            self.marginizedFrame = CGRectMake((frame.size.width - self.maxWidth) / 2, (self.availableHeight - self.maxHeight) / 2,
                                              self.maxWidth, self.maxHeight);
            [self setFrame:self.marginizedFrame];
        } else {
            self.marginizedFrame = frame;
        }
        [self renderLayout];
    }
    return self;
}

- (void)renderLayout
{
    [self updatePositionOnScreen];
}

- (void)updatePositionOnScreen
{
    float finalHeight = 0.0;
    for ( UIView *subview in self.subviews ) {
        finalHeight += subview.frame.size.height;
    }
    
    [self setFrame:CGRectMake(self.frame.origin.x, (self.availableHeight - finalHeight) / 2,
                              self.frame.size.width, finalHeight)];
}


# pragma mark Click Handlers

- (void)closeButtonClicked:(id)sender
{
    [self.parentWindow hide];
}

- (void)moveViewForKeyboard:(NSNotification *)notification keyboardIsUp:(BOOL)keyboardIsUp
{
    NSDictionary *userInfo = [notification userInfo];
    CGRect updatedFrame = self.frame;
    CGRect keyboardEndFrame;
    [[userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] getValue:&keyboardEndFrame];
    
    if ( UIDeviceOrientationIsLandscape([[UIApplication sharedApplication] statusBarOrientation]) ) {
        updatedFrame.origin.y -= (keyboardEndFrame.size.width * (keyboardIsUp? 1 : -1)) / 2;
    } else {
        updatedFrame.origin.y -= (keyboardEndFrame.size.height * (keyboardIsUp? 1 : -1)) / 2;
    }
    if ( (keyboardIsUp && updatedFrame.origin.y > 0) || (keyboardIsUp == NO && updatedFrame.origin.y + updatedFrame.size.height <= self.availableHeight) ) {
        self.frame = updatedFrame;
    }
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


# pragma mark NSNotification Handlers

- (void)keyboardDidShow:(NSNotification *)notification
{
    [self moveViewForKeyboard:notification keyboardIsUp:YES];
}

- (void)keyboardDidHide:(NSNotification *)notification
{
    [self moveViewForKeyboard:notification keyboardIsUp:NO];
}

@end
