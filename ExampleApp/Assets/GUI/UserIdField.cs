using UnityEngine;
using System;
using System.Collections;
using System.Collections.Generic;



[RequireComponent (typeof (GUIText))]
public class UserIdField : MonoBehaviour {
	

    void Start() {
        textField = gameObject.GetComponent<GUIText>();
		textField.text = "<log in first>";
		if( Arbiter.IsAuthenticated )
			UpdateField();

		Arbiter.AddNewUserListener( UpdateField );
    }
    private GUIText textField;


	void UpdateField () {
        textField.text = Arbiter.UserId;
    }


}