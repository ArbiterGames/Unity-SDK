using UnityEngine;
using UnityEngine.SocialPlatforms;
using System;
using System.Collections;
using System.Collections.Generic;



public class Game : MonoBehaviour {
	

    public int Score;


	void Start() {
        RequestCompetition();
    }


    private void RequestCompetition() {
        string buyIn = "0.0001";
        Dictionary<string,string> filters = new Dictionary<string,string>();
        filters.Add( "arbitrary_key", "the_value" );
        Arbiter.RequestCompetition( buyIn, filters, ResetPolling );
    }


    private void ResetPolling() {
        // TODO: Start polling for the previous game states
    }


    private void PlayGame() {
        Score = (int)UnityEngine.Random.Range( 0f, 100f );

    }


}