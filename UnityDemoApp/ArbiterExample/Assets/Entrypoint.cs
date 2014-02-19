using UnityEngine;
using UnityEngine.SocialPlatforms;
using System;
using System.Collections;


public class Entrypoint : MonoBehaviour {
	
	void Start () {
        ArbiterOptionalStep();

        Arbiter.Initialize( LogInToGameCenter );
    }


    void LogInToGameCenter() {
#if UNITY_EDITOR
        // Skip logging in since we're in editor
        ArbiterStep2();
#elif UNITY_IOS
        Action<bool> processAuth = ( success ) => {
            if( success )
                Arbiter.LoginWithGameCenter( ArbiterStep2 );
            else
                Debug.LogError( "Could not authenticate to Game Center!" );
        };
        Social.localUser.Authenticate( processAuth );
#endif
    }


    void ArbiterOptionalStep() {
        // Override some of the default handlers

        //
        // Authentication is critical. You can't really bet unless Arbiter knows who you are!
        //
        // TODO: Handle initialize errors in a similar manner as GC errors
#if UNITY_IOS
        Arbiter.LoginWithGameCenterErrorHandler = ( errors ) => {
            errors.ForEach( e => Debug.LogError( e ));
            Debug.LogError( "Cannot continue betting flow unless Game Center login errors are fixed!" );
        };
#endif
    }


    void ArbiterStep2() {
        Debug.Log( "Hello, " + Arbiter.Username + "!" );
        Debug.Log( "Have you verified your age & location yet? " + Arbiter.Verified );

        if( Arbiter.Verified )
            ArbiterStep3();
        else
            Arbiter.VerifyUser( ArbiterStep3 );
    }

    
    void ArbiterStep3() {
        Arbiter.AddWalletListener( UpdateWalletElements );
        Arbiter.AddWalletListener( SomeOtherHandler );

        ArbiterDoTheseAsOftenAsYouWant();
    }
    
    
    
    void ArbiterDoTheseAsOftenAsYouWant() { // But only after initialization is complete!
        Arbiter.QueryWallet();
    }



    void UpdateWalletElements() {
        string balance = Arbiter.Balance;
        string depositAddress = Arbiter.DepositAddress;
        string depositQrCode = Arbiter.DepositQrCode;
        string withdrawAddress = Arbiter.WithdrawAddress;

        Debug.Log( "Update elements if needed.\n"+
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