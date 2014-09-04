using UnityEngine;
using System;
using System.Collections;
using System.Collections.Generic;



[RequireComponent (typeof (GUIText))]
public class UserIdPoller : MonoBehaviour {
	

    void Start() {
        textField = gameObject.GetComponent<GUIText>();
    }
    private GUIText textField;


	void OnGUI () {
		if( Arbiter.IsAuthenticated )
        	textField.text = Arbiter.UserId;
		else
			textField.text = "<log in first>";
    }


}