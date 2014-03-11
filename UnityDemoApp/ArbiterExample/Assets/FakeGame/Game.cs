using UnityEngine;
using UnityEngine.SocialPlatforms;
using System;
using System.Collections;
using System.Collections.Generic;



public class Game : MonoBehaviour {
	

    public int Score;


	void Start() {
        GameObject go = new GameObject();
        go.name = "Fake Game Competition Poller";
        openGamePoller = go.AddComponent<Poller>();

        Arbiter.SetGameName( "iOS SDK Example App" );
        RequestCompetition();
    }


    private void RequestCompetition() {
        string buyIn = "0.0001";
        Dictionary<string,string> filters = new Dictionary<string,string>();
        filters.Add( "arbitrary_key", "the_value" );
        Arbiter.RequestCompetition( buyIn, filters, PollForOpenGames );
    }


    private void PollForOpenGames() {
        openGamePoller.SetAction( ( callback ) => {
            Arbiter.QueryCompetitions( UpdateCompetitionInfo );
        });
    }

    private void UpdateCompetitionInfo() {
        // Keep polling until an open competition is found
        List<Arbiter.Competition> competitions = Arbiter.OpenCompetitions;
        Arbiter.Competition openCompetition = null;
        foreach( var competition in competitions ) {
            openCompetition = competition;
            break;
        }
        if( openCompetition != null ) {
            Debug.LogError("ttt found an open competition!");
            PlayGame( openCompetition.Id );
        }
    }


    private void PlayGame( string competitionId ) {
        Score = (int)UnityEngine.Random.Range( 0f, 100f );
        ReportScore( competitionId );
    }


    private void ReportScore( string competitionId ) {
        // TODO: Call to report score!
        // ... and set this as the callback: ResetPolling();
    }

    
    private void ResetPolling() {
        Debug.LogWarning("ttt Start polling for results??");
        // TODO: Start polling for the previous game states
    }


    private Poller openGamePoller;
}