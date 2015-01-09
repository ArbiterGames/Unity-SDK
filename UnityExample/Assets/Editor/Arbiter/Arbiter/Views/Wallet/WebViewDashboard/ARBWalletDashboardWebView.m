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
    webview.delegate = self;
    [webview loadRequest:request];
    [self addSubview:webview];
    
    // Calling the super messes up the position since this is the only full screen ARBPanelView subclass
    // [super renderLayout];
}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    
    NSLog(@"navigating to: %@", [[request URL] absoluteString]);
    if ([[[request URL] absoluteString] hasPrefix:@"ios:"]) {
        [self performSelector:@selector(backButtonClicked)];
    } else {
        // TODO: Open any other links in safari
    }
    return YES;
}

- (void)backButtonClicked
{
    if ( self.callback ) {
        [self callback];
    }
    [self.parentWindow hide];
}



@end
