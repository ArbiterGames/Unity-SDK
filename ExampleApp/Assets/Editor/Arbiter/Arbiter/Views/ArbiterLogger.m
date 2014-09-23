#import "ARbiterLogger.h"
#import "Arbiter.h"


@implementation ArbiterLogger
{

}

-(NSMutableDictionary*) startDump:(NSMutableDictionary*)data
{
	NSLog(@"ttt start dump");
    return data;
}

-(void) finishDump:(NSMutableDictionary*)data
{
	NSLog(@"ttt send this data somewhere. data=\n%@", data);
}


@end