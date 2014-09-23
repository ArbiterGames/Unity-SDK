@protocol Loggable

-(void) addLogs:(NSMutableDictionary*)data;

@end


@interface ArbiterLogger : NSObject

-(NSMutableDictionary*) startDump:(NSMutableDictionary*)data;
-(void) finishDump:(NSMutableDictionary*)data;

@end