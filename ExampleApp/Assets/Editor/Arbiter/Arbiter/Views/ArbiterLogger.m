#import "ARbiterLogger.h"
#import "Arbiter.h"


@implementation ArbiterLogger
{

}

-(NSMutableDictionary*) startDump
{
	NSLog(@"ttt start dump");
    NSMutableDictionary* data = [[NSMutableDictionary alloc] init];
    return data;
}

-(void) finishDump:(NSMutableDictionary*)data
{
	NSLog(@"ttt add some data");
}


@end