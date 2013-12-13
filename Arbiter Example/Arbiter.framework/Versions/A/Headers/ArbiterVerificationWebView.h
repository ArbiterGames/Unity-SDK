//
//  ArbiterVerificationWebView.h
//  Arbiter
//
//  Created by Andy Zinsser on 12/6/13.
//  Copyright (c) 2013 Arbiter. All rights reserved.
//

#import "WebViewJavascriptBridge.h"


@interface ArbiterVerificationWebView : UIViewController <UIWebViewDelegate>
{
    void (^_completionHandler)(NSString *param);
}

@property (strong, nonatomic) WebViewJavascriptBridge *javascriptBridge;
@property (strong, nonatomic) NSString* verificationURL;

- (id)initWithVerificationURL:(NSString *) verificationURL callback:(void(^)(NSString *)) handler;
- (void)closeWithSuccess:(NSString *) success;

@end
