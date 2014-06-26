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
    CGRect *_parentFrame;
    
    // Picker View
    UIPickerView *pickerView;
    NSMutableArray *dataArray;
    NSMutableDictionary *selectedBundle;
    
    // NSURL Connection
    void(^_responseHandler)(NSDictionary *responseDict);
    NSMutableData *_responseData;
    
}

- (id)initWithFrame:(CGRect)frame andCallback:(void(^)(void))handler
{
    self = [super initWithFrame:frame];
    if (self) {
        _parentFrame = &(frame);
        callback = handler;
        [self setupBundleSelectLayout];
    }
    return self;
}

- (void)setupBundleSelectLayout
{
    self.backgroundColor = [UIColor whiteColor];
    [self renderCancelButton:350];
    [self renderSelectButton];
    [self renderBundleOptions];
}

- (void)setupStripeView
{
    self.stripeView = [[STPView alloc] initWithFrame:*(_parentFrame)
                                              andKey:@"pk_test_1SQ84edElZEWoGqlR7XB9V5j"];
    self.stripeView.delegate = self;
    [self addSubview:self.stripeView];
    [self renderPurchaseButton];
    [self renderCancelButton:150];
}


# pragma mark Click Handlers

- (void)cancelButtonClicked:(id)sender
{
    callback();
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
    
            _responseHandler = [^(NSDictionary *responseDict) {
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

            // TODO: Include the players token not ours
            NSString *tokenString = [NSString stringWithFormat:@"Token %@", TEMP_ACCESS_TOKEN];
            
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
    _responseHandler = [^(NSDictionary *responseDict) {
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
    NSString *tokenString = [NSString stringWithFormat:@"Token %@", TEMP_ACCESS_TOKEN];
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
    _responseData = [[NSMutableData alloc] init];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    [_responseData appendData:data];
}

- (NSCachedURLResponse *)connection:(NSURLConnection *)connection
                  willCacheResponse:(NSCachedURLResponse*)cachedResponse {
    return nil;
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    NSError *error = nil;
    NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:_responseData
                                                         options:NSJSONReadingMutableLeaves
                                                           error:&error];
    _responseHandler(dict);
    _responseData = nil;
    
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
