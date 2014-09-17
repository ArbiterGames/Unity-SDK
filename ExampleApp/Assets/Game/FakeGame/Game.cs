using UnityEngine;
using UnityEngine.SocialPlatforms;
using System;
using System.Collections;
using System.Collections.Generic;
using System.Linq;



public class Game : MonoBehaviour {
	
    public const string BET_SIZE = "100";
    public int Score;
    public string Problems = "---";
    public string TournamentId = "???";
    public string ResultsDescription = "???";
    
    private Arbiter arbiter;


	void Start() {
		GameObject arbiterGO = GameObject.Find( "Arbiter" );
		arbiter = arbiterGO.GetComponent<Arbiter>();
		
        if( float.Parse( Arbiter.Balance ) < float.Parse( BET_SIZE )) {
            Problems = "You need to deposit more money first.";
        } else {
			if( arbiter.SelectedUnfinishedTournamentId == null || arbiter.SelectedUnfinishedTournamentId == "" ) {
				GetTournament();
			} else {
				PlayGame();
			}
        }
    }

    private void GetTournament() {
        Dictionary<string,string> filters = new Dictionary<string,string>();
        filters.Add( "arbitrary_key", "the_value" );
        Arbiter.JoinTournament( BET_SIZE, filters, OnTournamentReturned, OnFailure );
    }

	private void OnTournamentReturned( Arbiter.Tournament tournament ) {
		arbiter.SelectedUnfinishedTournamentId = TournamentId = tournament.Id;
        PlayGame();
    }

    private void PlayGame() {
        Score = (int)UnityEngine.Random.Range( 1f, 100f );
        ReportScore();
    }


    private void ReportScore() {
		TournamentId = arbiter.SelectedUnfinishedTournamentId;
		arbiter.SelectedUnfinishedTournamentId = null;
        Arbiter.ReportScore( TournamentId, Score, DisplayResults );
    }


    private void DisplayResults( Arbiter.Tournament tournament ) {
        if( tournament.Status == Arbiter.Tournament.StatusType.Complete ) {
			if ( tournament.Winners != null ) {
				if ( tournament.Winners.First() == Arbiter.UserId ) {
					if ( tournament.Winners.Count() > 1 ) {
						ResultsDescription = "You tied!";
					} else {
						ResultsDescription = "You Won!";
					}
				} else {
					ResultsDescription = "You lost to user " + tournament.Winners.First();
	        	}
			}
		} else if( tournament.Status == Arbiter.Tournament.StatusType.InProgress || tournament.Status == Arbiter.Tournament.StatusType.Initializing ) {
            ResultsDescription = "Waiting for opponent";
        } else {
            Debug.LogError( "Found unexpected game status code ("+tournament.Status+")!" );
        }
    }


	private void OnFailure( List<string> errors ) {
		errors.ForEach( error => Debug.LogError( error ));
		Problems = errors[0];
	}

}