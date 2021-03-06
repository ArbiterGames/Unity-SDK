using UnityEngine;
using System;
using System.Collections.Generic;
using System.Linq;
using ArbiterInternal;


public delegate void SuccessHandler();
public delegate void ErrorHandler( List<string> errors );
public delegate void FriendlyErrorHandler( List<string> errors, List<string> descriptions );
public delegate void CodedErrorHandler( List<string> errorCodes, List<string> errors, List<string> descriptions );


public partial class Arbiter : MonoBehaviour {


	public string accessToken;
	public string gameApiKey;

	/// <summary>True when the SDK knows which user is playing.</summary><remarks>Might be too slow to call this each frame.</remarks>
	public static bool		IsAuthenticated				{ get { return ArbiterBinding.IsUserAuthenticated(); } }
	/// <summary>True when the authenticated user is able to participate in cash contests.</summary><remarks>Might be too slow to call this each frame.</remarks>
	public static bool		IsVerified					{ get { return ArbiterBinding.IsUserVerified(); } }
	public static bool		HasWallet					{ get { return WalletExists(false); } }
	public static string    UserId                      { get { if( !UserExists ) return null;  		return user.Id; } }
	public static string    Username                    { get { if( !UserExists ) return null; 			return user.Name; } }
	public static string	AccessToken				  	{ get { if( !UserExists ) return null;  		return user.Token; } }
	public static bool		AgreedToTerms				{ get { if( !UserExists ) return false;  		return user.AgreedToTerms; } }
	public static bool		LocationApproved			{ get { if( !UserExists ) return false;  		return user.LocationApproved; } }
	public static string    Balance                     { get { if( !WalletExists(true) ) return null;	return wallet.Balance; } }



	void Start() {
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

		ErrorHandler initializeErrorHandler = ( errors ) => {
			Debug.LogError( "Cannot initialize Arbiter. Resolve errors below:" );
			errors.ForEach( e => Debug.LogError( e ));
		};

		ArbiterBinding.Init( _gameApiKey, _accessToken, InitializeSuccess, initializeErrorHandler );
	}
	void InitializeSuccess() {
		Debug.Log( "Arbiter initialized. Invoking queued actions. (Post-Init:"+postInitActions.Count+", Post-Auth:"+postAuthenticateActions.Count+")" );
		FireAndForget( postInitActions );
		FirePostAuthenticateActionsIfAble();
		initted = true;

		setupPollers();
	}
	static void WaitUntilInitted( Action a ) {
		if( initted ) {
			a.Invoke();
		} else {
			Debug.Log( "Arbiter is not yet logged-in, queueing request Action: "+a );
			postInitActions.Add( a );
		}
	}
	static void FireAndForget( List<Action> list ) {
		var count = list.Count;
		for( int i=0; i<count; i++ ) {
			if( list[i] != null )
				list[i].Invoke();
		}
		list.Clear();
	}
	static void FirePostAuthenticateActionsIfAble() {
		if( IsAuthenticated ) {
			Debug.Log( "Firing Post-Auth actions ("+postAuthenticateActions.Count+")" );
			FireAndForget( postAuthenticateActions );
		} else {
			Debug.Log( "Waiting to fire Post-Auth actions ("+postAuthenticateActions.Count+")" );
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

	/// <summary>
	/// This is only necessary to call if there is no cached user credentials on device. But calling it redundantly is harmless.
	/// </summary>
	public static void LoginWithDeviceId( SuccessHandler success, ErrorHandler failure ) {
		SuccessHandler successWrapper = () => {
			FirePostAuthenticateActionsIfAble();
			if( success != null )
				success();
		};
		WaitUntilInitted( () => { 
			ArbiterBinding.LoginWithDeviceId( successWrapper, failure );
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
		wallet = null;
		user = null;
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


	/// <summary>
	/// Fires once on the first time authentication is successful
	/// </summary>
	/// <param name="listener">Listener.</param>
	public static void DoOnceOnAuthenticated( Action listener ) {
		if( !postAuthenticateActions.Contains( listener ))
			postAuthenticateActions.Add( listener );
	}
	/// <summary>
	/// For when the currently-authenticated user updates a piece of his/her info
	/// </summary>
	public static void AddUserUpdatedListener( Action listener ) {
		if( !userUpdatedListeners.Contains( listener ))
			userUpdatedListeners.Add( listener );
	}
	public static void RemoveUserUpdatedListener( Action listener ) {
		userUpdatedListeners.Remove( listener );
	}
	/// <summary>
	/// For when a new or different user just authenticated
	/// </summary>
	public static void AddUserChangedListener( Action listener ) {
		if( !userChangedListeners.Contains( listener ))
			userChangedListeners.Add( listener );
	}
	public static void RemoveUserChangedListener( Action listener ) {
		userChangedListeners.Remove( listener );
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


	/// <summary>
	/// Assuming your Arbiter credits are worth exactly 1 US-Cent, return a format like typical US currency (eg $12.34)
	/// </summary>
	/// <returns>The balance as usd.</returns>
	public static string FormattedBalanceAsUsd() {
		if( !WalletExists(true) || wallet.Balance == null || wallet.Balance == "" )
			return "...";
		return String.Format( "{0:C}", float.Parse( wallet.Balance ) / 100f );
	}


	public static void AddWalletListener( Action listener ) {
		if( !walletUpdatedListeners.Contains( listener ))
			walletUpdatedListeners.Add( listener );
	}
	public static void RemoveWalletListener( Action listener ) {
		walletUpdatedListeners.Remove( listener );
	}
	
	public static void UpdateWallet() {
		if( walletPoller != null )
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
	
	public static void DisplayWalletDashboardOnDepositTab( SuccessHandler callback ) {
		ArbiterBinding.ShowWalletPanelOnDepositTab( callback );
		walletPoller.Reset();
	}
	

	public static void SendPromoCredits( string amount, SuccessHandler success, ErrorHandler failure ) {
		ArbiterBinding.SendPromoCredits( amount, success, failure );
		walletPoller.Reset();
	}
	
	
	public delegate void JoinTournamentCallback( Tournament tournament );
	public static void JoinTournament( string buyIn, Dictionary<string,string> filters, JoinTournamentCallback success, FriendlyErrorHandler failure ) {

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
	public static void RequestCashChallenge( Dictionary<string,string> filters, RequestCashChallengeCallback callback, FriendlyErrorHandler failure ) {
		if( filters == null ) {
			filters = new Dictionary<string,string>();
		}
		ArbiterBinding.RequestCashChallenge( filters, callback, failure );
	}

	public static void AcceptCashChallengeUseNativeErrorDialogue( string challengeId, SuccessHandler success, SuccessHandler errorDialogueComplete ) {
		nativeDialogCallback = errorDialogueComplete;
		ArbiterBinding.AcceptCashChallenge( challengeId, success, ShowDescriptionInNativeAlert );
	}
	public static void AcceptCashChallenge( string challengeId, SuccessHandler success, FriendlyErrorHandler failure ) {
		CodedErrorHandler failWrapper = ( c,e,d ) => { failure( e,d ); };
		ArbiterBinding.AcceptCashChallenge( challengeId, success, failWrapper );
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


	
	private static SuccessHandler nativeDialogCallback;
	private static void ShowDescriptionInNativeAlert( List<string> errorCodes, List<string> errors, List<string> descriptions ) {
		string msg = "";
		for( int i=0; errors != null && i<errors.Count; i++ ) {
			Debug.LogError( errors[0] );
			msg = errors[i];
		}
		if( descriptions != null ) {
			msg = descriptions[0];
		}
		if( errorCodes != null ) {
			// NOTE: the ActionFor function should put the current callback into a wrapper/cb so it's OK to re-assign the nativeDialogCallback here
			nativeDialogCallback = ArbiterErrorCodes.ActionFor( errorCodes[0], nativeDialogCallback );
		}
		ShowNativeDialog( "ERROR", msg );
	}
	private static void ShowNativeDialog( string title, string message ) {
		ArbiterBinding.ShowNativeDialog( title, message, nativeDialogCallback );
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


	#region Hooks for testing
	[HideInInspector]
	public string SelectedUnfinishedTournamentId;
	#endregion

	private static string _gameApiKey;
	private static string _accessToken;

	private static bool initted = false;
	private static List<Action> postInitActions = new List<Action>();
	private static List<Action> postAuthenticateActions = new List<Action>();

	private static Poller walletPoller;
	private static Poller tournamentPoller;
	internal static User user;
	internal static Wallet wallet;

	internal static List<Action> userUpdatedListeners = new List<Action>();
	internal static List<Action> userChangedListeners = new List<Action>();
	internal static List<Action> walletUpdatedListeners = new List<Action>();
	private static Action walletSuccessCallback;

}
