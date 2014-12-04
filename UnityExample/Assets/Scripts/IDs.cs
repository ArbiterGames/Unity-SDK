using UnityEngine;
using System.Collections;
using System.Collections.Generic;


public class IDs : MonoBehaviour {

	private static int padding = 10;
	private static int buttonHeight = 100;
	private static int lineHeight = 32;
	private static int topPadding = 40;
	private static int boxWidth = Screen.width - padding * 2;
	private static int boxHeight = buttonHeight + lineHeight * 3 + topPadding + padding * 3;
	private static int boxY = (Screen.height - boxHeight) / 2;
	private static int buttonWidth = boxWidth - padding * 2;
	
	void OnGUI() {
	
		GUIStyle buttonStyle = new GUIStyle("button");
		buttonStyle.fontSize = 32;
		GUIStyle boxStyle = new GUIStyle("box");
		boxStyle.fontSize = 38;

		GUIStyle labelStyle = new GUIStyle("label");
		labelStyle.fontSize = 18;
		labelStyle.alignment = TextAnchor.LowerLeft;
		
		
		GUI.Box(new Rect(padding, boxY, boxWidth, boxHeight), "IDs", boxStyle);
		
		GUI.Label(new Rect(padding * 2, lineHeight * 0 + topPadding + padding * 2 + boxY, buttonWidth, lineHeight ), "Arbiter ID: "+Arbiter.UserId, labelStyle);
		GUI.Label(new Rect(padding * 2, lineHeight * 1 + topPadding + padding * 2 + boxY, buttonWidth, lineHeight ), "Device ID: "+SystemInfo.deviceUniqueIdentifier, labelStyle );
		GUI.Label(new Rect(padding * 2, lineHeight * 2 + topPadding + padding * 2 + boxY, buttonWidth, lineHeight ), "Zipcode: "+Arbiter.UserLocation.Zipcode, labelStyle );
		
		if(GUI.Button(new Rect(padding * 2, buttonHeight * 2 + boxY + padding, buttonWidth, buttonHeight), "Back", buttonStyle)) {
			Application.LoadLevel( "MainMenu" );
		}
	}

	
	private void LogoutCallback() {
		Application.LoadLevel( "Login" );
	}
	
	private void ErrorHandler( List<string> errors ) {
		Debug.LogWarning( "Verification Errors:" );
		errors.ForEach( error => Debug.Log( error ) );
	}
}
