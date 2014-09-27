using UnityEngine;
using UnityEngine.SocialPlatforms;
using System;
using System.Collections;
using System.Collections.Generic;



public class AcceptScoreChallengeBtn : MonoBehaviour {

	private ScoreChallenge challenge;
	
	void Awake() {
		challenge = GameObject.Find( "ScoreChallenge" ).GetComponent<ScoreChallenge>();
	}
	
	void OnMouseUpAsButton() {
		Arbiter.AcceptScoreChallenge( challenge.ChallengeId, OnSuccess, OnError );
	}
	
	void OnSuccess() {
		challenge.PlayGame();
	}
	
	void OnError( List<string> errors ) {
		string msg = "";
		errors.ForEach( error => msg += error + "\n" );
		Debug.Log ("Errors accepting: " + msg);
	}
	
}