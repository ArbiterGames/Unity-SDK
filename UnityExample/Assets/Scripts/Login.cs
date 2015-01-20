using UnityEngine;
using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine.SocialPlatforms;

public class Login : MonoBehaviour {
	
	private static int padding = 10;
	private static int buttonHeight = 100;
	private static int boxWidth = Screen.width - (padding * 2);
	private static int boxHeight = (buttonHeight * 4) + (padding * 4);
	private static int boxY = (Screen.height - boxHeight) / 2;
	private static int buttonWidth = boxWidth - (padding * 2);
	

	void Start() {
		if( !Arbiter.IsAuthenticated ) {
			Arbiter.AddNewUserListener( ContinueLoading );
			// tttd also need to remove this listener at the appropriate time.
		}
	}

	void OnGUI() {
		GUIStyle buttonStyle = new GUIStyle("button");
		buttonStyle.fontSize = 32;
		GUIStyle boxStyle = new GUIStyle("box");
		boxStyle.fontSize = 38;
		
		GUI.Box(new Rect(padding, boxY, boxWidth, boxHeight), "Login Options", boxStyle);

		if( needsNewUser ) {
			if(GUI.Button(new Rect(padding * 2, boxY + buttonHeight, buttonWidth, buttonHeight), "Login with Device ID", buttonStyle)) {
				Arbiter.LoginWithDeviceId( SuccessHandler, ErrorHandler );
			}

#if UNITY_IOS
			if(GUI.Button(new Rect(padding * 2, (buttonHeight * 2) + padding + boxY, buttonWidth, buttonHeight), "Login with Game Center", buttonStyle)) {
				Action<bool> processAuth = ( success ) => {
					if( success ) {
						Arbiter.LoginWithGameCenter( SuccessHandler, ErrorHandler );
					} else {
						Debug.LogError( "Could not authenticate to Game Center! Make Sure the user has not disabled Game Center on their device, or have them create an Arbiter Account." );
					}
				};
				Social.localUser.Authenticate( processAuth );
			}
#endif
			
			if(GUI.Button(new Rect(padding * 2, (buttonHeight * 3) + (padding * 2) + boxY, buttonWidth, buttonHeight), "Basic Login", buttonStyle)) {
				Arbiter.Login( SuccessHandler, ErrorHandler );
			}
		} else {
			GUI.Box(new Rect(padding, boxY + buttonHeight, boxWidth, boxHeight), "Initializing...", boxStyle);
		}
	}
	private void SuccessHandler() {
		Debug.Log ("ttt SuccessHandler!");
		ContinueLoading(); // ttt td test trying without this case and letting the native sdk catch the userUpdated event instead (which is already implemented).
	}
	private void ErrorHandler( List<string> errors ) {
		errors.ForEach( error => Debug.Log( error ));
	}


	void ContinueLoading() {
		UnityEngine.Debug.Log("ttt ContinueLoading called!");
		if ( Arbiter.IsAuthenticated ) {
			if ( Arbiter.IsVerified ) {
				Application.LoadLevel("MainMenu");
			} else {
				Application.LoadLevel("Verification");
			}
		} else {
			// ttt td call the new(ish) create device user here
			Debug.Log ("Error logging in!");
			needsNewUser = true;
		}	
	}


	bool needsNewUser = false;

}
