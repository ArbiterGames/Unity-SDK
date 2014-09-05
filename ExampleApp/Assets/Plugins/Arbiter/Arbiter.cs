using UnityEngine;
using System;
using System.Collections.Generic;
using System.Linq;
using ArbiterInternal;


public delegate void SuccessHandler();
public delegate void ErrorHandler( List<string> errors );

public partial class Arbiter : MonoBehaviour
{


	public string accessToken;
	public string gameApiKey;
	
	[HideInInspector]
	public string SelectedUnfinishedTournamentId;
	
	public static bool		IsAuthenticated				{ get { return ArbiterBinding.IsUserAuthenticated(); } }
	public static bool		IsVerified					{ get { return ArbiterBinding.IsUserVerified(); } }
	public static string    UserId                      { get { if( !UserExists ) return null;  	return user.Id; } }
	public static string    Username                    { get { if( !UserExists ) return null; 		return user.Name; } }
	public static string	AccessToken				  	{ get { if( !UserExists ) return null;  	return user.Token; } }
	public static bool		AgreedToTerms				{ get { if( !UserExists ) return false;  	return user.AgreedToTerms; } }
	public static bool		LocationApproved			{ get { if( !UserExists ) return false;  	return user.LocationApproved; } }
	public static string    Balance                     { get { if( !WalletExists ) return null;	return wallet.Balance; } }



	void Awake() {
		if ( accessToken.Length == 0 || gameApiKey.Length == 0 ) {
			Debug.LogWarning( "Arbiter Error: Missing Access Token or Game Api Key in the Arbiter Prefab inpesctor settings." );
		}
		
		_accessToken = accessToken;
		_gameApiKey = gameApiKey;
		
		var arbiters = FindObjectsOfType( typeof( Arbiter ) );
		if( arbiters.Length > 1 )
		{
			Destroy( gameObject );
			return;
		}
		DontDestroyOnLoad( gameObject );
		
		
		GameObject abGO = new GameObject( "ArbiterBinding" );
		abGO.AddComponent<ArbiterBinding>();
		GameObject.DontDestroyOnLoad( abGO );
		
		wallet = null;
		user = null;
		setupPollers();

		ErrorHandler initializeErrorHandler = ( errors ) => {
			Debug.LogError( "Cannot initialize Arbiter. Resolve errors below:" );
			errors.ForEach( e => Debug.LogError( e ));
		};

		ArbiterBinding.Init( _gameApiKey, _accessToken, () => {}, initializeErrorHandler );
	}

	
#if UNITY_IOS
	public static bool OSVersionSupportsGameCenter { 
		get {
			// SystemInfo.operatingSystem returns something like iPhone OS 6.1
			float osVersion = -1f;
			string versionString = SystemInfo.operatingSystem.Replace("iPhone OS ", "");
			float.TryParse(versionString.Substring(0, 1), out osVersion);
			return osVersion >= 7;
		}
	}
#endif


	// ttt mimic format of LoginAsAnoymous...
	public static void Login( SuccessHandler success, ErrorHandler failure ) {
		/* ttt implement something like this:
		ArbiterBinding.LoginCallback parse = ( responseUser, responseVerified, responseWallet ) => {    
			parseLoginResponse( responseUser, responseVerified, responseWallet, callback );
		};
		
		ArbiterBinding.Login( parse, loginErrorHandler );
		*/
	}
	public static Action<List<string>> LoginErrorHandler { set { loginErrorHandler = ( errors ) => value( errors ); } }
	

	public static void LoginAsAnonymous( SuccessHandler success, ErrorHandler failure ) {
		ArbiterBinding.LoginAsAnonymous( success, failure );
	}

#if UNITY_IOS
	public static void LoginWithGameCenter( SuccessHandler success, ErrorHandler failure ) {
		ArbiterBinding.LoginWithGameCenter( success, failure );
	}
#endif


	public static void Logout( SuccessHandler success, ErrorHandler failure ) {
		if ( walletPoller ) {
			walletPoller.Stop();
			walletPoller = null;
		}
		
		if ( tournamentPoller ) {
			tournamentPoller.Stop();
			tournamentPoller = null;
		}
		
		wallet = null;
		user = null;

		ArbiterBinding.Logout( success, failure );
	}


	
	public static void VerifyUser( SuccessHandler success, ErrorHandler failure ) {
		ArbiterBinding.VerifyUser( success, failure );
	}
	
	public static Action<List<string>> VerifyUserErrorHandler {
		set { verifyUserErrorHandler = ( errors ) => value( errors ); }
	}
	

	private static bool UserExists { get {
		if( user == null ) {
			return false;
		}
		return true;
	} }

	public static void AddUserUpdatedListener( Action listener ) {
		if( !userUpdatedListeners.Contains( listener ))
			userUpdatedListeners.Add( listener );
	}
	public static void RemoveUserUpdatedListener( Action listener ) {
		userUpdatedListeners.Remove( listener );
	}
	public static void AddNewUserListener( Action listener ) {
		if( !newUserListeners.Contains( listener ))
			newUserListeners.Add( listener );
	}
	public static void RemoveNewUserListener( Action listener ) {
		newUserListeners.Remove( listener );
	}


	private static bool WalletExists { get {
		if( wallet == null ) {
			Debug.LogWarning( "Wallet does not exist. Ensure that UpdateWallet was successful." );
			return false;
		}
		return true;
	} }


	public static void AddWalletListener( Action listener ) {
		if( !walletUpdatedListeners.Contains( listener ))
			walletUpdatedListeners.Add( listener );
	}
	public static void RemoveWalletListener( Action listener ) {
		walletUpdatedListeners.Remove( listener );
	}
	
	public static void UpdateWallet() {
		walletPoller.Reset();
	}
	
	private static void tryFetchWallet( SuccessHandler success, ErrorHandler failure ) {
		if( !IsAuthenticated ) {
			Debug.LogWarning( "Cannot get an Arbiter Wallet without first logging in" );
			return;
		}

		ArbiterBinding.FetchWallet( success, failure );
	}


	public static void DisplayWalletDashboard( SuccessHandler callback ) {
		ArbiterBinding.ShowWalletPanel( callback );
		walletPoller.Reset();
	}
	

	public static void SendPromoCredits( string amount, SuccessHandler success, ErrorHandler failure ) {
		ArbiterBinding.SendPromoCredits( amount, success, failure );
	}
	
	public delegate void JoinTournamentCallback( Tournament tournament );
	public static void JoinTournament( string buyIn, Dictionary<string,string> filters, JoinTournamentCallback callback ) {
		
		Func<Tournament,bool> isScorableByCurrentUser = ( tournament ) => {
			return (tournament.Status == Tournament.StatusType.Initializing ||
			        tournament.Status == Tournament.StatusType.InProgress) &&
			tournament.UserCanReportScore( user.Id );
		};
		
		FetchTournamentsCallback gotTournamentsPollHelper = ( tournaments ) => {
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
				ArbiterBinding.FetchTournaments( gotTournamentsPollHelper, getTournamentsErrorHandler );
			}
		};
		
		SuccessHandler gotRequestResponse = () => {
			tournamentPoller.SetAction( askAgain );
		};
		
		FetchTournamentsCallback gotTournamentsFirstTimeHelper = ( tournaments ) => {
			List<Tournament> joinableTournaments = tournaments.Where( iTourn => isScorableByCurrentUser( iTourn )).ToList();
			if( joinableTournaments.Count > 0 ) {
				callback( joinableTournaments[0] );
			} else {
				RequestTournament( buyIn, filters, gotRequestResponse );
			}
		};
		
		ArbiterBinding.FetchTournaments( gotTournamentsFirstTimeHelper, getTournamentsErrorHandler );
	}
	public static Action<List<string>> JoinTournamentErrorHandler { set { getTournamentsErrorHandler = ( errors ) => value( errors ); } }
	

	public static void RequestTournament( string buyIn, Dictionary<string,string> filters, SuccessHandler callback ) {
		if( filters == null ) {
			filters = new Dictionary<string,string>();
		}
		ArbiterBinding.RequestTournament( buyIn, filters, callback, requestTournamentErrorHandler );
	}
	public static Action<List<string>> RequestTournamentErrorHandler { set { requestTournamentErrorHandler = ( errors ) => value( errors ); } }
	
	
	public static void FetchTournaments( Action callback ) {
		getTournamentsCallback = callback;
		ArbiterBinding.FetchTournaments( FetchTournamentsSuccessHandler, getTournamentsErrorHandler );
	}
	
	public delegate void FetchTournamentsCallback( List<Tournament> tournaments );
	public static void FetchTournamentsSuccessHandler( List<Tournament> tournaments ) {
		initializingTournaments = tournaments.Where( c => c.Status == Tournament.StatusType.Initializing ).ToList();
		inProgressTournaments = tournaments.Where( c => c.Status == Tournament.StatusType.InProgress ).ToList();
		completeTournaments = tournaments.Where( c => c.Status == Tournament.StatusType.Complete ).ToList();
		getTournamentsCallback();
	}
	
	public static void DisplayTournamentDetails( string tournamentId, SuccessHandler callback ) {
		ArbiterBinding.ShowTournamentDetailsPanel( tournamentId, callback );
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

	public static void ViewPreviousTournaments( SuccessHandler callback ) {
		if( callback == null )
			callback = () => {};
		ArbiterBinding.ViewPreviousTournaments( callback, defaultErrorHandler );
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
	
	private static void setupPollers() {
		if ( !walletPoller ) {
			walletPoller = Poller.Create( "ArbiterWalletPoller" );
			DontDestroyOnLoad( walletPoller.gameObject );
			walletPoller.Verbose = false;
			walletPoller.SetAction( () => tryFetchWallet( 
				() => {}, 
				(errors) => errors.ForEach( e=>Debug.Log(e) ) )
			);
		}
		if ( !tournamentPoller ) {
			tournamentPoller = Poller.Create( "ArbiterTournamentPoller" );
			DontDestroyOnLoad( tournamentPoller.gameObject );
			tournamentPoller.Verbose = true;
		}
	}

	// ttt kill
	private static void parseLoginResponse( User responseUser, bool responseVerified, Wallet responseWallet, Action done ) {
		user = responseUser;
		wallet = responseWallet != null? responseWallet : null;
		setupPollers();
		done();
	}


	
	private static string _gameApiKey;
	private static string _accessToken;
	private static Poller walletPoller;
	private static Poller tournamentPoller;
	internal static User user;
	internal static Wallet wallet;
	private static List<Tournament> initializingTournaments; // ttt these still used??
	private static List<Tournament> inProgressTournaments;
	private static List<Tournament> completeTournaments;
	
//	private static ErrorHandler initializeErrorHandler = defaultErrorHandler; // ttt kill the unused handlers!
	private static ErrorHandler loginErrorHandler = defaultErrorHandler;
	private static ErrorHandler loginAsAnonymousErrorHandler = defaultErrorHandler;
	internal static List<Action> userUpdatedListeners = new List<Action>();
	internal static List<Action> newUserListeners = new List<Action>();
	internal static List<Action> walletUpdatedListeners = new List<Action>();
	private static Action walletSuccessCallback;
//	private static List<Action> walletQueryListeners = new List<Action>();
//	private static ErrorHandler walletErrorHandler = defaultErrorHandler;
	private static ErrorHandler verifyUserErrorHandler = defaultErrorHandler;
	private static Action getTournamentsCallback;
	private static ErrorHandler getTournamentsErrorHandler = defaultErrorHandler;
	private static ErrorHandler requestTournamentErrorHandler = defaultErrorHandler;
	#if UNITY_IOS
	private static ErrorHandler loginWithGameCenterErrorHandler = defaultErrorHandler;
	#endif

}
