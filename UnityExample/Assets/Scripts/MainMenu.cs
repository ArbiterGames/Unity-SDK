using UnityEngine;
using System.Collections;
using System.Collections.Generic;

public class MainMenu : MonoBehaviour {

	private static int padding = 10;
	private static int buttonHeight = 100;
	private static int boxWidth = Screen.width - padding * 2;
	private static int boxHeight = buttonHeight * 6 + padding * 5;
	private static int boxY = (Screen.height - boxHeight) / 2;
	private static int buttonWidth = boxWidth - padding * 2;
	
	void Awake() {
		if ( GameObject.Find("GameState") == null ) {
			GameObject go = new GameObject( "GameState" );
			go.AddComponent<GameState>();
		}
	}
	
	void OnGUI() {
	
		GUIStyle buttonStyle = new GUIStyle("button");
		buttonStyle.fontSize = 32;
		GUIStyle boxStyle = new GUIStyle("box");
		boxStyle.fontSize = 38;
		
		GUIStyle labelStyle = new GUIStyle("label");
		labelStyle.fontSize = 18;
		labelStyle.alignment = TextAnchor.LowerCenter;
		
		GUI.Box(new Rect(padding, boxY, boxWidth, boxHeight), "Main Menu", boxStyle);

		GUI.Label(new Rect(0, boxY - padding - labelStyle.fontSize, buttonWidth, buttonHeight), "Arbiter User Id:" + Arbiter.UserId, labelStyle);
		GUI.Label(new Rect(0, boxY - padding, buttonWidth, buttonHeight), "User Wallet Balance:" + Arbiter.Balance, labelStyle);
		
		if(GUI.Button(new Rect(padding * 2, buttonHeight + boxY, buttonWidth / 2 - padding / 2, buttonHeight), "Dashboard", buttonStyle)) {
			Arbiter.DisplayWalletDashboard( OnWalletDashboardClose );
		}
		
		if(GUI.Button(new Rect(padding * 2.5f + buttonWidth / 2, buttonHeight + boxY, buttonWidth / 2 - padding / 2, buttonHeight), "Free Credits!", buttonStyle)) {
			Arbiter.SendPromoCredits( "100", OnSendPromoCreditsSuccess, ErrorHandler );
			Arbiter.DisplayWalletDashboard( OnWalletDashboardClose );
		}
		
		if(GUI.Button(new Rect(padding * 2, buttonHeight * 2 + padding + boxY, buttonWidth, buttonHeight), "Cash Challenge", buttonStyle)) {
			Application.LoadLevel ("CashChallenge");
		}
		
		GUI.Label(new Rect(padding * 2, buttonHeight * 3 + padding + boxY, buttonWidth, buttonHeight), "Entry fee: 50 credits", labelStyle);
		if(GUI.Button(new Rect(padding * 2, buttonHeight * 3 + padding  * 2 + boxY, buttonWidth, buttonHeight), "Join Cash Tournament", buttonStyle)) {
			string betSize = "50";
			Dictionary<string,string> filters = new Dictionary<string,string>();
			filters.Add("level", "2");
			Arbiter.JoinTournament( betSize, filters, JoinTournamentSuccessHandler, FriendlyErrorHandler );
		}
		
		if(GUI.Button(new Rect(padding * 2, buttonHeight * 4 + padding * 3 + boxY, buttonWidth / 2 - padding / 2, buttonHeight), "Updates", buttonStyle)) {
			Arbiter.ShowPreviousTournaments( OnViewPreviousTournamentsClosed );
		}
		
		if(GUI.Button(new Rect(padding * 2.5f + buttonWidth / 2, buttonHeight * 4 + padding * 3 + boxY, buttonWidth / 2 - padding / 2, buttonHeight), "Previous", buttonStyle)) {
			Arbiter.ShowPreviousTournaments( OnViewPreviousTournamentsClosed );
		}
		
		if(GUI.Button(new Rect(padding * 2, buttonHeight * 5 + padding * 4 + boxY, buttonWidth, buttonHeight), "Logout", buttonStyle)) {
			Arbiter.Logout( LogoutSuccessHandler, ErrorHandler );
		}
	}
	
	private void OnWalletDashboardClose() {
		Debug.Log ("Dashboard closed");
	}
	
	private void JoinTournamentSuccessHandler( Arbiter.Tournament tournament ) {
		GameObject go = GameObject.Find("GameState");
		GameState gameState = go.GetComponent<GameState>();
		gameState.CurrentTournamentId = tournament.Id;
		
		// TODO: Rename "Game" to "Tournament"
		Application.LoadLevel("CashTournament");
	}
	
	private void FriendlyErrorHandler( List<string> errors, List<string> descriptions ) {
		errors.ForEach( error => Debug.Log( error ) );
	}
	
	private void ErrorHandler( List<string> errors ) {
		errors.ForEach( error => Debug.Log( error ) );
	}
	
	private void OnSendPromoCreditsSuccess() {
		Debug.Log ("Credits have been sent");
	}
	
	private void OnViewPreviousTournamentsClosed() {
		Debug.Log ("ViewPreviousTournaments closed");
	}
	
	private void LogoutSuccessHandler() {
		Application.LoadLevel ("Login");
	}
}
