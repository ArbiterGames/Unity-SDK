using UnityEngine;
using UnityEngine.SocialPlatforms;
using System;
using System.Collections;
using System.Collections.Generic;



public class LogoutBtn : MonoBehaviour {
	
	void OnMouseUpAsButton() {
		Arbiter.Logout(  LogoutCallback );
	}

	public static void LogoutCallback() {
		Application.LoadLevel( "StartupScene" );
	}
	
}