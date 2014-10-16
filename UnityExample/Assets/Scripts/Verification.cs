using UnityEngine;
using System.Collections;
using System.Collections.Generic;

public class Verification : MonoBehaviour {

	private static int padding = 10;
	private static int buttonHeight = 100;
	private static int boxWidth = Screen.width - padding * 2;
	private static int boxHeight = buttonHeight * 3 + padding * 3;
	private static int boxY = (Screen.height - boxHeight) / 2;
	private static int buttonWidth = boxWidth - padding * 2;
	
	void OnGUI() {
	
		GUIStyle buttonStyle = new GUIStyle("button");
		buttonStyle.fontSize = 32;
		GUIStyle boxStyle = new GUIStyle("box");
		boxStyle.fontSize = 38;
		
		
		GUI.Box(new Rect(padding, boxY, boxWidth, boxHeight), "Verification", boxStyle);
		
		if(GUI.Button(new Rect(padding * 2, buttonHeight + boxY, buttonWidth, buttonHeight), "Verify", buttonStyle)) {
			Arbiter.VerifyUser( VerificationCallback, ErrorHandler );
		}
		
		if(GUI.Button(new Rect(padding * 2, buttonHeight * 2 + boxY + padding, buttonWidth, buttonHeight), "Logout", buttonStyle)) {
			Arbiter.Logout( LogoutCallback, ErrorHandler );
		}
	}
	
	private void VerificationCallback() {
		if ( Arbiter.AgreedToTerms && Arbiter.LocationApproved ) {
			Application.LoadLevel( "MainMenu" );
		} else {
			if ( !Arbiter.LocationApproved ) {
				// TODO: Figure out why this user's location is not getting approved
				Debug.Log ("Issue in Verification.cs: The user's location is not approved for betting in this game.");
			}  
			if ( !Arbiter.AgreedToTerms ) {
				Debug.Log ("Issue in Verification.cs: The user did not agree to the terms and conditions.");
			}
		}
	}
	
	private void LogoutCallback() {
		Application.LoadLevel( "Login" );
	}
	
	private void ErrorHandler( List<string> errors ) {
		errors.ForEach( error => Debug.Log( error ) );
	}
}
