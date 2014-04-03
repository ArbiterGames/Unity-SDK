using UnityEngine;
using UnityEngine.SocialPlatforms;
using System;
using System.Collections;
using System.Collections.Generic;

public class FinishUnplayedGamesBtn : MonoBehaviour {
	
	void OnMouseUpAsButton() {
		Arbiter.ViewIncompleteCompetitions( PlayUnfinishedGame );
	}
	
	void PlayUnfinishedGame( string competitionId ) {
		if ( competitionId != "" ) {
			GameObject globalsGO = GameObject.Find ("Globals");
			Globals globals = globalsGO.GetComponent<Globals>();
			globals.SelectedUnfinishedCompetitionId = competitionId;
			Application.LoadLevel( "FakeGameScene.cs" );
		}
	}	
}