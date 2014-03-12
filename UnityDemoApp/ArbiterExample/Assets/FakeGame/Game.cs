using UnityEngine;
using UnityEngine.SocialPlatforms;
using System;
using System.Collections;
using System.Collections.Generic;



public class Game : MonoBehaviour {
	

    public int Score;
    public string CompetitionId = "???";
    public string ResultsDescription = "???";


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
            CompetitionId = openCompetition.Id;
            break;
        }
        if( openCompetition != null ) {
            Debug.LogError("ttt found an open competition!");
            PlayGame();
        }
    }


    private void PlayGame() {
        Score = (int)UnityEngine.Random.Range( 0f, 100f );
        ReportScore();
    }


    private void ReportScore() {
        Arbiter.ReportScore( CompetitionId, Score, DisplayResults );
    }


    private void DisplayResults( Arbiter.Competition competition ) {
        if( competition.Status == Arbiter.Competition.StatusType.Complete ) {
            if( competition.Winner.User.Id == Arbiter.UserId ) {
                ResultsDescription = "You Won!";
            } else {
                ResultsDescription = "You lost to player "+competition.Winner.User.Id;
            }
        } else if( competition.Status == Arbiter.Competition.StatusType.InProgress ) {
            ResultsDescription = "Waiting for opponent";
            ResetPolling();
        } else {
            Debug.LogError( "Found unexpected game status code ("+competition.Status+")!" );
        }

    }

    
    private void ResetPolling() {
        openGamePoller.Reset();
    }


    private Poller openGamePoller;
}