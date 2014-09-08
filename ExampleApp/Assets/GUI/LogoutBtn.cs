using UnityEngine;
using System.Collections;
using System.Collections.Generic;



public class LogoutBtn : MonoBehaviour {
	
	void OnMouseUpAsButton() {
		Arbiter.Logout( LogoutCallback, ErrorCallback );
    }
    
    void LogoutCallback() {
    	Application.LoadLevel("StartupScene");
    }

	void ErrorCallback( List<string> errors ) {
		errors.ForEach( error => Debug.Log( error ));
	}

}