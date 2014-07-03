using UnityEngine;
using UnityEngine.SocialPlatforms;
using System;
using System.Collections;
using System.Collections.Generic;



public class Entrypoint : MonoBehaviour {

	void Start () {
		// Override default error handlers if you want
		OptionallyOverrideDefaultArbiterErrorHandlers();

#if UNITY_EDITOR
		// Skip logging in since we're in editor
		VerificationStep();
#elif UNITY_IOS
		Action<bool> processAuth = ( success ) => {
			if( success ) {
				Arbiter.LoginWithGameCenter( VerificationStep );
			} else {
				Debug.LogError( "Could not authenticate to Game Center! Calling Arbiter.Login()" );
				Arbiter.Login ( VerificationStep );
			}
		};
		Social.localUser.Authenticate( processAuth );
#endif	
	}

    void VerificationStep() {
        Debug.Log( "Hello, " + Arbiter.Username + "!" );
        Debug.Log( "Have you verified your age & location yet? " + Arbiter.Verified );

        // You can choose to verify later if you prefer. But most of the Arbiter features won't let this user do anything until s/he is verified
        if( Arbiter.Verified )
            SetupListenersExample();
        else
			Arbiter.VerifyUser( SetupListenersExample );
	}


	void SetupListenersExample() {
        Arbiter.AddWalletListener( UpdateWalletElements );
		Arbiter.AddWalletListener( WalletListenerExample );
		ArbiterDoTheseAsOftenAsYouWant();

        LoadAnotherScene();
    }

	void LoadAnotherScene() {
        // Since the 2 listeners won't persist across level load, remove them or the game will crash when they are called  TODO: Re-assess this ... is this actually true??
        // (if you setup listeners on persistent objects you should be fine)
        Arbiter.RemoveWalletListener( UpdateWalletElements );
		Arbiter.RemoveWalletListener( WalletListenerExample );
		Application.LoadLevel( "SecondScene" );
    }



    void ArbiterDoTheseAsOftenAsYouWant() { // But only after initialization is complete!
        Arbiter.GetWallet();
    }



    void UpdateWalletElements() {
        bool verified = Arbiter.Verified;
        string balance = Arbiter.Balance;
		string pendingBalance = Arbiter.PendingBalance;
        string depositAddress = Arbiter.DepositAddress;
        string depositQrCode = Arbiter.DepositQrCode;
        string withdrawAddress = Arbiter.WithdrawAddress;

        Debug.Log( "Update elements if needed.\n"+
            "verified="+verified+"\n"+
            "balance="+balance+"\n"+
            "pending balance="+pendingBalance+"\n"+
            "deposit="+depositAddress+"\n"+
            "depositQr="+depositQrCode+"\n"+
            "withdraw="+withdrawAddress
        );
    }


	/**
		Method to demo setting up a wallet listener
	*/
    void WalletListenerExample() {
        Debug.Log( "Example of other wallet listeners triggering." );
    }


	/**
		Method to demo overriding the default Arbiter error handlers
	*/
	void OptionallyOverrideDefaultArbiterErrorHandlers() {
		Action<List<string>> criticalErrorHandler = ( errors ) => {
			Debug.LogError( "Cannot continue betting flow unless these login errors are fixed!" );
			errors.ForEach( e => Debug.LogError( e ));
		};
		Arbiter.InitializeErrorHandler = criticalErrorHandler;

		#if UNITY_IOS
		Arbiter.LoginWithGameCenterErrorHandler = criticalErrorHandler;
		#endif

		Arbiter.VerifyUserErrorHandler = ( errors ) => {
			Debug.LogError( "Problem with verification. Not all features will be available!" );
			errors.ForEach( e => Debug.LogError( e ));
			SetupListenersExample();
		};
	}
}
