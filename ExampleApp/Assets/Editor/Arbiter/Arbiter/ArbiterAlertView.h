//
//  ArbiterAlertView.h
//  Unity-iPhone
//
//  Created by Andy Zinsser on 8/8/14.
//
//

#import <UIKit/UIKit.h>
#import "Arbiter.h"

@interface ArbiterAlertView : UIView <NSURLConnectionDataDelegate>

@property (assign) Arbiter *arbiter;
@property (assign) NSMutableData *responseData;
@property (assign) void(^responseHandler)(NSDictionary *responseDict);
@property (assign) void(^callback)(void);

- (id)initWithCallback:(void(^)(void))callback arbiterInstance:(Arbiter *)arbiterInstance;
- (void)setupNextScreen;
- (void)animateIn;
- (void)animateOut;
- (void)cancelButtonClicked:(id)sender;
- (void)setMaxHeight:(float)maxHeight;
- (NSString *)addThousandsSeparatorToString:(NSString *)original;

@end
