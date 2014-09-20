@protocol Loggable

-(void) addLogs:(NSMutableDictionary*)data;

@end


@interface ArbiterLogger : NSObject

-(NSMutableDictionary*) startDump;
-(void) finishDump:(NSMutableDictionary*)data;

@end