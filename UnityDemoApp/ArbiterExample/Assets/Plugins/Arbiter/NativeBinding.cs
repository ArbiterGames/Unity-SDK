using UnityEngine;
using System.Collections;
using System.Runtime.InteropServices;

public class NativeBinding : MonoBehaviour {

	static NativeBinding() {
		GameObject go = new GameObject( "ArbiterBinding" );
		go.AddComponent< NativeBinding >();
		GameObject.DontDestroyOnLoad( go );
	}

	public void ReceiveMessage( string msg ){
		Debug.Log( "===== Received message from iOS =====" );
		Debug.Log( msg );
	}

	public static void Foo() {
#if UNITY_IOS && !UNITY_EDITOR
		foo("Hi from Unity");
#else
		Debug.Log( "Call was made to native function. Has no effect in editor." );
#endif
	}
	
	
	[DllImport ("__Internal")]
	private static extern float foo( string msg );
	
}
