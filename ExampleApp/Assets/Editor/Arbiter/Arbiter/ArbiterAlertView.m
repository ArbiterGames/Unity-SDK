//
//  ArbiterAlertView.m
//  Unity-iPhone
//
//  Created by Andy Zinsser on 8/8/14.
//
//

#import "ArbiterAlertView.h"

@implementation ArbiterAlertView

- (id)initWithCallback:(void(^)(void))handler arbiterInstance:(Arbiter *)arbiterInstance
{
    self = [super init];
    
    if (self) {
        self.arbiter = arbiterInstance;
        self.callback = handler;
        
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

- (void)setFrame:(CGRect)frame
{
    float maxWidth = 420.0f;
    float maxHeight = 285.0f;
    float orientedWidth = frame.size.width;
    float orientedHeight = frame.size.height;
    
    if ( UIDeviceOrientationIsLandscape([[UIApplication sharedApplication] statusBarOrientation]) ) {
        orientedHeight = frame.size.width;
        orientedWidth = frame.size.height;
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
}

- (void)setupNextScreen
{
    NSLog(@"Override setupNextScreen in subclass");
}

# pragma mark Click Handlers

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




@end
