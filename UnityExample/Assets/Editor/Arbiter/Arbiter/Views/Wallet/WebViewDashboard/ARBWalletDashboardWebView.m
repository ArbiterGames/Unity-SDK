//
//  ARBWalletDashboardWebView.m
//  Unity-iPhone
//
//  Created by Andy Zinsser on 12/16/14.
//
//

#import "ARBWalletDashboardWebView.h"
#import "ARBConstants.h"

@implementation ARBWalletDashboardWebView

- (void)renderLayout
{
    CGRect screenFrame = [[UIApplication sharedApplication] keyWindow].frame;
    [self setFrame:screenFrame];
    UIWebView *webview = [[UIWebView alloc]initWithFrame:screenFrame];
    NSString *postString = [NSString stringWithFormat:@"token=%@&gameApiKey=%@", [self.arbiter.user objectForKey:@"token"], self.arbiter.apiKey];
    NSData *postData = [postString dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:YES];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    [request setURL:[NSURL URLWithString:APIWalletDashboardWebViewURL]];
    [request setHTTPMethod:@"POST"];
    [request setHTTPBody:postData];
    webview.opaque = NO;
    webview.backgroundColor = [UIColor clearColor];
    [webview loadRequest:request];
    [self addSubview:webview];
    
    // This renders an invisible button in the top right corner of the dashboard ontop of the webview
    // The button assets are actually being rendered in the HTML of the webview
    UIButton *backButton = [UIButton buttonWithType:UIButtonTypeSystem];
    float btnWidth = 100.0;
    float btnHeight = 100.0;
    [backButton setFrame:CGRectMake(0.0, 5.0, btnWidth, btnHeight)];
    [backButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [backButton addTarget:self action:@selector(backButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    backButton.titleLabel.textAlignment = NSTextAlignmentLeft;
    backButton.titleLabel.font = [UIFont boldSystemFontOfSize:17.0];
    [self addSubview:backButton];

    // Calling the super messes up the position since this is the only full screen ARBPanelView subclass
    // [super renderLayout];
}

- (void)backButtonClicked:(id)sender
{
    if ( self.callback ) {
        [self callback];
    }
    [self.parentWindow hide];
}


# pragma mark NSNotification Handlers -- Overrides the ARBPanelViewHandlers

- (void)keyboardDidShow:(NSNotification *)notification
{
    // No-op
}

- (void)keyboardDidHide:(NSNotification *)notification
{
    // No-op
}



@end
