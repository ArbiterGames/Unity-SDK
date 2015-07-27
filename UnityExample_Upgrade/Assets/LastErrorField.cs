using UnityEngine;
using System.Collections;
using System.Collections.Generic;


public class LastErrorField : DynamicTextField {

	void Start() {
		instance = this;
		Initialize();
	}


	public static void ShowGlobalError( List<string> messages ) {
		if( messages != null && messages.Count > 0 ) {
			Debug.Log (messages[0]);
			ShowGlobalError( messages[0] );
		}
	}


	public static void ShowGlobalError( string message ) {
		if( instance != null && instance.gameObject != null ) {
			instance.SetText( message );
		}
	}


	static LastErrorField instance;
}
