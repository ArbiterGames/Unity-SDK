using UnityEngine;
using UnityEngine.SocialPlatforms;
using System;
using System.Collections;
using System.Collections.Generic;



public class Game : MonoBehaviour {
	

    public const string BET_SIZE = "1";
    public int Score;
    public string Problems = "---";
    public string TournamentId = "???";
    public string ResultsDescription = "???";
    
    private Globals globals;


	void Start() {
		GameObject globalsGO = GameObject.Find ("Globals");
		globals = globalsGO.GetComponent<Globals>();

        if( float.Parse( Arbiter.Balance ) < float.Parse( BET_SIZE )) {
            Problems = "You need to deposit more money first.";
        } else {
			if ( globals.SelectedUnfinishedTournamentId == null || globals.SelectedUnfinishedTournamentId == "" ) {
				GetTournament();
			} else {
				PlayGame();
			}
        }
    }

    private void GetTournament() {
        Dictionary<string,string> filters = new Dictionary<string,string>();
        filters.Add( "arbitrary_key", "the_value" );
        Arbiter.GetTournament( BET_SIZE, filters, OnTournamentReturned );
    }

	private void OnTournamentReturned( Arbiter.Tournament tournament ) {
		globals.SelectedUnfinishedTournamentId = TournamentId = tournament.Id;
        PlayGame();
    }

    private void PlayGame() {
        Score = (int)UnityEngine.Random.Range( 1f, 100f );
        ReportScore();
    }


    private void ReportScore() {
		TournamentId = globals.SelectedUnfinishedTournamentId;
		globals.SelectedUnfinishedTournamentId = null;
        Arbiter.ReportScore( TournamentId, Score, DisplayResults );
    }


    private void DisplayResults( Arbiter.Tournament tournament ) {
        if( tournament.Status == Arbiter.Tournament.StatusType.Complete ) {
            if( tournament.Winner.Id == Arbiter.UserId ) {
                ResultsDescription = "You Won!";
            } else {
                ResultsDescription = "You lost to user "+tournament.Winner.Id;
            }
		} else if( tournament.Status == Arbiter.Tournament.StatusType.InProgress || tournament.Status == Arbiter.Tournament.StatusType.Initializing ) {
            ResultsDescription = "Waiting for opponent";
        } else {
            Debug.LogError( "Found unexpected game status code ("+tournament.Status+")!" );
        }
    }


}