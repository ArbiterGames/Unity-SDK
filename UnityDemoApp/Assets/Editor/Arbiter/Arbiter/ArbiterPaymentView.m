//
//  ArbiterPaymentView.m
//  
//
//  Created by Andy Zinsser on 6/24/14.
//
//

#import <objc/runtime.h>
#import <QuartzCore/QuartzCore.h>
#import "ArbiterPaymentView.h"
#import "ArbiterConstants.h"

#define BUNDLE_SELECT_TAG 667
#define PAYMENT_INFO_TAG 668

@implementation ArbiterPaymentView
{
    // Custom Arbiter
    void(^callback)(void);
    CGRect *parentFrame;
    NSDictionary *user;
    
    // Picker View
    UIPickerView *pickerView;
    NSMutableArray *dataArray;
    NSMutableDictionary *selectedBundle;
    
    // NSURL Connection
    void(^responseHandler)(NSDictionary *responseDict);
    NSMutableData *responseData;
    
}

- (id)initWithFrame:(CGRect)frame andCallback:(void(^)(void))handler forUser:(NSDictionary *)userDict
{
    self = [super initWithFrame:CGRectInset(frame, 25, 25)];
    if (self) {
        parentFrame = &(frame);
        user = userDict;
        callback = handler;
        self.backgroundColor = [UIColor whiteColor];
        [self animateIn];
        [self setupBundleSelectLayout];
    }
    return self;
}

- (void)setupBundleSelectLayout
{
    // border radius
    [self.layer setCornerRadius:5.0f];
    
    // drop shadow
    [self.layer setShadowColor:[UIColor blackColor].CGColor];
    [self.layer setShadowOpacity:0.8];
    [self.layer setShadowRadius:3.0];
    [self.layer setShadowOffset:CGSizeMake(2.0, 2.0)];
    
    [self renderCancelButton:350];
    [self renderSelectButton];
    [self renderBundleOptions];
}

- (void)setupStripeView
{
    self.stripeView = [[STPView alloc] initWithFrame:*(parentFrame)
                                              andKey:@"pk_test_1SQ84edElZEWoGqlR7XB9V5j"];
    self.stripeView.delegate = self;
    [self addSubview:self.stripeView];
    [self renderPurchaseButton];
    [self renderCancelButton:150];
}


# pragma mark Click Handlers

- (void)cancelButtonClicked:(id)sender
{
    [self animateOut];
}

- (void)selectButtonClicked:(id)sender
{
    [self hideBundleSelectUI];
    [self setupStripeView];
}

- (void)purchaseButtonClicked:(id)sender
{
    [self.stripeView createToken:^(STPToken *token, NSError *error) {
        if (error) {
            [self handleError:[error localizedDescription]];
        } else {
            NSLog(@"Received token %@", token.tokenId);
    
            responseHandler = [^(NSDictionary *responseDict) {
                if ([[responseDict objectForKey:@"errors"] count]) {
                    [self handleError:[[responseDict objectForKey:@"errors"] objectAtIndex:0]];
                } else {
                    callback();
                }
            } copy];
            
            
            NSData *paramsData = [NSJSONSerialization dataWithJSONObject:@{@"card_token": token.tokenId,
                                                                           @"bundle_sku": [selectedBundle objectForKey:@"sku"]}
                                                                 options:0
                                                                   error:&error];
            NSString *paramsStr = [[NSString alloc] initWithData:paramsData encoding:NSUTF8StringEncoding];
            NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:@"https://www.arbiter.me/stripe/deposit"]];
            request.HTTPMethod = @"POST";
            [request setHTTPBody:[paramsStr dataUsingEncoding:NSUTF8StringEncoding]];
            [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
            NSString *tokenString = [NSString stringWithFormat:@"Token %@", [user objectForKey:@"token"]];
            [request setValue:tokenString forHTTPHeaderField:@"Authorization"];
            [[NSURLConnection alloc] initWithRequest:request delegate:self];
        }
    }];
}


# pragma mark UI Rendering Methods

- (void)renderSelectButton
{
    UIButton *button = [UIButton buttonWithType:UIButtonTypeSystem];
    [button setTitle:@"Select" forState:UIControlStateNormal];
    [button sizeToFit];
    [button setTag:BUNDLE_SELECT_TAG];
    button.center = CGPointMake([UIScreen mainScreen].bounds.size.width / 2, 300);
    [button addTarget:self action:@selector(selectButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:button];
}

- (void)renderCancelButton:(NSInteger)yPosition
{
    UIButton *button = [UIButton buttonWithType:UIButtonTypeSystem];
    [button setTitle:@"Cancel" forState:UIControlStateNormal];
    [button sizeToFit];
    [button setTag:BUNDLE_SELECT_TAG];
    button.center = CGPointMake([UIScreen mainScreen].bounds.size.width / 2, yPosition);
    [button addTarget:self action:@selector(cancelButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:button];
}

- (void)renderBundleOptions
{
    // Once we get the current bundle prices, display them in a UIPicker
    responseHandler = [^(NSDictionary *responseDict) {
        dataArray = [[NSMutableArray alloc] initWithArray:[responseDict objectForKey:@"bundles"]];
        float screenWidth = [UIScreen mainScreen].bounds.size.width;
        float pickerWidth = screenWidth * 3 / 4;
        float xPoint = screenWidth / 2 - pickerWidth / 2;
        
        pickerView = [[UIPickerView alloc] init];
        [pickerView setTag:BUNDLE_SELECT_TAG];
        [pickerView setDataSource: self];
        [pickerView setDelegate: self];
        [pickerView setFrame: CGRectMake(xPoint, 50.0f, pickerWidth, 200.0f)];
        pickerView.showsSelectionIndicator = YES;
        
        NSInteger selectedRow = 1;
        [pickerView selectRow:selectedRow inComponent:0 animated:YES];
        selectedBundle = [dataArray objectAtIndex:selectedRow];
        
        [self addSubview: pickerView];
    } copy];
    
    // Get the current bundle prices from the server
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:@"https://www.arbiter.me/cashier/bundle"]];
    request.HTTPMethod = @"GET";
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    NSString *tokenString = [NSString stringWithFormat:@"Token %@", [user objectForKey:@"token"]];
    NSLog(@"tokenString: %@", tokenString);
    [request setValue:tokenString forHTTPHeaderField:@"Authorization"];
    [[NSURLConnection alloc] initWithRequest:request delegate:self];
}

- (void)hideBundleSelectUI
{
    for (UIView *view in [self subviews]) {
        if (view.tag == BUNDLE_SELECT_TAG) {
            [view removeFromSuperview];
        }
    }
}

- (void)renderPurchaseButton
{
    // Keep it hidden until the payment form is correct
    self.purchaseButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [self.purchaseButton setTitle:@"Submit" forState:UIControlStateNormal];
    [self.purchaseButton sizeToFit];
    self.purchaseButton.enabled = false;
    [self.purchaseButton setTag:PAYMENT_INFO_TAG];
    self.purchaseButton.center = CGPointMake([UIScreen mainScreen].bounds.size.width / 2, 100);
    [self.purchaseButton addTarget:self action:@selector(purchaseButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:self.purchaseButton];
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
                     completion:^(BOOL finished) { callback(); }];
}


# pragma mark Stripe View Delegate Methods

- (void)stripeView:(STPView *)view withCard:(PKCard *)card isValid:(BOOL)valid
{
    self.purchaseButton.enabled = true;
}

- (void)handleError:(NSString *)error
{
    UIAlertView *message = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error", @"Error")
                                                      message:error
                                                     delegate:nil
                                            cancelButtonTitle:NSLocalizedString(@"OK", @"OK")
                                            otherButtonTitles:nil];
    [message show];
}


# pragma mark Picker Delegate Methods

// Number of components.
-(NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}

// Total rows in our component.
-(NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    return [dataArray count];
}

// Display each row's data.
-(NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    return [NSString stringWithFormat:@"%@ credits for $%@", [[dataArray objectAtIndex:row] objectForKey:@"value"],
                                                             [[dataArray objectAtIndex:row] objectForKey:@"price"]];
}

// Do something with the selected row.
-(void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    selectedBundle = [dataArray objectAtIndex:row];
}


# pragma mark NSURLConnection Delegate Methods

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    responseData = [[NSMutableData alloc] init];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    [responseData appendData:data];
}

- (NSCachedURLResponse *)connection:(NSURLConnection *)connection
                  willCacheResponse:(NSCachedURLResponse*)cachedResponse {
    return nil;
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    NSError *error = nil;
    NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:responseData
                                                         options:NSJSONReadingMutableLeaves
                                                           error:&error];
    responseHandler(dict);
    responseData = nil;
    
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    NSLog(@"Connection Error");
}

#pragma mark Utility Helpers


- (UIWindow*) getTopApplicationWindow
{
    UIApplication* clientApp = [UIApplication sharedApplication];
    NSArray* windows = [clientApp windows];
    UIWindow* topWindow = nil;
    
    if (windows && [windows count] > 0)
        topWindow = [[clientApp windows] objectAtIndex:0];
    
    return topWindow;
}


@end
