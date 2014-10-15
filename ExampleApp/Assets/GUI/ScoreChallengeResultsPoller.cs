﻿using UnityEngine;
using System;
using System.Collections;
using System.Collections.Generic;



[RequireComponent (typeof (GUIText))]
public class ScoreChallengeResultsPoller : MonoBehaviour {
	
	
	void Awake() {
		textField = gameObject.GetComponent<GUIText>();
		challenge = GameObject.Find( "ScoreChallenge" ).GetComponent<ScoreChallenge>();
	}
	private GUIText textField;
	private ScoreChallenge challenge;
	
	
	void OnGUI() {
		textField.text = challenge.ResultsDescription;
	}
	
	
}