//#import "SimpleC.h"

//extern "C" {
	void _SimpleCFunction() {
		UnitySendMessage(
			"TestNativeReceiver", 
			"SimpleUnityFunction", 
			"MessageParam");
	}
//}