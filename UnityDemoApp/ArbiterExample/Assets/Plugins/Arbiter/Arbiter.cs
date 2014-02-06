using UnityEngine;
using System;
using System.Collections.Generic;
using ArbiterInternal;


public class Arbiter : MonoBehaviour
{
	static Arbiter() {
		// Add a GO to the scene for iOS to send responses back to
		GameObject go = new GameObject("ArbiterBinding");
		go.AddComponent<ArbiterBinding>();
        poller = go.AddComponent<Poller>();
        wallet = new Wallet();
        user = new User();
		GameObject.DontDestroyOnLoad( go );
	}


    public static string    Username                    { get { return user.Name; } }
    public static bool      Verified                    { get { return verified == VerificationStatus.Verified; } }
    public static string    Balance                     { get { return wallet.Balance; } }
    public static string    DepositAddress              { get { return wallet.DepositAddress; } }
    public static string    DepositQrCode               { get { return wallet.DepositQrCode; } }
    public static string    WithdrawAddress             { get { return wallet.WithdrawAddress; } }



	public static void Initialize( Action done ) {
		ArbiterBinding.InitializeCallback parse = ( responseUser, responseVerified, responseWallet ) => {
            user = responseUser;
            if( responseVerified )
                verified = VerificationStatus.Verified;
            if( responseWallet != null )
                wallet = responseWallet;
            		
            poller.SetAction( queryWalletIfAble );
            resetWalletPolling();
            done();
		};
		ArbiterBinding.Init( parse );
	}
    

    public static void VerifyUser( Action done ) {
        ArbiterBinding.VerifyUserCallback parse = ( response ) => {
            if( response == true )
                verified = VerificationStatus.Verified;
            else
                verified = VerificationStatus.Unverified;
            done();
        };
        ArbiterBinding.VerifyUser( parse, verifyErrorHandler );
    }
    
    
    public static void AddWalletListener( Action listener ) {
        if( !walletQueryListeners.Contains( listener ))
            walletQueryListeners.Add( listener );
    }
    public static void RemoveWalletListener( Action listener ) {
        walletQueryListeners.Remove( listener );
    }


    public static void QueryWallet() {
        if( user == null )
            Debug.LogWarning( "Cannot query an Arbiter Wallet without first logging in. Did you call Arbiter.Initialize()?" );
        else if( verified == VerificationStatus.Unknown )
            Debug.LogWarning( "This user has not yet been verified and cannot query an Arbiter wallet. Did you call Arbiter.VerifyUser()?" );

        queryWalletIfAble( null );
    }
    private static void queryWalletIfAble( Action callback ) {
        if( user == null || verified != VerificationStatus.Verified ) return;

        Action done = () => {
            walletQueryListeners.ForEach( listener => listener() );
            if( callback != null )
                callback();
        };
        ArbiterBinding.GetWalletCallback parse = ( responseWallet ) => {
            wallet = responseWallet;
            done();
        };
        ArbiterBinding.GetWallet( parse, walletErrorHandler );
    }
    private static void defaultErrorHandler( List<string> errors ) {
        string msg = "";
        errors.ForEach( error => msg+=error );
        Debug.LogError( "There was a problem with an Arbiter call!\n"+msg );
    }
    
    
    private static void resetWalletPolling() {
        poller.Reset();
    }
    
    
    void Update() {
    }


    private static Poller poller;
    private static User user;
    private enum VerificationStatus { Unknown, Unverified, Verified };
    private static VerificationStatus verified = VerificationStatus.Unknown;
    private static Wallet wallet;
    private static List<Action> walletQueryListeners = new List<Action>();
    private static ArbiterBinding.ErrorHandler walletErrorHandler = defaultErrorHandler;
    private static ArbiterBinding.ErrorHandler verifyErrorHandler = defaultErrorHandler;
}
