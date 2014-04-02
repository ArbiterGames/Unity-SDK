using UnityEngine;
using UnityEngine.SocialPlatforms;
using System;
using System.Collections;
using System.Collections.Generic;



public class Game : MonoBehaviour {
	

    public const string BET_SIZE = "0";//ttt"0.0001";
    public int Score;
    public string Problems = "---";
    public string CompetitionId = "???";
    public string ResultsDescription = "???";


	void Start() {
        Arbiter.SetGameName( "iOS SDK Example App" );
        if( float.Parse( Arbiter.Balance ) < float.Parse( BET_SIZE )) {
            Problems = "You need to deposit more bitcoin first.";
        } else {
           JoinCompetition();
        }
    }


    private void JoinCompetition() {
        Dictionary<string,string> filters = new Dictionary<string,string>();
        filters.Add( "arbitrary_key", "the_value" );
        Arbiter.JoinAvailableCompetition( BET_SIZE, filters, OnCompetitionJoined );
    }


    private void OnCompetitionJoined( Arbiter.Competition competition ) {
        CompetitionId = competition.Id;
        PlayGame();
    }


    private void PlayGame() {
        Score = (int)UnityEngine.Random.Range( 1f, 100f );
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
		} else if( competition.Status == Arbiter.Competition.StatusType.InProgress || competition.Status == Arbiter.Competition.StatusType.Initializing ) {
            ResultsDescription = "Waiting for opponent";
        } else {
            Debug.LogError( "Found unexpected game status code ("+competition.Status+")!" );
        }
    }
}