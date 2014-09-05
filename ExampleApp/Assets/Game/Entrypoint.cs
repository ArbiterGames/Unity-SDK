using UnityEngine;
using UnityEngine.SocialPlatforms;
using System;
using System.Collections;
using System.Collections.Generic;



public class Entrypoint : MonoBehaviour {

	void Start () {
		if ( Arbiter.IsAuthenticated ) {
			LoadNextScene();
		} else {
			StartAuthenticationFlow();
		}
	}
	
	void StartAuthenticationFlow() {
#if UNITY_EDITOR
		// Just log in as anon since we're in the editor
		Arbiter.LoginAsAnonymous( VerificationStep, FatalError );
#elif UNITY_IOS
		if ( Arbiter.OSVersionSupportsGameCenter ) {
			Action<bool> processGcAuth = ( success ) => {
				if( success ) {
					Arbiter.LoginWithGameCenter( VerificationStep, FatalError );
				} else {
					Arbiter.LoginAsAnonymous( VerificationStep, FatalError );
				}

			};
			Social.localUser.Authenticate( processGcAuth );
		} else {
			Arbiter.LoginAsAnonymous( VerificationStep, FatalError );
		}
#else
		Debug.LogError( "Unknown platform!");
		Arbiter.LoginAsAnonymous( VerificationStep, FatalError );
#endif	
	}


	void FatalError( List<string> errors ) {
		Debug.LogError( "Encountered fatal errors. Cannot continue until they are resolved." );
		errors.ForEach( error => {
			Debug.LogError( error );
		});
	}


    void VerificationStep() {
    
        Debug.Log( "Hello, " + Arbiter.Username + "!" );
        Debug.Log( "Have you verified your age & location yet? " + Arbiter.IsVerified );

        // You can choose to verify later if you prefer. But most of the Arbiter features won't let this user do anything until s/he is verified
        if( Arbiter.IsVerified )
            SetupListenersExample();
        else
			Arbiter.VerifyUser( SetupListenersExample, FatalError );
	}


	void SetupListenersExample() {
		Arbiter.AddUserUpdatedListener( UpdateUserElements );
		Arbiter.AddNewUserListener( UpdateUserElements );
        Arbiter.AddWalletListener( UpdateWalletElements );

        LoadNextScene();
    }


	void LoadNextScene() {
        // Since these listeners won't persist across level load, remove them or the game will crash when they are called  TODO: Re-assess this ... is this actually true??
        // (if you setup listeners on persistent objects you should be fine)
		Arbiter.RemoveUserUpdatedListener( UpdateUserElements );
		Arbiter.RemoveNewUserListener( UpdateUserElements );
        Arbiter.RemoveWalletListener( UpdateWalletElements );
		Application.LoadLevel( "SecondScene" );
    }



	void UpdateUserElements() {
		string name = Arbiter.Username;
		bool verified = Arbiter.IsVerified;
		
		Debug.Log( "Update elements if needed...\n"+
		          "username="+name+"\n"+
		          "verified="+verified);
	}


    void UpdateWalletElements() {    
        string balance = Arbiter.Balance;

        Debug.Log( "Update elements if needed...\n"+
			"balance="+balance+"\n");
    }


}
