using UnityEngine;
using UnityEngine.SocialPlatforms;
using System;
using System.Collections;
using System.Collections.Generic;



public class RejectScoreChallengeBtn : MonoBehaviour {
	
	private ScoreChallenge challenge;
	
	void Awake() {
		challenge = GameObject.Find( "ScoreChallenge" ).GetComponent<ScoreChallenge>();
	}
	
	void OnMouseUpAsButton() {
		Arbiter.RejectScoreChallenge( challenge.ChallengeId, Callback );
	}
	
	void Callback() {
		Application.LoadLevel( "SecondScene" );
	}
	
}