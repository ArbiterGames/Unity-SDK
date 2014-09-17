using UnityEngine;
using System;
using System.Collections;
using System.Collections.Generic;



[RequireComponent (typeof (GUIText))]
public class BalancePoller : MonoBehaviour {
	

    void Start() {
        textField = gameObject.GetComponent<GUIText>();
    }
    private GUIText textField;


	void OnGUI () {
		if( Arbiter.HasWallet )
			textField.text = Arbiter.FormattedBalance();
    }


}