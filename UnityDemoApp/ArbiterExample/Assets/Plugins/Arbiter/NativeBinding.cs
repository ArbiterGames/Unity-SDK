using UnityEngine;
using System.Collections;
using System.Runtime.InteropServices;

public class NativeBinding {

	static NativeBinding() {
		//tttDebug.LogError("ttt make a GO here!");
	}

	public static void Foo() {
#if UNITY_IOS && !UNITY_EDITOR
		foo("Hi from Unity");
#else
		Debug.Log( "Call was made to native function. Has no effect in editor." );
#endif
	}
	
	
	[DllImport ("__Internal")]
	private static extern float foo(string msg);
	
}
