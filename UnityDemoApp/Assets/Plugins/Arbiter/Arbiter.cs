using UnityEngine;
using System;
using System.Collections.Generic;
using System.Linq;
using ArbiterInternal;


public partial class Arbiter : MonoBehaviour
{
	static Arbiter() {
		// Add a GO to the scene for iOS to send responses back to
		GameObject go = new GameObject( "ArbiterBinding" );
		go.AddComponent<ArbiterBinding>();
        walletPoller = go.AddComponent<Poller>();
        competitionPoller = go.AddComponent<Poller>();
        wallet = new Wallet();
        user = new User();
		GameObject.DontDestroyOnLoad( go );
	}


    public static string    UserId                      { get { return user.Id; } }
    public static string    Username                    { get { return user.Name; } }
    public static bool      Verified                    { get { return verified == VerificationStatus.Verified; } }
    public static string    Balance                     { get { return wallet.Balance; } }
    public static string    DepositAddress              { get { return wallet.DepositAddress; } }
    public static string    DepositQrCode               { get { return wallet.DepositQrCode; } }
    public static string    WithdrawAddress             { get { return wallet.WithdrawAddress; } }



	public static void Initialize( string gameApiKeyFromDashboard, Action done ) {
        ArbiterBinding.LoginCallback parse = ( responseUser, responseVerified, responseWallet ) => {    // TODO: These anon functions will call the first "done" callback for every call--need to provide proper function closures!
            parseLoginResponse( responseUser, responseVerified, responseWallet, done );
        };
        ArbiterBinding.Init( gameApiKeyFromDashboard, parse, initializeErrorHandler );
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
            if( done != null )
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


    public delegate void GetScorableCompetitionCallback( Competition competition );
    public static void GetScorableCompetition( string buyIn, Dictionary<string,string> filters, GetScorableCompetitionCallback callback ) {
        getScorableCompetitionCallback = callback;
        // ttt TODO: Check if there is already an 'unplayed' competition this user is already a part of. For now just request a new one and then start polling.
        RequestCompetition( buyIn, filters, null );
		pollUntilScorableCompetitionFound( buyIn, filters );
    }


    public delegate void RequestCompetitionCallback();
    public static void RequestCompetition( Dictionary<string,string> filters, RequestCompetitionCallback callback ) { // tttd rename to request new competition?
        RequestCompetition( null, filters, callback );
    }
    public static void RequestCompetition( string buyIn, Dictionary<string,string> filters, RequestCompetitionCallback callback ) {
        if( filters == null ) {
            filters = new Dictionary<string,string>();
        }
        
        ArbiterBinding.RequestCompetition( buyIn, filters, callback, defaultErrorHandler );
    }


    public static void QueryCompetitions( Action callback ) {
        getCompetitionsCallback = callback;
        ArbiterBinding.GetCompetitions( GetCompetitionsSuccessHandler, getCompetitionsErrorHandler );
    }
    public delegate void GetCompetitionsCallback( List<Competition> competitions );
    public static void GetCompetitionsSuccessHandler( List<Competition> competitions ) {
        initializingCompetitions = competitions.Where( c => c.Status == Competition.StatusType.Initializing ).ToList();
        inProgressCompetitions = competitions.Where( c => c.Status == Competition.StatusType.InProgress ).ToList();
        completeCompetitions = competitions.Where( c => c.Status == Competition.StatusType.Complete ).ToList();
        getCompetitionsCallback();
    }


	public static List<Competition> InitializingCompetitions {
        get {
			return initializingCompetitions;
        }
    }
    public static List<Competition> InProgressCompetitions {
        get {
            return inProgressCompetitions;
        }
    }
    public static List<Competition> CompleteCompetitions {
        get {
            return completeCompetitions;
        }
    }


    public delegate void ViewPreviousCompetitionsCallback();
    public static void ViewPreviousCompetitions( ViewPreviousCompetitionsCallback callback ) {
        if( callback == null )
            callback = () => {};
        ArbiterBinding.ViewPreviousCompetitions( callback );
    }
    
    
	public delegate void ViewIncompleteCompetitionsCallback( string competitionId );
	public static void ViewIncompleteCompetitions( ViewIncompleteCompetitionsCallback callback ) {
		if( callback == null )
			callback = ( String competitionId ) => {};
		ArbiterBinding.ViewIncompleteCompetitions( callback );
	}


    public delegate void ReportScoreCallback( Competition competition );
    public static void ReportScore( string competitionId, int score, ReportScoreCallback callback ) {
        if( callback == null )
            Debug.LogError( "Must pass in a non-null handler to Arbiter.ReportScore" );
        ArbiterBinding.ReportScore( competitionId, score, callback, defaultErrorHandler );
    }


	private static void pollUntilScorableCompetitionFound( string buyIn, Dictionary<string,string> filters ) {
        competitionPoller.SetAction( () => {
			Action findExistingFromCacheOrRequestNewCompetition = () => {
				Competition found = findScorableCompetition();
				Debug.Log("ttt found="+found);
				if( found != null ) {
					if( getScorableCompetitionCallback != null )
						getScorableCompetitionCallback( found );
					getScorableCompetitionCallback = null;
					competitionPoller.Stop();
				} else {
					if( competitionRequestSemaphore <= 0 ) {
						competitionRequestSemaphore += 1;
						GetScorableCompetitionCallback decSemaphore = ( ignoredComp ) => competitionRequestSemaphore -= 1;
						GetScorableCompetition( buyIn, filters, decSemaphore );
					}
					// else wait for the poller to catch the newly-requested competition!
				}
			};
			Arbiter.QueryCompetitions( findExistingFromCacheOrRequestNewCompetition );
        });
    }
    private static Competition findScorableCompetition() {
		Debug.Log("ttt findScorableCompetition()");
        IEnumerator<Competition> e = inProgressCompetitions.GetEnumerator();
        Competition found = null;
        while( e.MoveNext() ) {
            Competition c = e.Current;
			if( c.UserHasNotReportedScore( user )) {
                found = c;
                break;
            }
        }
        
        if ( found == null ) {
        	e = initializingCompetitions.GetEnumerator();
			while( e.MoveNext() ) {
				Competition c = e.Current;
				if( c.UserHasNotReportedScore( user )) {
					found = c;
					break;
				}
			}
        }

		return found;
    }


    private static void defaultErrorHandler( List<string> errors ) {
        string msg = "";
        errors.ForEach( error => msg+=error+"\n" );
        Debug.LogError( "There were problems with an Arbiter call:\n"+msg );
    }


    private static void parseLoginResponse( User responseUser, bool responseVerified, Wallet responseWallet, Action done ) {
        user = responseUser;
        verified = responseVerified? VerificationStatus.Verified : VerificationStatus.Unknown;
        wallet = responseWallet != null? responseWallet : new Wallet();
        
        walletPoller.SetAction( queryWalletIfAble );
        done();
    }



    private static Poller walletPoller;
    private static Poller competitionPoller;
    private static User user;
    private enum VerificationStatus { Unknown, Unverified, Verified };
    private static VerificationStatus verified = VerificationStatus.Unknown;
    private static Wallet wallet;
	private static List<Competition> initializingCompetitions;
    private static List<Competition> inProgressCompetitions;
    private static List<Competition> completeCompetitions;
	private static int competitionRequestSemaphore = 0;

    private static ArbiterBinding.ErrorHandler initializeErrorHandler = defaultErrorHandler;
    private static Action walletSuccessCallback;
    private static List<Action> walletQueryListeners = new List<Action>();
    private static ArbiterBinding.ErrorHandler walletErrorHandler = defaultErrorHandler;
    private static ArbiterBinding.ErrorHandler verifyUserErrorHandler = defaultErrorHandler;
    private static GetScorableCompetitionCallback getScorableCompetitionCallback;
    private static Action getCompetitionsCallback;
    private static ArbiterBinding.ErrorHandler getCompetitionsErrorHandler = defaultErrorHandler;
	private static Action viewIncompleteCompetitionsCallback;
#if UNITY_IOS
    private static ArbiterBinding.ErrorHandler loginWithGameCenterErrorHandler = defaultErrorHandler;
#endif
}
