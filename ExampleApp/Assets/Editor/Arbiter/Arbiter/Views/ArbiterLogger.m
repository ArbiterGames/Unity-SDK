#import "ARbiterLogger.h"
#import "Arbiter.h"


@implementation ArbiterLogger
{

}

-(NSMutableDictionary*) startDump:(NSMutableDictionary*)data
{
	NSLog(@"TODO: Add stuff about system/platform as able");
    return data;
}

-(void) finishDump:(NSMutableDictionary*)data
{
	NSLog(@"TODO: send this data somewhere. data=\n%@", data);
	// TODO: Also free the dictionary
}


@end