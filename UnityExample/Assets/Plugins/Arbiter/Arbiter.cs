using UnityEngine;
using System;
using System.Collections.Generic;
using System.Linq;
using ArbiterInternal;


public delegate void SuccessHandler();
public delegate void ErrorHandler( List<string> errors );
public delegate void FriendlyErrorHandler( List<string> errors, List<string> descriptions );


public partial class Arbiter : MonoBehaviour {


	public string accessToken;
	public string gameApiKey;
	
	[HideInInspector]
	public string SelectedUnfinishedTournamentId;
	
	public static bool		IsAuthenticated				{ get { return ArbiterBinding.IsUserAuthenticated(); } }
	public static bool		IsVerified					{ get { return ArbiterBinding.IsUserVerified(); } }
	public static bool		HasWallet					{ get { return WalletExists(false); } }
	public static string    UserId                      { get { if( !UserExists ) return null;  		return user.Id; } }
	public static string    Username                    { get { if( !UserExists ) return null; 			return user.Name; } }
	public static string	AccessToken				  	{ get { if( !UserExists ) return null;  		return user.Token; } }
	public static bool		AgreedToTerms				{ get { if( !UserExists ) return false;  		return user.AgreedToTerms; } }
	public static bool		LocationApproved			{ get { if( !UserExists ) return false;  		return user.LocationApproved; } }
	public static string    Balance                     { get { if( !WalletExists(true) ) return null;	return wallet.Balance; } }



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

		ArbiterBinding.Init( _gameApiKey, _accessToken, InitializeSuccess, initializeErrorHandler );
	}
	void InitializeSuccess() {
		postInitActions.ForEach( a => a.Invoke() );
		postInitActions = null;
		initted = true;
	}
	static void WaitUntilInitted( Action a ) {
		if( initted ) {
			a.Invoke ();
		} else {
			Debug.Log( "Arbiter is not yet logged-in, queueing request Action: "+a );
			postInitActions.Add( a );
		}
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

	
	public static void Login( SuccessHandler success, ErrorHandler failure ) {
		WaitUntilInitted( () => { 
			ArbiterBinding.Login( success, failure ); 
		});
	}

	public static void LoginAsAnonymous( SuccessHandler success, ErrorHandler failure ) {
		WaitUntilInitted( () => { 
			ArbiterBinding.LoginAsAnonymous( success, failure );
		});
	}

#if UNITY_IOS
	public static void LoginWithGameCenter( SuccessHandler success, ErrorHandler failure ) {
		WaitUntilInitted( () => { 
			ArbiterBinding.LoginWithGameCenter( success, failure );
		});
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

		setupPollers();

		ArbiterBinding.Logout( success, failure );
	}


	
	public static void VerifyUser( SuccessHandler success, ErrorHandler failure ) {
		ArbiterBinding.VerifyUser( success, failure );
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


	private static bool WalletExists( bool warn ) {
		if( wallet == null ) {
			if( warn )
				Debug.LogWarning( "Wallet does not exist. Ensure that UpdateWallet was successful." );
			return false;
		}
		return true;
	}


	/// <summary>
	/// Returns a human-readable string no longer than X characters long
	/// </summary>
	public static string FormattedBalance() {
		if( !WalletExists(true) || wallet.Balance == null || wallet.Balance == "" )
			return "...";
		return FormattedLikeBalance( int.Parse( wallet.Balance ));
	}
	/// <summary>
	/// Returns a human-readable string no longer than X characters long
	/// </summary>
	public static string FormattedLikeBalance( int amount ) {
		if( amount >= 1000000000 ) {
			return ">999m";
		} else if( amount >= 1000000 ) {
			return (amount / 1000000).ToString("0.0") + "m";
		} else if( amount >= 100000 ) {
			return (amount / 1000 ).ToString("0.0") + "k";
		} else if( amount >= 1000 ) {
			return Mathf.FloorToInt(amount / 1000).ToString() + "," + (amount % 1000).ToString("000");
		} else {
			return amount.ToString();
		}
	}


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
		walletPoller.Reset();
	}
	
	
	public delegate void JoinTournamentCallback( Tournament tournament );
	public static void JoinTournament( string buyIn, Dictionary<string,string> filters, JoinTournamentCallback success, FriendlyErrorHandler failure ) {

		/* ttt keep this check clientside for now...
		if( !IsVerified ) {
			List<string> errors = new List<string>() { "The current user is not verified and cannot play in tournaments." };
			failure( errors, errors );
			return;
		}*/

		Func<Tournament,bool> isScorableByCurrentUser = ( tournament ) => {
			return (tournament.Status == Tournament.StatusType.Initializing ||
			        tournament.Status == Tournament.StatusType.InProgress) &&
			tournament.UserCanReportScore( user.Id );
		};
		
		TournamentsCallback gotTournamentsPollHelper = ( tournaments ) => {
			List<Tournament> joinableTournaments = tournaments.Where( iTourn => isScorableByCurrentUser( iTourn )).ToList();
			if( joinableTournaments.Count > 0 ) {
				tournamentPoller.Stop();
				success( joinableTournaments[0] );
			}
			// Else wait for the poller to call this anon func again...
		};
		
		int retries = 0;
		const int MAX_RETRIES = 6;
		Action askAgain = () => {
			retries++;
			if( retries > MAX_RETRIES ) {
				List<string> errors = new List<string>();
				errors.Add( "Tournament request limit exceeded. Ceasing new requests." );
				List<string> descriptions = new List<string>();
				descriptions.Add( "The tournament timed-out. Please try again later." );
				failure( errors, descriptions );
				tournamentPoller.Stop();
			} else {
				ArbiterBinding.FetchTournaments( gotTournamentsPollHelper, failure );
			}
		};
		
		SuccessHandler gotRequestResponse = () => {
			tournamentPoller.SetAction( askAgain );
		};
		
		TournamentsCallback gotTournamentsFirstTimeHelper = ( tournaments ) => {
			List<Tournament> joinableTournaments = tournaments.Where( iTourn => isScorableByCurrentUser( iTourn )).ToList();
			if( joinableTournaments.Count > 0 ) {
				success( joinableTournaments[0] );
			} else {
				RequestTournament( buyIn, filters, gotRequestResponse, failure );
			}
		};
		
		ArbiterBinding.FetchTournaments( gotTournamentsFirstTimeHelper, failure );
	}

	public static void RequestTournament( string buyIn, Dictionary<string,string> filters, SuccessHandler callback, FriendlyErrorHandler failure ) {
		if( filters == null ) {
			filters = new Dictionary<string,string>();
		}
		ArbiterBinding.RequestTournament( buyIn, filters, callback, failure );
	}
	
	
	public static void FetchTournaments( SuccessHandler success, FriendlyErrorHandler failure ) {
		fetchedTournamentsCallback = () => { 
			success();
		};
		ArbiterBinding.FetchTournaments( FetchTournamentsSuccessHandler, failure );
	}
	private static SuccessHandler fetchedTournamentsCallback;
	public delegate void TournamentsCallback( List<Tournament> tournaments );
	public static void FetchTournamentsSuccessHandler( List<Tournament> tournaments ) {
		fetchedTournamentsCallback();
	}


	public static void ShowTournamentDetails( string tournamentId, SuccessHandler callback ) {
		ArbiterBinding.ShowTournamentDetailsPanel( tournamentId, callback );
	}
	

	public static void ShowPreviousTournaments( SuccessHandler callback ) {
		ArbiterBinding.ShowPreviousTournaments( callback, defaultErrorHandler );
	}

	
	public delegate void ShowIncompleteTournamentsCallback( string tournamentId );
	public static void ShowIncompleteTournaments( ShowIncompleteTournamentsCallback callback ) {
		if( callback == null )
			callback = ( tournamentId ) => {};
		ArbiterBinding.ShowIncompleteTournaments( callback );
	}
	
	
	public delegate void ReportScoreCallback( Tournament tournament );
	public static void ReportScore( string tournamentId, int score, ReportScoreCallback callback ) {
		if( callback == null )
			Debug.LogError( "Must pass in a non-null handler to Arbiter.ReportScore" );
		ArbiterBinding.ReportScore( tournamentId, score, callback, defaultErrorHandler );
	}

	public static void ShowUnviewedTournaments( SuccessHandler callback ) {
		if( !UserExists ) {
			Debug.LogWarning( "Make sure user is logged in before showing their unviewed tournaments!" );
			return;
		}
		ArbiterBinding.ShowUnviewedTournaments( callback, defaultErrorHandler ); 
	}
	
	
	public delegate void RequestCashChallengeCallback( CashChallenge cashChallenge );
	public static void RequestCashChallenge( string entryFee, RequestCashChallengeCallback callback, FriendlyErrorHandler failure ) {
		ArbiterBinding.RequestCashChallenge( entryFee, callback, failure );
	}
	
	public static void AcceptCashChallenge( string challengeId, SuccessHandler success, FriendlyErrorHandler failure ) {
		ArbiterBinding.AcceptCashChallenge( challengeId, success, failure );
	}
	
	public static void RejectCashChallenge( string challengeId, SuccessHandler success ) {
		ArbiterBinding.RejectCashChallenge( challengeId, success );
	}
	
	public delegate void ReportScoreForChallengeCallback( CashChallenge cashChallenge );
	public static void ReportScoreForChallenge( string challengeId, string score, Arbiter.ReportScoreForChallengeCallback success, FriendlyErrorHandler failure ) {
		ArbiterBinding.ReportScoreForChallenge( challengeId, score, success, failure );
	}
	
	public static void ShowCashChallengeRules( string challengeId, SuccessHandler callback ) {
		ArbiterBinding.ShowCashChallengeRules( challengeId, callback );
	}
	
	
	public static void ShowWalkThrough( string walkThroughId, SuccessHandler callback ) {
		ArbiterBinding.ShowWalkThrough( walkThroughId, callback );
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


	/// <summary>
	/// A debug logger that adds the given custom data to some state in the SDK and logs in Arbiter debug servers.
	/// </summary>
	/// <param name="gameDataToInclude">Game data to include with the debug log report.</param>
	public static void DumpLogs( string logData ) {
		ArbiterBinding.DumpLogs( logData );
	}
	internal static void DumpLogs() {
		ArbiterBinding.DumpLogs( "" );
	}


	private static string _gameApiKey;
	private static string _accessToken;

	private static bool initted = false;
	private static List<Action> postInitActions = new List<Action>();

	private static Poller walletPoller;
	private static Poller tournamentPoller;
	internal static User user;
	internal static Wallet wallet;

	internal static List<Action> userUpdatedListeners = new List<Action>();
	internal static List<Action> newUserListeners = new List<Action>();
	internal static List<Action> walletUpdatedListeners = new List<Action>();
	private static Action walletSuccessCallback;

}
