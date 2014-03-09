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
        ArbiterBinding.LoginCallback parse = ( responseUser, responseVerified, responseWallet ) => {    // TODO: These anon functions will call the first "done" callback for every call--need to provide proper function closures!
            parseLoginResponse( responseUser, responseVerified, responseWallet, done );
        };
        ArbiterBinding.Init( parse, initializeErrorHandler );
	}
    public static Action<List<string>> InitializeErrorHandler { set { initializeErrorHandler = ( errors ) => value( errors ); } }


#if UNITY_IOS
    /// <summary>
    /// Uses Game Center credentials to log in to an Arbiter Account.
    /// </summary>
    /// <param name="done">Called when login was completed successfully</param>
    public static void LoginWithGameCenter( Action done ) {
        ArbiterBinding.LoginCallback parse = ( responseUser, responseVerified, responseWallet ) => {
            parseLoginResponse( responseUser, responseVerified, responseWallet, done );
        };
        ArbiterBinding.LoginWithGameCenter( parse, loginWithGameCenterErrorHandler );
    }
    public static Action<List<string>> LoginWithGameCenterErrorHandler { set { loginWithGameCenterErrorHandler = ( errors ) => value( errors ); } }
#endif


    public static void VerifyUser( Action done ) {
        ArbiterBinding.VerifyUserCallback parse = ( response ) => {
            if( response == true )
                verified = VerificationStatus.Verified;
            done();
        };
        verified = VerificationStatus.Unverified;
        ArbiterBinding.VerifyUser( parse, verifyUserErrorHandler );
    }
    public static Action<List<string>> VerifyUserErrorHandler { set { verifyUserErrorHandler = ( errors ) => value( errors ); } }
    
    
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
        walletSuccessCallback = callback;

        if( user == null || verified != VerificationStatus.Verified ) {
            if( walletSuccessCallback != null )
                walletSuccessCallback();
            return;
        }

        ArbiterBinding.GetWallet( walletSuccessHandler, walletErrorHandler );
    }
    private static void walletSuccessHandler( Wallet responseWallet ) {
        wallet = responseWallet;
        walletQueryListeners.ForEach( listener => listener() );
        if( walletSuccessCallback != null )
            walletSuccessCallback();
    }


    public static void ShowWalletPanel( Action callback ) {
        ArbiterBinding.ShowWalletPanel( callback );
    }


    public delegate void RequestCompetitionCallback();
    public static void RequestCompetition( Dictionary<string,string> filters, RequestCompetitionCallback callback ) {
        RequestCompetition( null, filters, callback );
    }
    public static void RequestCompetition( string buyIn, Dictionary<string,string> filters, RequestCompetitionCallback callback ) {
        /* ttt
        const string BUY_IN = "buy_in";
        if( otherFilters == null )
            otherFilters = new Dictionary<string,string>();
        if( otherFilters.ContainsKey( BUY_IN )) {
            if( otherFilters[ BUY_IN ] != buyIn ) {
                Debug.LogError( "It appears you have added the 'buy_in' filter manually but it does not match the buyIn parameter!" );
            }
        } else {
            otherFilters.Add( BUY_IN, buyIn );  // ttt TODO don't pass this in to the filters dict
        }
        */

        if( filters == null )
            filters = new Dictionary<string,string>();
        
        ArbiterBinding.RequestCompetition( buyIn, filters, callback, defaultErrorHandler );
    }


    private static void defaultErrorHandler( List<string> errors ) {
        string msg = "";
        errors.ForEach( error => msg+=error+"\n" );
        Debug.LogError( "There were problems with an Arbiter call:\n"+msg );
    }


    private static void parseLoginResponse( User responseUser, bool responseVerified, Wallet responseWallet, Action done ) {
        user = responseUser;
        verified = responseVerified? VerificationStatus.Verified : VerificationStatus.Unknown;
        wallet = responseWallet == null? responseWallet : new Wallet();
        
        poller.SetAction( queryWalletIfAble );
        resetWalletPolling();
        done();
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
    private static Action walletSuccessCallback;
    private static List<Action> walletQueryListeners = new List<Action>();
    private static ArbiterBinding.ErrorHandler initializeErrorHandler = defaultErrorHandler;
    private static ArbiterBinding.ErrorHandler walletErrorHandler = defaultErrorHandler;
    private static ArbiterBinding.ErrorHandler verifyUserErrorHandler = defaultErrorHandler;
#if UNITY_IOS
    private static ArbiterBinding.ErrorHandler loginWithGameCenterErrorHandler = defaultErrorHandler;
#endif
}
