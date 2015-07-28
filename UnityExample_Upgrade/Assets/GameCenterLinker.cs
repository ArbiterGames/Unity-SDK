using UnityEngine;
using System.Collections;

public class GameCenterLinker : MonoBehaviour {


	public void LinkWithGameCenter() {
		if( Social.localUser.authenticated )
			LogInNow( true );
		else
			Social.localUser.Authenticate( LogInNow );
	}


	void LogInNow( bool success ) {
		if( !success )
			LastErrorField.ShowGlobalError( "Problem with this app logging in to GameCenter." );
		else
			Arbiter.LoginWithGameCenter( LinkSuccess, LastErrorField.ShowGlobalError );
	}


	void LinkSuccess() {
		Debug.Log( "Link with GameCenter successful." );
	}

}
