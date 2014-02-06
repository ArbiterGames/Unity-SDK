using UnityEngine;
using System;
using System.Collections.Generic;
using ArbiterInternal;


public class Arbiter : MonoBehaviour
{
	static Arbiter() {
		// Add a GO to the scene for iOS to send responses back to
		GameObject go = new GameObject("ArbiterBinding");
		binding = go.AddComponent<ArbiterBinding>();
        poller = go.AddComponent<Poller>();
		GameObject.DontDestroyOnLoad( go );
	}


	public static void Initialize( Action done ) {
		Action<Dictionary<string, string>> parse = ( response ) => {
            userId = response[ "user_id" ];
            poller.SetAction( queryWalletIfAble );
            resetWalletPolling();
            done();
		};
		ArbiterBinding.Init( parse );
	}
    
    
    public static void VerifyUser( Action done ) {
        Action<bool> parse = ( response ) => {
            if( response == true )
                verified = VerificationStatus.Verified;
            else
                verified = VerificationStatus.Unverified;
            done();
        };
        ArbiterBinding.VerifyUser( parse );
    }
    
    
    public static void QueryWallet( Action callback ) {
        if( userId == null )
            Debug.LogWarning( "Cannot query an Arbiter Wallet without first logging in. Did you call Arbiter.Initialize()?" );
        else if( verified == VerificationStatus.Unknown )
            Debug.LogWarning( "This user has not yet been verified and cannot query an Arbiter wallet. Did you call Arbiter.VerifyUser()?" );
        queryWalletIfAble( callback );
    }
    private static void queryWalletIfAble( Action done ) {
        if( userId == null || verified != VerificationStatus.Verified ) return;
        
        Action<Dictionary<string, string>> parse = ( response ) => {
            Debug.Log( response );
            if( done != null ) 
                done();
        };
        ArbiterBinding.GetWallet( parse );
    }

    
    
    private static void resetWalletPolling() {
        poller.Reset();
    }
    
    
    void Update() {
    }

    
	private static ArbiterBinding binding;
    private static Poller poller;
    private static string userId;
    private enum VerificationStatus { Unknown, Unverified, Verified };
    private static VerificationStatus verified = VerificationStatus.Unknown;
}
