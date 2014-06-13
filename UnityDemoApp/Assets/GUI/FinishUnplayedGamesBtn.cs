using UnityEngine;
using UnityEngine.SocialPlatforms;
using System;
using System.Collections;
using System.Collections.Generic;

public class FinishUnplayedGamesBtn : MonoBehaviour {
	
	void OnMouseUpAsButton() {
		Arbiter.ViewIncompleteTournaments( PlayUnfinishedGame );
	}
	
	void PlayUnfinishedGame( string tournamentId ) {
		if ( tournamentId != "" ) {
			GameObject globalsGO = GameObject.Find ("Globals");
			Globals globals = globalsGO.GetComponent<Globals>();
			globals.SelectedUnfinishedTournamentId = tournamentId;
			Application.LoadLevel( "FakeGameScene.cs" );
		}
	}	
}