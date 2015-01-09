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
    
    self.spinnerView = [[UIActivityIndicatorView alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.spinnerView.activityIndicatorViewStyle = UIActivityIndicatorViewStyleWhiteLarge;
    self.spinnerView.backgroundColor = [UIColor clearColor];

    [request setURL:[NSURL URLWithString:APIWalletDashboardWebViewURL]];
    [request setHTTPMethod:@"POST"];
    [request setHTTPBody:postData];

    webview.opaque = NO;
    webview.backgroundColor = [UIColor clearColor];
    webview.delegate = self;
    [webview loadRequest:request];
    [self addSubview:webview];
    
    [self.spinnerView setFrame:self.bounds];
    [self addSubview:self.spinnerView];
    [self.spinnerView startAnimating];
    
    // Calling the super messes up the position since this is the only full screen ARBPanelView subclass
    // [super renderLayout];
}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    NSString *url = [[request URL] absoluteString];
    if ([url hasPrefix:@"ios:"]) {
        [self performSelector:@selector(backButtonClicked)];
        return NO;
    } else if ( [url rangeOfString:@"support.arbiter"].location != NSNotFound ) {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:url]];
        return NO;
    }
    return YES;
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    [self.spinnerView stopAnimating];
    [self.spinnerView removeFromSuperview];
}

- (void)backButtonClicked
{
    if ( self.callback ) {
        [self callback];
    }
    [self.parentWindow hide];
}



@end
