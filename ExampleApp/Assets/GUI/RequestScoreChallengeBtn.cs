using UnityEngine;
using UnityEngine.SocialPlatforms;
using System;
using System.Collections;
using System.Collections.Generic;



public class RequestScoreChallengeBtn : MonoBehaviour {
	
	void OnMouseUpAsButton() {
		Debug.Log("Request Score Challenge");
		string ENTRY_FEE = "100";
		Arbiter.RequestScoreChallenge( ENTRY_FEE, OnSuccess, OnError);
	}
	
	void OnSuccess() {
		Debug.Log ("Score Challenge Successfull");
	}
	
	void OnError( List<string> errors, List<string> descriptions ) {
		string msg = "";
		errors.ForEach( error => msg += error + "\n" );
		Debug.Log ("Error requesting score challenge: " + msg);
	}
	
}
