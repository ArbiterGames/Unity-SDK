using UnityEngine;
using UnityEngine.SocialPlatforms;
using System;
using System.Collections;
using System.Collections.Generic;



public class Game : MonoBehaviour {
	

    public int Score;


	void Start() {
        Arbiter.SetGameName( "iOS SDK Example App" );
        RequestCompetition();
    }


    private void RequestCompetition() {
        string buyIn = "0.0001";
        Dictionary<string,string> filters = new Dictionary<string,string>();
        filters.Add( "arbitrary_key", "the_value" );
        Arbiter.RequestCompetition( buyIn, filters, PlayGame );
    }


    private void PlayGame() {
        Score = (int)UnityEngine.Random.Range( 0f, 100f );
        ReportScore();
    }


    private void ReportScore() {
        // TODO: Call to report score!
        // ... and set this as the callback: ResetPolling();
    }

    
    private void ResetPolling() {
        Debug.LogWarning("ttt Start polling for results??");
        // TODO: Start polling for the previous game states
    }
}