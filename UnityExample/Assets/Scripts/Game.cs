using UnityEngine;
using System.Collections;
using System.Linq;

public class Game : MonoBehaviour {
	
	static int padding = 10;
	static int buttonHeight = 100;
	static int boxWidth = Screen.width - padding * 2;
	static int boxHeight = buttonHeight * 2 + padding * 3;
	static int boxY = (Screen.height - boxHeight) / 2;
	static int buttonWidth = boxWidth - padding * 2;
	
	int score;
	bool scoreReported;
	
	
	void OnGUI() {
		
		GUIStyle buttonStyle = new GUIStyle("button");
		buttonStyle.fontSize = 32;
		GUIStyle boxStyle = new GUIStyle("box");
		boxStyle.fontSize = 38;
		GUIStyle labelStyle = new GUIStyle("label");
		labelStyle.fontSize = 18;
		labelStyle.alignment = TextAnchor.MiddleCenter;
		
		GUI.Box(new Rect(padding, boxY, boxWidth, boxHeight), "The Game", boxStyle);
	
		if ( !scoreReported ) {
			if(GUI.Button(new Rect(padding * 2, buttonHeight + boxY + padding, buttonWidth, buttonHeight), "Play", buttonStyle)) {
				GameObject go = GameObject.Find("GameState");
				GameState gameState = go.GetComponent<GameState>();
				score = (int)UnityEngine.Random.Range( 1f, 100f );
				Arbiter.ReportScore( gameState.CurrentTournamentId, score, OnScoreReported );
			}
		}
	}
	
	void OnScoreReported( Arbiter.Tournament tournament ) {
		scoreReported = true;
		Arbiter.ShowTournamentDetails( tournament.Id, OnDetailsPanelClosed );
	}
	
	void OnDetailsPanelClosed() {
		Application.LoadLevel ("MainMenu");
	}
}
