using UnityEngine;
using UnityEngine.SocialPlatforms;
using System;
using System.Collections;
using System.Collections.Generic;



public class Entrypoint : MonoBehaviour {
	
	void Start () {
		const string GAME_API_KEY = "c61d1e3f7d5544e595551ff773121077";     // This comes from the www.arbiter.me/dashboard/games/
		
        ArbiterOptionalStep();
        Arbiter.Initialize( GAME_API_KEY, LogInToGameCenter );
	}


    void LogInToGameCenter() {
#if UNITY_EDITOR
        // Skip logging in since we're in editor
        VerificationStep();
#elif UNITY_IOS
        Action<bool> processAuth = ( success ) => {
            if( success ) {
                Arbiter.LoginWithGameCenter( VerificationStep );
            } else {
                Debug.LogError( "Could not authenticate to Game Center!" );
                // Can continue, but logged in as the anonymous user created/fetched from the initialize call
                VerificationStep();
            }
        };
        Social.localUser.Authenticate( processAuth );
#endif
    }


    void ArbiterOptionalStep() {
        // Override some of the default handlers

        //
        // Authentication is critical. You can't really bet unless Arbiter knows who you are!
        //
        Action<List<string>> criticalErrorHandler = ( errors ) => {
            Debug.LogError( "Cannot continue betting flow unless these login errors are fixed!" );
            errors.ForEach( e => Debug.LogError( e ));
        };
        Arbiter.InitializeErrorHandler = criticalErrorHandler;
#if UNITY_IOS
        Arbiter.LoginWithGameCenterErrorHandler = criticalErrorHandler;
#endif

        // Verification is less critical, but they'll still need to do it to actually compete!
        Arbiter.VerifyUserErrorHandler = ( errors ) => {
            Debug.LogError( "Problem with verification. Not all features will be available!" );
            errors.ForEach( e => Debug.LogError( e ));
            SetupListenersIfYouWant();
        };

    }


    void VerificationStep() {
        Debug.Log( "Hello, " + Arbiter.Username + "!" );
        Debug.Log( "Have you verified your age & location yet? " + Arbiter.Verified );

        // You can choose to verify later if you prefer. But most of the Arbiter features won't let this user do anything until s/he is verified
        if( Arbiter.Verified )
            SetupListenersIfYouWant();
        else
            Arbiter.VerifyUser( SetupListenersIfYouWant );
    }

    
    void SetupListenersIfYouWant() {
        Arbiter.AddWalletListener( UpdateWalletElements );
        Arbiter.AddWalletListener( SomeOtherHandler );
        ArbiterDoTheseAsOftenAsYouWant();

        LoadAnotherScene();
    }

    void LoadAnotherScene() {
        // Since the 2 listeners won't persist across level load, remove them or the game will crash when they are called  TODO: Re-assess this ... is this actually true??
        // (if you setup listeners on persistent objects you should be fine)
        Arbiter.RemoveWalletListener( UpdateWalletElements );
        Arbiter.RemoveWalletListener( SomeOtherHandler );

        Application.LoadLevel( "SecondScene" );
    }
    
    
    
    void ArbiterDoTheseAsOftenAsYouWant() { // But only after initialization is complete!
        Arbiter.QueryWallet();
    }



    void UpdateWalletElements() {
        bool verified = Arbiter.Verified;
        string balance = Arbiter.Balance;
        // TODO: Add PendingBalance to Arbiter class definition
        //		 Figure out where else this should also go (wallet alert, main scene)
		// string pendingBalance = Arbiter.PendingBalance;
        string depositAddress = Arbiter.DepositAddress;
        string depositQrCode = Arbiter.DepositQrCode;
        string withdrawAddress = Arbiter.WithdrawAddress;

        Debug.Log( "Update elements if needed.\n"+
            "verified="+verified+"\n"+
            "balance="+balance+"\n"+
            "deposit="+depositAddress+"\n"+
            "depositQr="+depositQrCode+"\n"+
            "withdraw="+withdrawAddress
        );
    }


    void SomeOtherHandler() {
        Debug.Log( "Example of other wallet listeners triggering." );
    }
}