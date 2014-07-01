using UnityEngine;
using System;
using System.Collections;
using System.Collections.Generic;



[RequireComponent (typeof (GUIText))]
public class PlayFakeGameBestSizeLabel : MonoBehaviour {
	
	
	void Start() {
		GUIText textField = gameObject.GetComponent<GUIText>();
		textField.text = "(Bet Size: " + Game.BET_SIZE + ")";
	}

	
}