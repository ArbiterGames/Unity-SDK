using UnityEngine;
using System;
using System.Collections;
using System.Collections.Generic;



[RequireComponent (typeof (GUIText))]
public class ScoreChallengeProblemsPoller : MonoBehaviour {
	
	
	void Start() {
		challenge = GameObject.Find( "ScoreChallenge" ).GetComponent<ScoreChallenge>();
		textField = gameObject.GetComponent<GUIText>();
	}
	private ScoreChallenge challenge;
	private GUIText textField;
	
	
	void Update () {
		if( challenge.Problems != null )
			textField.text = challenge.Problems;
	}
	
	
}