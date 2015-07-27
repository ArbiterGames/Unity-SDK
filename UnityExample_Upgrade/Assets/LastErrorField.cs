using UnityEngine;
using System.Collections;
using System.Collections.Generic;


public class LastErrorField : DynamicTextField {

	void Start() {
		instance = this;
	}


	public static void ShowGlobalError( List<string> messages ) {
		Debug.Log ("ttt in ShowGlobalError");
		Debug.Log (messages);
		if( messages != null && messages.Count > 0 ) {
			Debug.Log ("ttt in Check 1");
			Debug.Log (messages[0]);
			ShowGlobalError( messages[0] );
		}
	}


	public static void ShowGlobalError( string message ) {
		Debug.Log ("ttt in Check 2");
		if( instance != null && instance.gameObject != null ) {
			Debug.Log ("ttt in Check 3");
			instance.SetText( message );
		}
	}


	static LastErrorField instance;
}
