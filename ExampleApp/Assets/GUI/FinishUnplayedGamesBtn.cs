using UnityEngine;
using UnityEngine.SocialPlatforms;
using System;
using System.Collections;
using System.Collections.Generic;

public class FinishUnplayedGamesBtn : MonoBehaviour {
	
	void OnMouseUpAsButton() {
		Arbiter.ShowIncompleteTournaments( PlayUnfinishedGame );
	}
	
	void PlayUnfinishedGame( string tournamentId ) {
		if ( tournamentId != "" ) {
			GameObject arbiterGO = GameObject.Find ("Arbiter");
			Arbiter arbiter = arbiterGO.GetComponent<Arbiter>();
			arbiter.SelectedUnfinishedTournamentId = tournamentId;
			Application.LoadLevel( "FakeGameScene.cs" );
		}
	}	
}