

#import <GameKit/GameKit.h>

@implementation Test

extern "C" {
    void foo(char* msg) {
        NSLog(@"=====Call made to foo=====");
        NSLog(@"%s", msg);

        UnitySendMessage("ArbiterBinding", "ReceiveMessage", "Hi from iOS!");
    }
}

@end