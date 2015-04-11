using UnityEngine;
using System.Collections;
using System.Collections.Generic;
using System.Linq;

public class CashChallenge : MonoBehaviour {

	const string ENTRY_FEE = "100";
	string ScoreToBeat;
	string Score;
	string Problems = "";
	string ChallengeId = "Waiting";
	string ResultsDescription = "";
	bool ChallengeAccepted = false;
	bool ScoreReported = false;
	
	static int padding = 10;
	static int buttonHeight = 100;
	static int boxWidth = Screen.width - padding * 2;
	static int boxHeight = buttonHeight * 6 + padding * 6;
	static int boxY = (Screen.height - boxHeight) / 2;
	static int buttonWidth = boxWidth - padding * 2;
	static int labelHeight = 30;
	static int labelWidth = buttonWidth;
	
	
	void Start () {
		Arbiter.RequestCashChallenge( null, OnChallengeCreated, ErrorHandler );
	}
	
	
	void OnGUI() {
		
		GUIStyle buttonStyle = new GUIStyle("button");
		buttonStyle.fontSize = 32;
		GUIStyle boxStyle = new GUIStyle("box");
		boxStyle.fontSize = 38;
		GUIStyle labelStyle = new GUIStyle("label");
		labelStyle.fontSize = 18;
		labelStyle.alignment = TextAnchor.MiddleLeft;
		
		GUI.Box(new Rect(padding, boxY, boxWidth, boxHeight), "The Challenge", boxStyle);
		
		GUI.Label(new Rect(padding * 2, boxY + labelHeight * 2, labelWidth, labelHeight), "Challenge id:" + ChallengeId, labelStyle);
		GUI.Label(new Rect(padding * 2, boxY + labelHeight * 3, labelWidth, labelHeight), "Score to beat:" + ScoreToBeat, labelStyle);
		GUI.Label(new Rect(padding * 2, boxY + labelHeight * 4, labelWidth, labelHeight), "Score:" + Score, labelStyle);
		GUI.Label(new Rect(padding * 2, boxY + labelHeight * 5, labelWidth, labelHeight), "Results:" + ResultsDescription, labelStyle);
		GUI.Label(new Rect(padding * 2, boxY + labelHeight * 6, labelWidth, labelHeight), "Errors:" + Problems, labelStyle);
		
		if ( ScoreReported ) {
			if(GUI.Button(new Rect(padding * 2, buttonHeight * 3 + boxY + padding * 3, buttonWidth, buttonHeight), "Back", buttonStyle)) {
				Application.LoadLevel("MainMenu");
			}
		}
		else if ( ChallengeAccepted ) {
			if(GUI.Button(new Rect(padding * 2, buttonHeight * 3 + boxY + padding * 3, buttonWidth, buttonHeight), "Play", buttonStyle)) {
				int intScore = (int)UnityEngine.Random.Range( 1f, 100f );
				Score = intScore.ToString();
				Arbiter.ReportScoreForChallenge( ChallengeId, Score, OnScoreReported, ErrorHandler );
			}
		} else {
			if(GUI.Button(new Rect(padding * 2, buttonHeight * 2 + boxY + padding * 2, buttonWidth, buttonHeight), "Accept Custom", buttonStyle)) {
				Arbiter.AcceptCashChallenge( ChallengeId, OnChallengeAccepted, ErrorHandler );
			}
			if(GUI.Button(new Rect(padding * 2, buttonHeight * 3 + boxY + padding * 3, buttonWidth, buttonHeight), "Accept Default", buttonStyle)) {
				Arbiter.AcceptCashChallengeUseNativeErrorDialogue( ChallengeId, OnChallengeAccepted, OnChallengeRejected );
			}
			if(GUI.Button(new Rect(padding * 2, buttonHeight * 4 + boxY + padding * 4, buttonWidth, buttonHeight), "Reject", buttonStyle)) {
				Arbiter.RejectCashChallenge( ChallengeId, OnChallengeRejected );
			}
		}
		
		if ( ChallengeId != "Waiting" ) {
			if(GUI.Button(new Rect(padding * 2, buttonHeight * 5 + boxY + padding * 5, buttonWidth, buttonHeight), "Official Rules", buttonStyle)) {
				Arbiter.ShowCashChallengeRules( ChallengeId, OnRulesClosed );
			}
		}
	}
	
	void OnChallengeCreated( Arbiter.CashChallenge challenge ) {
		ChallengeId = challenge.Id;
		ScoreToBeat = challenge.ScoreToBeat;
	}
	
	void OnChallengeAccepted() {
		ChallengeAccepted = true;
	}
	
	void OnChallengeRejected() {
		Application.LoadLevel("MainMenu");
	}
	
	void OnRulesClosed() {
		Debug.Log ("Score Challenge rules closed");
	}
	
	void OnScoreReported( Arbiter.CashChallenge challenge ) {
		ScoreReported = true;
		if ( challenge.Status == Arbiter.CashChallenge.StatusType.Closed ) {
			if ( challenge.Winner != null ) {
				if ( challenge.Winner.Id == Arbiter.UserId ) {
					ResultsDescription = "You Won!";
				} else {
					ResultsDescription = "You lost";
				}
			}
		} else if ( challenge.Status == Arbiter.CashChallenge.StatusType.Open || challenge.Status == Arbiter.CashChallenge.StatusType.Busy ) {
			ResultsDescription = "You lost";
		} else {
			Debug.LogError( "Found unexpected status code ("+challenge.Status+")!" );
		}
	}
	
	void ErrorHandler( List<string> errors, List<string> descriptions ) {
		ErrorHandlerWODescriptions( errors );
	}
	
	void ErrorHandlerWODescriptions( List<string> errors ) {
		string msg = "";
		errors.ForEach( error => msg += error + ". " );
		Problems = msg;
	}
	
	
	void OnDetailsPanelClosed() {
		Application.LoadLevel ("MainMenu");
	}
}
