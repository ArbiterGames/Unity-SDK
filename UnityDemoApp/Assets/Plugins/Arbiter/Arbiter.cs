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
		GameObject.DontDestroyOnLoad( go );
        wallet = new Wallet();
        user = new User();

		walletPoller = Poller.Create( "ArbiterWalletPoller" );
		tournamentPoller = Poller.Create( "ArbiterTournamentPoller" );
		DontDestroyOnLoad( walletPoller.gameObject );
		DontDestroyOnLoad( tournamentPoller.gameObject );
		walletPoller.Verbose = false;
		tournamentPoller.Verbose = true;
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


	/// <summary>
	/// Deletes cached user, wallet, and tournament data and returns Arbiter back to an un-initialized state
	/// </summary>
//	public static void Logout( Action done ) {
//		// Setup ArbiterBinding Function
//	}


    public static void VerifyUser( Action done ) {
        ArbiterBinding.VerifyUserCallback parse = ( response ) => {
        	Debug.Log ("VerifyUserCallback response");
        	Debug.Log (response);
        	
            if( response == true )
                verified = VerificationStatus.Verified;
            if( done != null )
                done();
        };
        verified = VerificationStatus.Unverified;
        ArbiterBinding.VerifyUser( parse, verifyUserErrorHandler );
    }
    public static Action<List<string>> VerifyUserErrorHandler { set { verifyUserErrorHandler = ( errors ) => value( errors ); } }
    
    
	/// <summary>
	/// Removes the cached user and wallet and deletes the user's access token
	/// </summary>
	public static void Logout( Action callback ) {
		logoutSuccessCallback = callback;
		ArbiterBinding.LogoutCallback parse = () => {
			walletPoller.Stop();
			tournamentPoller.Stop();
			
			if ( callback != null ) 
				callback();
		};
		ArbiterBinding.Logout( logoutSuccessHandler );
	}
//	public static Action<List<string>> LogoutErrorHandler { set { logoutErrorHandler = ( errors ) => value( errors ); } }
	private static void logoutSuccessHandler( ) {
		if ( logoutSuccessCallback != null ) 
			logoutSuccessCallback();
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

	
	public delegate void GetTournamentCallback( Tournament tournament );
	/// <summary>
	/// Finds an existing tournament that you could join. If no available tournaments are found, requests a new one and returns that.
	/// </summary>
	public static void GetTournament( string buyIn, Dictionary<string,string> filters, GetTournamentCallback callback ) {
		Func<Tournament,bool> isScorableByCurrentUser = ( tournament ) => {
			return (tournament.Status == Tournament.StatusType.Initializing || tournament.Status == Tournament.StatusType.InProgress) &&
			tournament.UserCanReportScore( user );
		};

		GetTournamentsCallback gotTournamentsPollHelper = ( tournaments ) => {
			List<Tournament> joinableTournaments = tournaments.Where( iTourn => isScorableByCurrentUser( iTourn )).ToList();
			if( joinableTournaments.Count > 0 ) {
				tournamentPoller.Stop();
				callback( joinableTournaments[0] );
			}
			// Else wait for the poller to call this anon func again...
		};

		int retries = 0;
		const int MAX_RETRIES = 10;
		Action askAgain = () => {
			retries++;
			if( retries > MAX_RETRIES ) {
				List<string> errors = new List<string>();
				errors.Add( "Tournament request limit exceeded. Ceasing new requests." );
				getTournamentsErrorHandler( errors );
				tournamentPoller.Stop();
			} else {
				ArbiterBinding.GetTournaments( gotTournamentsPollHelper, getTournamentsErrorHandler );
			}
		};
		
		RequestTournamentCallback gotRequestResponse = () => {
			tournamentPoller.SetAction( askAgain );
		};

		GetTournamentsCallback gotTournamentsFirstTimeHelper = ( tournaments ) => {
			List<Tournament> joinableTournaments = tournaments.Where( iTourn => isScorableByCurrentUser( iTourn )).ToList();
			if( joinableTournaments.Count > 0 ) {
				callback( joinableTournaments[0] );
			} else {
				RequestTournament( buyIn, filters, gotRequestResponse );
			}
		};

		ArbiterBinding.GetTournaments( gotTournamentsFirstTimeHelper, getTournamentsErrorHandler );
    }


	public delegate void RequestTournamentCallback();
	/// <summary>
	/// Requests a new Tournament.
	/// </summary>
	public static void RequestTournament( Dictionary<string,string> filters, RequestTournamentCallback callback ) {
		RequestTournament( null, filters, callback );
	}
	public static void RequestTournament( string buyIn, Dictionary<string,string> filters, RequestTournamentCallback callback ) {
		if( filters == null ) {
			filters = new Dictionary<string,string>();
		}
		ArbiterBinding.RequestTournament( buyIn, filters, callback, defaultErrorHandler );
	}



	/// <summary>
	/// Asks the server for a list of tournaments in various stages.
	/// </summary>
	public static void QueryTournaments( Action callback ) {
		getTournamentsCallback = callback;
		ArbiterBinding.GetTournaments( GetTournamentsSuccessHandler, getTournamentsErrorHandler );
	}
	public delegate void GetTournamentsCallback( List<Tournament> tournaments );
	public static void GetTournamentsSuccessHandler( List<Tournament> tournaments ) {
		initializingTournaments = tournaments.Where( c => c.Status == Tournament.StatusType.Initializing ).ToList();
		inProgressTournaments = tournaments.Where( c => c.Status == Tournament.StatusType.InProgress ).ToList();
		completeTournaments = tournaments.Where( c => c.Status == Tournament.StatusType.Complete ).ToList();
		getTournamentsCallback();
	}

	public static List<Tournament> InitializingTournaments {
		get {
			return initializingTournaments;
		}
	}
	public static List<Tournament> InProgressTournaments {
		get {
			return inProgressTournaments;
		}
	}
	public static List<Tournament> CompleteTournaments {
		get {
			return completeTournaments;
		}
	}


	public delegate void ViewPreviousTournamentsCallback();
	public static void ViewPreviousTournaments( ViewPreviousTournamentsCallback callback ) {
		if( callback == null )
		callback = () => {};
		ArbiterBinding.ViewPreviousTournaments( callback );
	}
    
    
	public delegate void ViewIncompleteTournamentsCallback( string tournamentId );
	public static void ViewIncompleteTournaments( ViewIncompleteTournamentsCallback callback ) {
		if( callback == null )
		callback = ( String tournamentId ) => {};
		ArbiterBinding.ViewIncompleteTournaments( callback );
	}


	public delegate void ReportScoreCallback( Tournament tournament );
	public static void ReportScore( string tournamentId, int score, ReportScoreCallback callback ) {
		if( callback == null )
			Debug.LogError( "Must pass in a non-null handler to Arbiter.ReportScore" );
		ArbiterBinding.ReportScore( tournamentId, score, callback, defaultErrorHandler );
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
    private static Poller tournamentPoller;
    private static User user;
    private enum VerificationStatus { Unknown, Unverified, Verified };
    private static VerificationStatus verified = VerificationStatus.Unknown;
    private static Wallet wallet;
	private static List<Tournament> initializingTournaments;
	private static List<Tournament> inProgressTournaments;
	private static List<Tournament> completeTournaments;

    private static ArbiterBinding.ErrorHandler initializeErrorHandler = defaultErrorHandler;
    private static Action walletSuccessCallback;
    private static List<Action> walletQueryListeners = new List<Action>();
    private static ArbiterBinding.ErrorHandler walletErrorHandler = defaultErrorHandler;
	private static Action logoutSuccessCallback;
    private static ArbiterBinding.ErrorHandler verifyUserErrorHandler = defaultErrorHandler;
	private static Action getTournamentsCallback;
	private static ArbiterBinding.ErrorHandler getTournamentsErrorHandler = defaultErrorHandler;
	private static Action viewIncompleteTournamentsCallback;
#if UNITY_IOS
    private static ArbiterBinding.ErrorHandler loginWithGameCenterErrorHandler = defaultErrorHandler;
#endif
}
