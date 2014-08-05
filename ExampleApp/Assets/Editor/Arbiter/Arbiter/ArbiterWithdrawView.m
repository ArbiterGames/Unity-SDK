//
//  ArbiterWithdrawView.m
//  Unity-iPhone
//
//  Created by Andy Zinsser on 6/27/14.
//
//

#import "ArbiterWithdrawView.h"
#import "ArbiterConstants.h"
#import "STPView.h"
#import "Arbiter.h"

#define AMOUNT_SELECT_TAG 767
#define CARD_INFO_TAG 768
#define NAME_FIELD_TAG 769
#define EMAIL_FIELD_TAG 770
#define NEXT_BUTTON_TAG 771
#define CANCEL_BUTTON_TAG 772

@implementation ArbiterWithdrawView
{
    // Custom Arbiter
    void(^callback)(void);
    CGRect *parentFrame;
    Arbiter *arbiter;
    float selectedWithdrawAmount;
    
    UILabel *withdrawSelectionLabel;
    UILabel *withdrawValueLabel;
    
    // NSURL Connection
    void(^responseHandler)(NSDictionary *responseDict);
    NSMutableData *responseData;
}

- (id)initWithFrame:(CGRect)frame andCallback:(void(^)(void))handler arbiterInstance:(Arbiter *)arbiterInstance
{
    UIDeviceOrientation orientation = [[UIDevice currentDevice] orientation];
    
    BOOL isLandscape = orientation == 3 || orientation == 4 || orientation == 5;
    float trueScreenHeight = [UIScreen mainScreen].bounds.size.height;
    float trueScreenWidth = [UIScreen mainScreen].bounds.size.width;
    float maxWidth = 420.0f;
    float maxHeight = 285.0f;
    
    if ( isLandscape ) {
        trueScreenHeight = [UIScreen mainScreen].bounds.size.width;
        trueScreenWidth = [UIScreen mainScreen].bounds.size.height;
        
        float wrongWidth = frame.size.width;
        float wrongHeight = frame.size.height;
        frame.size.width = wrongHeight;
        frame.size.height = wrongWidth;
    }
    
    if ( frame.size.height > maxHeight ) {
        frame.size.height = maxHeight;
    }
    
    if ( frame.size.width > maxWidth ) {
        frame.size.width = maxWidth;
    }
    
    frame.size.width -= 25.0f;
    frame.size.height -= 25.0f;
    
    self = [super initWithFrame:CGRectMake((trueScreenWidth - frame.size.width) / 2,
                                           (trueScreenHeight - frame.size.height) / 2,
                                           frame.size.width,
                                           frame.size.height)];    self = [super initWithFrame:CGRectInset(frame, 25.0f, 25.0f)];
    if (self) {
        parentFrame = &(frame);
        arbiter = arbiterInstance;
        callback = handler;
        
        [self setBackgroundColor:[[UIColor whiteColor] colorWithAlphaComponent:0.95f]];
        [self.layer setCornerRadius:5.0f];
        [self.layer setShadowColor:[UIColor blackColor].CGColor];
        [self.layer setShadowOpacity:0.8f];
        [self.layer setShadowRadius:3.0f];
        [self.layer setShadowOffset:CGSizeMake(2.0f, 2.0f)];
        
        [self animateIn];
        [self setupNextScreen];
    }
    return self;
}


# pragma mark UI Rendering Methods

- (void)setupNextScreen
{
    BOOL enabled = true;
    [self hideNextButton];
    [self hideCancelButton];
    [self hideAmountSelectUI];
    [self hideNameFieldUI];
    [self hideEmailFieldUI];
    
    if ( selectedWithdrawAmount == 0.0f ) {
        [self setupWithdrawAmountLayout];
    } else if ( self.nameField == nil ) {
        [self setupGenericFieldLayoutWithTag:NAME_FIELD_TAG];
    } else if ( self.emailField == nil ) {
        [self setupGenericFieldLayoutWithTag:EMAIL_FIELD_TAG];
    } else if ( self.stripeView == nil ) {
        [self setupCardFieldUI];
        enabled = false;
    } else {
        [self getTokenAndSubmitWithdraw];
        enabled = false;
    }
    
    [self renderCancelButton];
    [self renderNextButton:enabled];
}

- (void)setupWithdrawAmountLayout
{
    float walletBalance = [[[arbiter wallet] objectForKey:@"balance"] floatValue];
    
    UILabel *title = [[UILabel alloc] initWithFrame:CGRectMake(0.0f, 10.0f, self.bounds.size.width, 40.0f)];
    [title setText:@"Withdraw"];
    [title setFont:[UIFont boldSystemFontOfSize:17]];
    [title setTextAlignment:NSTextAlignmentCenter];
    [title setTag:AMOUNT_SELECT_TAG];
    [self addSubview:title];
    
    UILabel *message = [[UILabel alloc] initWithFrame:CGRectMake(10.0f, 30.0f, self.bounds.size.width - 20.0f, 50.0f)];
    [message setNumberOfLines:0];
    [message setText:@"Select the amount of credits you would like to withdraw."];
    [message setFont:[UIFont systemFontOfSize:14]];
    [message setTextAlignment:NSTextAlignmentCenter];
    [message setTag:AMOUNT_SELECT_TAG];
    [message setBackgroundColor:[UIColor clearColor]];
    [self addSubview:message];
    
    if ( walletBalance < 100 ) {
        [message setText:[NSString stringWithFormat:@"Your current wallet balance (%.f credits) is below the withdraw minimum.", walletBalance]];
        [self renderFullWidthCancelButton];
    } else {
        UISlider *slider = [[UISlider alloc] initWithFrame:CGRectMake(5.0f, 120.0f, self.bounds.size.width - 10.0f, 100.0f)];
        [slider addTarget:self action:@selector(sliderAction:) forControlEvents:UIControlEventValueChanged];
        [slider setBackgroundColor:[UIColor clearColor]];
        [slider setTag:AMOUNT_SELECT_TAG];
        
        slider.minimumValue = 100.0f;
        slider.maximumValue = walletBalance;
        slider.continuous = YES;
        slider.value = ( walletBalance + 100.0f ) / 2;
        selectedWithdrawAmount = roundl(slider.value);
        [self addSubview:slider];
        
        withdrawSelectionLabel = [[UILabel alloc] initWithFrame:CGRectMake(5.0f, 100.0f, self.bounds.size.width - 10.0f, 20.0f)];
        [withdrawSelectionLabel setTextAlignment:NSTextAlignmentCenter];
        [withdrawSelectionLabel setFont:[UIFont boldSystemFontOfSize:17]];
        [withdrawSelectionLabel setTag:AMOUNT_SELECT_TAG];
        [self addSubview:withdrawSelectionLabel];
        [self updateSelectedAmountLabel];
        
        withdrawValueLabel = [[UILabel alloc] initWithFrame:CGRectMake(5.0f, 120.0f, self.bounds.size.width - 10.0f, 20.0f)];
        [withdrawValueLabel setTextAlignment:NSTextAlignmentCenter];
        [withdrawValueLabel setFont:[UIFont systemFontOfSize:14]];
        [withdrawValueLabel setTag:AMOUNT_SELECT_TAG];
        [self addSubview:withdrawValueLabel];
        [self updateWithdrawValueLabel];
    }
}

- (void)setupGenericFieldLayoutWithTag:(int)tag
{
    CGRect frame = self.frame;
    frame.size.height = 140.0f;
    frame.origin.y = ([UIScreen mainScreen].bounds.size.width / 2 - frame.size.height) / 2;
    [self setFrame:frame];
    UITextField *field;

    NSString *messageBody;
    NSString *placeHolderText;
    UILabel *message = [[UILabel alloc] initWithFrame:CGRectMake(5.0f, 10.0f, self.bounds.size.width - 10.0f, 20.0f)];
    
    if ( tag == NAME_FIELD_TAG ) {
        messageBody = [NSString stringWithFormat:@"Full legal name"];
        placeHolderText = [NSString stringWithFormat:@"Must match name on debit card"];
        self.nameField = [[UITextField alloc] initWithFrame:CGRectMake(20.0f, 40.0f, frame.size.width - 25.0f, 45.0f)];
        field = self.nameField;
    } else if ( tag == EMAIL_FIELD_TAG ) {
        messageBody = [NSString stringWithFormat:@"Email"];
        placeHolderText = [NSString stringWithFormat:@"Enter a valid email address" ];
        self.emailField = [[UITextField alloc] initWithFrame:CGRectMake(20.0f, 40.0f, frame.size.width - 25.0f, 45.0f)];
        field = self.emailField;
    }
    
    [message setText:messageBody];
    [message setFont:[UIFont boldSystemFontOfSize:17]];
    [message setTextAlignment:NSTextAlignmentCenter];
    [message setBackgroundColor:[UIColor clearColor]];
    [message setTag:tag];
    [self addSubview:message];
    
    [field setBackgroundColor:[UIColor clearColor]];
    [field setFont:[UIFont boldSystemFontOfSize:17]];
    [field setPlaceholder:placeHolderText];
    [field setAutocorrectionType:UITextAutocorrectionTypeNo];
    [field setKeyboardType:UIKeyboardTypeDefault];
    [field setReturnKeyType:UIReturnKeyDone];
    [field setClearButtonMode:UITextFieldViewModeWhileEditing];
    [field setContentVerticalAlignment:UIControlContentVerticalAlignmentCenter];
    [field setDelegate:self];
    [field setTag:tag];
    
    UIImageView *backgroundImageView = [[UIImageView alloc] initWithFrame:CGRectMake(5.0f, 40.0f, frame.size.width - 10.0f, 45.0f)];
    backgroundImageView.image = [[UIImage imageNamed:@"textfield"]
                                 resizableImageWithCapInsets:UIEdgeInsetsMake(0, 8, 0, 8)];
    [backgroundImageView setTag:tag];
    [self addSubview:backgroundImageView];
    [self addSubview:field];
    
    [field becomeFirstResponder];
}

- (void)setupCardFieldUI
{
    NSString *stripePublishableKey;
    float cardFieldWidth = 290.0f;
    
    if ( [[[arbiter game] objectForKey:@"is_live"] boolValue] == true ) {
        stripePublishableKey = StripeLivePublishableKey;
    } else {
        stripePublishableKey = StripeTestPublishableKey;
    }
    
    self.stripeView = [[STPView alloc] initWithFrame:CGRectMake((self.frame.size.width - cardFieldWidth) / 2, 40.0f,
                                                                self.frame.size.width, 40.0f)
                                              andKey:stripePublishableKey];
    self.stripeView.delegate = self;
    [self.stripeView setTag:CARD_INFO_TAG];
    [self addSubview:self.stripeView];
    
    UILabel *message = [[UILabel alloc] initWithFrame:CGRectMake(5.0f, 10.0f, self.bounds.size.width - 10.0f, 20.0f)];
    NSString *messageBody = [NSString stringWithFormat:@"Enter debit card info"];
    [message setText:messageBody];
    [message setFont:[UIFont boldSystemFontOfSize:17]];
    [message setTextAlignment:NSTextAlignmentCenter];
    [message setBackgroundColor:[UIColor clearColor]];
    [message setTag:CARD_INFO_TAG];
    [self addSubview:message];
}

- (void)renderNextButton:(BOOL)enabled
{
    self.nextButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [self.nextButton setFrame:CGRectMake(self.bounds.size.width / 2, self.bounds.size.height - 50, self.bounds.size.width / 2, 50)];
    [self.nextButton setTitle:@"Next" forState:UIControlStateNormal];
    [self.nextButton.titleLabel setFont:[UIFont boldSystemFontOfSize:17]];
    [self.nextButton addTarget:self action:@selector(nextButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self.nextButton setTag:NEXT_BUTTON_TAG];
    
    CALayer *topBorder = [CALayer layer];
    topBorder.frame = CGRectMake(0, 0, self.nextButton.frame.size.width, 0.5f);
    topBorder.backgroundColor = [[UIColor lightGrayColor] CGColor];
    [self.nextButton.layer addSublayer:topBorder];
    [self.nextButton setEnabled:enabled];
    [self addSubview:self.nextButton];
}

- (void)renderFullWidthCancelButton
{
    UIButton *button = [UIButton buttonWithType:UIButtonTypeSystem];
    [button setFrame:CGRectMake(0, self.bounds.size.height - 50, self.bounds.size.width, 50)];
    [button setTitle:@"Cancel" forState:UIControlStateNormal];
    [button setTag:AMOUNT_SELECT_TAG];
    [button.titleLabel setFont:[UIFont systemFontOfSize:17]];
    [button addTarget:self action:@selector(cancelButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    
    CALayer *topBorder = [CALayer layer];
    topBorder.frame = CGRectMake(0, 0, button.frame.size.width, 0.5f);
    topBorder.backgroundColor = [[UIColor lightGrayColor] CGColor];
    [button.layer addSublayer:topBorder];
    
    [self addSubview:button];
}

- (void)renderCancelButton
{
    UIButton *button = [UIButton buttonWithType:UIButtonTypeSystem];
    [button setFrame:CGRectMake(0, self.bounds.size.height - 50, self.bounds.size.width / 2, 50)];
    [button setTitle:@"Cancel" forState:UIControlStateNormal];
    [button setTag:AMOUNT_SELECT_TAG];
    [button.titleLabel setFont:[UIFont systemFontOfSize:17]];
    [button addTarget:self action:@selector(cancelButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    
    CALayer *topBorder = [CALayer layer];
    topBorder.frame = CGRectMake(0, 0, button.frame.size.width, 0.5f);
    topBorder.backgroundColor = [[UIColor lightGrayColor] CGColor];
    [button.layer addSublayer:topBorder];
    
    CALayer *rightBorder = [CALayer layer];
    rightBorder.frame = CGRectMake(button.frame.size.width - 0.5f, 0, 0.5f, button.frame.size.height);
    rightBorder.backgroundColor = [[UIColor lightGrayColor] CGColor];
    [button.layer addSublayer:rightBorder];
    
    
    [self addSubview:button];
}

- (void)hideNextButton
{
    for (UIView *view in [self subviews]) {
        if (view.tag == NEXT_BUTTON_TAG) {
            [view removeFromSuperview];
        }
    }
}

- (void)hideCancelButton
{
    for (UIView *view in [self subviews]) {
        if (view.tag == CANCEL_BUTTON_TAG) {
            [view removeFromSuperview];
        }
    }
}

- (void)hideNameFieldUI
{
    for (UIView *view in [self subviews]) {
        if (view.tag == NAME_FIELD_TAG) {
            [view removeFromSuperview];
        }
    }
}

- (void)hideAmountSelectUI
{
    for (UIView *view in [self subviews]) {
        if (view.tag == AMOUNT_SELECT_TAG) {
            [view removeFromSuperview];
        }
    }
}

- (void)hideEmailFieldUI
{
    for (UIView *view in [self subviews]) {
        if (view.tag == EMAIL_FIELD_TAG) {
            [view removeFromSuperview];
        }
    }
}


# pragma mark Event Handlers

- (void)cancelButtonClicked:(id)sender
{
    [self animateOut];
}

- (void)nextButtonClicked:(id)sender
{
    [self setupNextScreen];
}

- (void)getTokenAndSubmitWithdraw
{
    [self.stripeView createToken:^(STPToken *token, NSError *error) {
        if (error) {
            [self handleError:[error localizedDescription]];
        } else {
            responseHandler = [^(NSDictionary *responseDict) {
                if ([[responseDict objectForKey:@"errors"] count]) {
                    [self handleError:[[responseDict objectForKey:@"errors"] objectAtIndex:0]];
                } else {
                    callback();
                }
            } copy];
            
            NSDictionary *params = @{@"card_token": token.tokenId,
                                     @"card_name": [NSString stringWithFormat:@"%@", self.nameField.text],
                                     @"amount": [NSString stringWithFormat:@"%.0f", selectedWithdrawAmount]};

            [arbiter httpPost:APIWithdrawURL params:params handler:responseHandler];
        }
    }];
}

- (void)sliderAction:(id)sender
{
    UISlider *slider = (UISlider*)sender;
    int rounded = roundl(slider.value);
    selectedWithdrawAmount = rounded;
    [self updateSelectedAmountLabel];
    [self updateWithdrawValueLabel];
    [slider setValue:(float)rounded];
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


#pragma mark Stripe View Delegate Methods

- (void)stripeView:(STPView *)view withCard:(PKCard *)card isValid:(BOOL)valid
{
    self.nextButton.enabled = true;
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


# pragma mark Helpers

- (void)updateSelectedAmountLabel
{
    [withdrawSelectionLabel setText:[NSString stringWithFormat:@"%.0f credits", selectedWithdrawAmount]];
}

- (void)updateWithdrawValueLabel
{
    [withdrawValueLabel setText:[NSString stringWithFormat:@"$%.02f", selectedWithdrawAmount / 100.0f]];
}

@end
