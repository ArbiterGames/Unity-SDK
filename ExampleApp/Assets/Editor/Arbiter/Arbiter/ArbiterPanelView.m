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
        self.maxWidth = 400.0;
        self.titleHeight = 40.0;
        self.titleYPos = 10.0;
        [self animateIn];
        [self renderLayout];
    }
    return self;
}

- (void)renderLayout
{
    self.backgroundColor = [UIColor clearColor];
    if ( self.bounds.size.width > self.maxWidth ) {
        self.marginizedFrame = CGRectMake((self.bounds.size.width - self.maxWidth) / 2, 0.0,
                                          self.maxWidth, self.bounds.size.height - self.titleHeight - self.titleYPos);
    } else {
        self.marginizedFrame = CGRectMake(0.0, 0.0, self.bounds.size.width, self.bounds.size.height - self.titleHeight - self.titleYPos);
    }
    [self renderPoweredBy];
}

- (void)renderPoweredBy
{
    UILabel *poweredBy = [[UILabel alloc] initWithFrame:CGRectMake((self.bounds.size.width - 100) / 2, self.bounds.size.height - 20.0, 100.0, 20.0f)];
    [poweredBy setText:@"powered by Arbiter"];
    [poweredBy setFont:[UIFont systemFontOfSize:11.0f]];
    [poweredBy setTextColor:[UIColor whiteColor]];
    [poweredBy setAlpha:0.3f];
    [self addSubview:poweredBy];
}


# pragma mark Click Handlers

- (void)closeButtonClicked:(id)sender
{
    [self animateOut];
}


# pragma mark AlertView Esqueue Animations

- (void)animateIn
{
    CAKeyframeAnimation *animation = [CAKeyframeAnimation
                                      animationWithKeyPath:@"transform"];

    CATransform3D scale1 = CATransform3DMakeScale(1.0, 0.0, 1.0);
    CATransform3D scale2 = CATransform3DMakeScale(1.0, 0.5, 1.0);
    CATransform3D scale3 = CATransform3DMakeScale(1.0, 0.8, 1.0);
    CATransform3D scale4 = CATransform3DMakeScale(1.0, 1.0, 1.0);
    
    NSArray *frameValues = [NSArray arrayWithObjects:
                            [NSValue valueWithCATransform3D:scale1],
                            [NSValue valueWithCATransform3D:scale2],
                            [NSValue valueWithCATransform3D:scale3],
                            [NSValue valueWithCATransform3D:scale4],
                            nil];
    [animation setValues:frameValues];
    
    NSArray *frameTimes = [NSArray arrayWithObjects:
                           [NSNumber numberWithFloat:0.0],
                           [NSNumber numberWithFloat:0.5],
                           [NSNumber numberWithFloat:0.9],
                           [NSNumber numberWithFloat:1.0],
                           nil];
    [animation setKeyTimes:frameTimes];
    
    animation.fillMode = kCAFillModeForwards;
    animation.removedOnCompletion = NO;
    animation.duration = .2;

    [self.layer addAnimation:animation forKey:@"popup"];
}

- (void)animateOut
{
    [UIView animateWithDuration:0.2f
                     animations:^{ [self setAlpha:0.0f]; }
                     completion:^(BOOL finished) { [self.parentWindow hide]; }];
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
