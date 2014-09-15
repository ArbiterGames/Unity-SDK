//ttt #import "Arbiter.h"


@protocol ArbiterWalletObserver

// ttt need?
//@property (strong) Arbiter *arbiter;

- (void)onWalletUpdated:(NSMutableDictionary *)wallet; // ttt use NSDictionary instead??

@end

@interface ArbiterWalletObserverTemp
@end