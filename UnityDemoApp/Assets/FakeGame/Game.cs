using UnityEngine;
using UnityEngine.SocialPlatforms;
using System;
using System.Collections;
using System.Collections.Generic;



public class Game : MonoBehaviour {
	

    public const string BET_SIZE = "1";
    public int Score;
    public string Problems = "---";
    public string CompetitionId = "???";
    public string ResultsDescription = "???";
    
    private Globals globals;


	void Start() {
		GameObject globalsGO = GameObject.Find ("Globals");
		globals = globalsGO.GetComponent<Globals>();

        if( float.Parse( Arbiter.Balance ) < float.Parse( BET_SIZE )) {
            Problems = "You need to deposit more money first.";
        } else {
            if ( globals.SelectedUnfinishedCompetitionId == null || globals.SelectedUnfinishedCompetitionId == "" ) {
				GetCompetition();
			} else {
				PlayGame();
			}
        }
    }


    private void GetCompetition() {
        Dictionary<string,string> filters = new Dictionary<string,string>();
        filters.Add( "arbitrary_key", "the_value" );
        Arbiter.GetScorableCompetition( BET_SIZE, filters, OnCompetitionFound );
    }


    private void OnCompetitionFound( Arbiter.Competition competition ) {
        globals.SelectedUnfinishedCompetitionId = CompetitionId = competition.Id;
        PlayGame();
    }


    private void PlayGame() {
        Score = (int)UnityEngine.Random.Range( 1f, 100f );
        ReportScore();
    }


    private void ReportScore() {
		CompetitionId = globals.SelectedUnfinishedCompetitionId;
		globals.SelectedUnfinishedCompetitionId = null;
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