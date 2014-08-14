//
//  ArbiterAlertView.m
//  Unity-iPhone
//
//  Created by Andy Zinsser on 8/8/14.
//
//

#import "ArbiterAlertView.h"
#import <QuartzCore/QuartzCore.h>



@implementation ArbiterAlertView
{
    float _maxHeight;
}

- (id)initWithCallback:(void(^)(void))handler arbiterInstance:(Arbiter *)arbiterInstance
{
    self = [super init];
    
    if (self) {
        self.arbiter = arbiterInstance;
        self.callback = handler;
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidShow:) name:UIKeyboardDidShowNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidHide:) name:UIKeyboardDidHideNotification object:nil];
        
        [self setFrame:[[UIScreen mainScreen] bounds]];
        [self setBackgroundColor:[[UIColor whiteColor] colorWithAlphaComponent:0.95f]];

        [self.layer setCornerRadius:5.0f];
        [self.layer setShadowColor:[UIColor blackColor].CGColor];
        [self.layer setShadowOpacity:0.8];
        [self.layer setShadowRadius:3.0];
        [self.layer setShadowOffset:CGSizeMake(2.0, 2.0)];
        
        [self animateIn];
        [self setupNextScreen];
    }
    return self;
}

- (void)setMaxHeight:(float)maxHeight
{
    _maxHeight = maxHeight;
}

- (void)setFrame:(CGRect)frame
{
    float maxWidth = 320.0f;
    float maxHeight = 285.0f;
    float orientedWidth = frame.size.width;
    float orientedHeight = frame.size.height;
    
    if ( _maxHeight ) {
        maxHeight = _maxHeight;
    }
    
    if ( UIDeviceOrientationIsLandscape([[UIApplication sharedApplication] statusBarOrientation]) ) {
        orientedHeight = frame.size.width;
        orientedWidth = frame.size.height;
        frame.size.height = orientedHeight;
        frame.size.width = orientedWidth;
    }
    
    if ( frame.size.height > maxHeight ) {
        frame.size.height = maxHeight;
    }
    
    if ( frame.size.width > maxWidth ) {
        frame.size.width = maxWidth;
    }
    
    frame.size.width -= 25.0f;
    frame.size.height -= 25.0f;
    
    frame.origin.x = (orientedWidth - frame.size.width) / 2;
    frame.origin.y = (orientedHeight - frame.size.height) / 2;
    
    [super setFrame:frame];
    [self resetSubviewFrames];
}

- (void)resetSubviewFrames
{
    NSLog(@"Override resetSubviewFrames in subclass");
}

- (void)setupNextScreen
{
    NSLog(@"Override setupNextScreen in subclass");
}

- (void)renderNextButton:(BOOL)enabled
{
    self.nextButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [self.nextButton setFrame:CGRectMake(self.bounds.size.width / 2, self.bounds.size.height - 50, self.bounds.size.width / 2, 50)];
    [self.nextButton setTitle:@"Next" forState:UIControlStateNormal];
    [self.nextButton.titleLabel setFont:[UIFont boldSystemFontOfSize:17]];
    [self.nextButton addTarget:self action:@selector(nextButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    
    CALayer *topBorder = [CALayer layer];
    topBorder.frame = CGRectMake(0, 0, self.nextButton.frame.size.width, 0.5f);
    topBorder.backgroundColor = [[UIColor lightGrayColor] CGColor];
    [self.nextButton.layer addSublayer:topBorder];
    [self.nextButton setEnabled:enabled];
    [self addSubview:self.nextButton];
}

- (void)renderCancelButton
{
    self.cancelButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [self.cancelButton setFrame:CGRectMake(0, self.bounds.size.height - 50, self.bounds.size.width / 2, 50)];
    [self.cancelButton setTitle:@"Cancel" forState:UIControlStateNormal];
    [self.cancelButton.titleLabel setFont:[UIFont systemFontOfSize:17]];
    [self.cancelButton addTarget:self action:@selector(cancelButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    
    CALayer *topBorder = [CALayer layer];
    topBorder.frame = CGRectMake(0, 0, self.cancelButton.frame.size.width, 0.5f);
    topBorder.backgroundColor = [[UIColor lightGrayColor] CGColor];
    [self.cancelButton.layer addSublayer:topBorder];
    
    CALayer *rightBorder = [CALayer layer];
    rightBorder.frame = CGRectMake(self.cancelButton.frame.size.width - 0.5f, 0, 0.5f, self.cancelButton.frame.size.height);
    rightBorder.backgroundColor = [[UIColor lightGrayColor] CGColor];
    [self.cancelButton.layer addSublayer:rightBorder];
    
    [self addSubview:self.cancelButton];
}

# pragma mark Click Handlers


- (void)nextButtonClicked:(id)sender
{
    [self setupNextScreen];
}

- (void)cancelButtonClicked:(id)sender
{
    [self animateOut];
    [self endEditing:YES];
}

# pragma mark AlertView Esqueue Animations

- (void)animateIn
{
    CAKeyframeAnimation *animation = [CAKeyframeAnimation
                                      animationWithKeyPath:@"transform"];
    
    CATransform3D scale1 = CATransform3DMakeScale(0.5, 0.5, 1);
    CATransform3D scale2 = CATransform3DMakeScale(0.9, 0.9, 1);
    CATransform3D scale3 = CATransform3DMakeScale(1.1, 1.1, 1);
    CATransform3D scale4 = CATransform3DMakeScale(1.0, 1.0, 1);
    
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
                     completion:^(BOOL finished) { self.callback(); }];
}

# pragma mark NSURLConnection Delegate Methods

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    self.responseData = [[NSMutableData alloc] init];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    [self.responseData appendData:data];
}

- (NSCachedURLResponse *)connection:(NSURLConnection *)connection
                  willCacheResponse:(NSCachedURLResponse*)cachedResponse {
    return nil;
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    NSError *error = nil;
    NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:self.responseData
                                                         options:NSJSONReadingMutableLeaves
                                                           error:&error];
    self.responseHandler(dict);
    self.responseData = nil;
    
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    NSLog(@"Connection Error");
}

#pragma mark Utility Helpers

- (NSString *)addThousandsSeparatorToString:(NSString *)original
{
    NSNumberFormatter *separatorFormattor = [[NSNumberFormatter alloc] init];
    [separatorFormattor setFormatterBehavior: NSNumberFormatterBehavior10_4];
    [separatorFormattor setNumberStyle: NSNumberFormatterDecimalStyle];
    
    NSNumberFormatter *stringToNumberFormatter = [[NSNumberFormatter alloc] init];
    [stringToNumberFormatter setNumberStyle:NSNumberFormatterDecimalStyle];
    NSNumber *origNumber = [stringToNumberFormatter numberFromString:original];
    
    return [separatorFormattor stringFromNumber:origNumber];
}


# pragma mark NSNotification Handlers

- (void)keyboardDidShow:(NSNotification *)notification
{
    CGRect screenSize = [[[notification userInfo] valueForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue];
    [self setFrame:screenSize];
}

-(void)keyboardDidHide:(NSNotification *)notification
{
    [self setFrame:[[[notification userInfo] valueForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue]];
}




@end
