using UnityEngine;
using UnityEngine.SocialPlatforms;
using System;
using System.Collections;
using System.Collections.Generic;
using System.Linq;


public class ScoreChallengeController : MonoBehaviour {
	
	public const string ENTRY_FEE = "100";
	public string ScoreToBeat;
	public string Score;
	public string Problems = "---";
	public string ChallengeId = "???";
	public string ResultsDescription = "???";
	
	private Arbiter arbiter;
	
	void Start () {
		GameObject arbiterGO = GameObject.Find( "Arbiter" );
		arbiter = arbiterGO.GetComponent<Arbiter>();
		
		if( float.Parse( Arbiter.Balance ) < float.Parse( ENTRY_FEE )) {
			Problems = "You need to deposit more money first.";
		} else {
			Arbiter.RequestScoreChallenge( ENTRY_FEE, OnChallengeCreated, OnError );
		}
	}
	
	void OnChallengeCreated( Arbiter.ScoreChallenge challenge ) {
		ChallengeId = challenge.Id;
		ScoreToBeat = challenge.ScoreToBeat;
	}
	
	public void PlayGame() {
		int intScore = (int)UnityEngine.Random.Range( 1f, 100f );
		Score = intScore.ToString();
		Arbiter.ReportScoreForChallenge( ChallengeId, Score, DisplayResults, OnError );
	}
	
	private void DisplayResults( Arbiter.ScoreChallenge challenge ) {
		if ( challenge.Status == Arbiter.ScoreChallenge.StatusType.Closed ) {
			if ( challenge.Winner != null ) {
				if ( challenge.Winner.Id == Arbiter.UserId ) {
					ResultsDescription = "You Won!";
				} else {
					ResultsDescription = "You lost";
				}
			}
		} else if ( challenge.Status == Arbiter.ScoreChallenge.StatusType.Open || challenge.Status == Arbiter.ScoreChallenge.StatusType.Busy ) {
			ResultsDescription = "You probably lost";
		} else {
			Debug.LogError( "Found unexpected status code ("+challenge.Status+")!" );
		}
	}
	
	
	void OnError( List<string> errors, List<string> descriptions ) {
		string msg = "";
		errors.ForEach( error => msg += error + "\n" );
		Debug.Log ("Error requesting score challenge: " + msg);
	}
	
}
