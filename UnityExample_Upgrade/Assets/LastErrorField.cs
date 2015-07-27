using UnityEngine;
using System.Collections;
using System.Collections.Generic;


public class LastErrorField : DynamicTextField {

	void Start() {
		instance = this;
	}


	public static void ShowGlobalError( List<string> messages ) {
		Debug.Log ("ttt in ShowGlobalError");
		if( messages != null && messages.Count > 0 ) {
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
