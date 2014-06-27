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
    self = [super initWithFrame:CGRectInset(frame, 25, 50)];
    if (self) {
        parentFrame = &(frame);
        user = userDict;
        callback = handler;
        [self animateIn];
        [self setupBundleSelectLayout];
    }
    return self;
}

- (void)setupBundleSelectLayout
{
    [self setBackgroundColor:[[UIColor whiteColor] colorWithAlphaComponent:0.95f]];
    [self.layer setCornerRadius:5.0f];
    [self.layer setShadowColor:[UIColor blackColor].CGColor];
    [self.layer setShadowOpacity:0.8];
    [self.layer setShadowRadius:3.0];
    [self.layer setShadowOffset:CGSizeMake(2.0, 2.0)];
    
    UILabel *title = [[UILabel alloc] initWithFrame:CGRectMake(0, 10, self.bounds.size.width, 40)];
    [title setText:@"Deposit Credits"];
    [title setFont:[UIFont boldSystemFontOfSize:17]];
    [title setTextAlignment:NSTextAlignmentCenter];
    [title setTag:BUNDLE_SELECT_TAG];
    [self addSubview:title];
    
    UITextView *message = [[UITextView alloc] initWithFrame:CGRectMake(10, 40, self.bounds.size.width - 20, 50)];
    [message setText:@"Select the amount of credits you\nwould like to buy."];
    [message setFont:[UIFont systemFontOfSize:14]];
    [message setTextAlignment:NSTextAlignmentCenter];
    [message setTag:BUNDLE_SELECT_TAG];
    [message setBackgroundColor:[UIColor clearColor]];
    [self addSubview:message];
    
    [self renderCancelButton];
    [self renderSelectButton];
    [self renderBundleOptions];
}

- (void)setupBillingInfoLayout
{
    CGRect frame = self.frame;
    frame.size.height = 240;
    frame.size.width = frame.size.width + 30;
    frame.origin.y = 10;
    frame.origin.x = 10;
    [self setFrame:frame];

    self.stripeView = [[STPView alloc] initWithFrame:CGRectMake(5, 70, frame.size.width - 10, 40)
                                              andKey:@"pk_test_1SQ84edElZEWoGqlR7XB9V5j"];
    self.stripeView.delegate = self;
    [self addSubview:self.stripeView];
    
    UITextView *message = [[UITextView alloc] initWithFrame:CGRectMake(10, 10, self.bounds.size.width - 20, 50)];
    NSString *valueText = [self addThousandsSeparatorToString:[selectedBundle objectForKey:@"value"]];
    NSString *messageBody = [NSString stringWithFormat:@"Enter your billing info for purchasing\n%@ credits for $%@", valueText, [selectedBundle objectForKey:@"price"]];
    [message setText:messageBody];
    [message setFont:[UIFont systemFontOfSize:14]];
    [message setTextAlignment:NSTextAlignmentCenter];
    [message setBackgroundColor:[UIColor clearColor]];
    [message setTag:PAYMENT_INFO_TAG];
    [self addSubview:message];
    
    [self renderPurchaseButton];
    [self renderCancelButton];
}


# pragma mark Click Handlers

- (void)cancelButtonClicked:(id)sender
{
    [self animateOut];
}

- (void)selectButtonClicked:(id)sender
{
    [self hideBundleSelectUI];
    [self setupBillingInfoLayout];
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
    [button setFrame:CGRectMake(0, self.bounds.size.height - 50 * 2, self.bounds.size.width, 50)];
    [button setTitle:@"Next" forState:UIControlStateNormal];
    [button.titleLabel setFont:[UIFont boldSystemFontOfSize:17]];
    [button setTag:BUNDLE_SELECT_TAG];
    [button addTarget:self action:@selector(selectButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    
    CALayer *topBorder = [CALayer layer];
    topBorder.frame = CGRectMake(0, 0, button.frame.size.width, 0.5f);
    topBorder.backgroundColor = [[UIColor lightGrayColor] CGColor];
    [button.layer addSublayer:topBorder];

    [self addSubview:button];
}

- (void)renderCancelButton
{
    UIButton *button = [UIButton buttonWithType:UIButtonTypeSystem];
    [button setFrame:CGRectMake(0, self.bounds.size.height - 50, self.bounds.size.width, 50)];
    [button setTitle:@"Cancel" forState:UIControlStateNormal];
    [button setTag:BUNDLE_SELECT_TAG];
    [button.titleLabel setFont:[UIFont systemFontOfSize:17]];
    [button addTarget:self action:@selector(cancelButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    
    CALayer *topBorder = [CALayer layer];
    topBorder.frame = CGRectMake(0, 0, button.frame.size.width, 0.5f);
    topBorder.backgroundColor = [[UIColor lightGrayColor] CGColor];
    [button.layer addSublayer:topBorder];
    
    [self addSubview:button];
}

- (void)renderBundleOptions
{
    // Once we get the current bundle prices, display them in a UIPicker
    responseHandler = [^(NSDictionary *responseDict) {
        dataArray = [[NSMutableArray alloc] initWithArray:[responseDict objectForKey:@"bundles"]];
        
        pickerView = [[UIPickerView alloc] init];
        [pickerView setTag:BUNDLE_SELECT_TAG];
        [pickerView setDataSource: self];
        [pickerView setDelegate: self];
        [pickerView setFrame: CGRectMake(0, 70, self.bounds.size.width, 300)];
        pickerView.showsSelectionIndicator = YES;
        
        NSInteger selectedRow = 2;
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
    [self.purchaseButton.titleLabel setFont:[UIFont boldSystemFontOfSize:17]];
    [self.purchaseButton setFrame:CGRectMake(0, self.bounds.size.height - 50 * 2, self.bounds.size.width, 50)];
    self.purchaseButton.enabled = false;
    [self.purchaseButton setTag:PAYMENT_INFO_TAG];
    CALayer *topBorder = [CALayer layer];
    topBorder.frame = CGRectMake(0, 0, self.purchaseButton.frame.size.width, 0.5f);
    topBorder.backgroundColor = [[UIColor lightGrayColor] CGColor];
    [self.purchaseButton.layer addSublayer:topBorder];
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
    return [NSString stringWithFormat:@"%@ credits for $%@", [self addThousandsSeparatorToString:[[dataArray objectAtIndex:row] objectForKey:@"value"]],
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
