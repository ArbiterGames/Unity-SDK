using UnityEngine;
using System;
using System.Linq;
using System.Collections;
using System.Collections.Generic;
using System.Runtime.InteropServices;
using SimpleJSON;


namespace ArbiterInternal {

	public class ArbiterBinding : MonoBehaviour
	{


#region Shared data
		
		[DllImport ("__Internal")]
		private static extern bool _isUserVerified();
		public static bool IsUserVerified() {
#if UNITY_EDITOR
			return true;
#elif UNITY_IOS
			return _isUserVerified();
#endif
		}


		[DllImport ("__Internal")]
		private static extern bool _isUserAuthenticated();
		public static bool IsUserAuthenticated() {
#if UNITY_EDITOR
			return Arbiter.UserId != null;
#elif UNITY_IOS
			return _isUserAuthenticated();
#endif
		}


		/// <summary>
		/// Handler for native to call whenever it updates its user
		/// </summary>
		public void OnUserUpdated( string jsonString ) {
			if( UserProtocol.Update( ref Arbiter.user, jsonString )) {
				Arbiter.userUpdatedListeners.ForEach( listener => listener() );
			} else {
				Arbiter.user = UserProtocol.Parse( jsonString );
				Arbiter.newUserListeners.ForEach( listener => listener() );
			}
		}


		/// <summary>
		/// Handler for native to call whenever it updates its wallet
		/// </summary>
		public void OnWalletUpdated( string jsonString ) {
			if( Arbiter.wallet == null )
				Arbiter.wallet = new Wallet();
			WalletProtocol.Update( ref Arbiter.wallet, jsonString );
			Arbiter.walletUpdatedListeners.ForEach( listener => listener() );
		}
		
#endregion


		const string INIT = "init";
		[DllImport ("__Internal")]
		private static extern void _init( string gameApiKey, string accessToken );
		public static void Init( string gameApiKey, string accessToken, SuccessHandler success, ErrorHandler failure ) {
			SetCallbacksWithErrors( INIT, success, failure );
#if UNITY_EDITOR
			ReportIgnore( "Initialize" );
			success();
#elif UNITY_IOS
			_init( gameApiKey, accessToken );
#endif
		}
		

		const string LOGIN_ANONYMOUS = "login_anon";
		[DllImport ("__Internal")]
		private static extern void _loginAsAnonymous();
		public static void LoginAsAnonymous( SuccessHandler success, ErrorHandler failure ) {
			SetCallbacksWithErrors( LOGIN_ANONYMOUS, success, failure );
#if UNITY_EDITOR
			ReportIgnore( "Login:Anonymous" );
			User user = new User();
			user.Id = "FakeId123";
			user.Name = "Anonymock";
			Arbiter.user = user;
			success();
#elif UNITY_IOS
			_loginAsAnonymous();
#endif
		}
		

		const string LOGIN_GAME_CENTER = "login_game_center";
		[DllImport ("__Internal")]
		private static extern void _loginWithGameCenterPlayer();
		public static void LoginWithGameCenter( SuccessHandler success, ErrorHandler failure ) {
			SetCallbacksWithErrors( LOGIN_GAME_CENTER, success, failure );
#if UNITY_EDITOR
			ReportIgnore( "Login:GameCenter" );
			User user = new User();
			user.Id = "FakeGcId";
			user.Name = "GameOckUser";
			Arbiter.user = user;
			success();
#elif UNITY_IOS
			_loginWithGameCenterPlayer();
#endif
		}
		

		const string LOGIN = "login";
		[DllImport ("__Internal")]
		private static extern void _login();
		public static void Login( SuccessHandler success, ErrorHandler failure ) {
			SetCallbacksWithErrors( LOGIN, success, failure );
#if UNITY_EDITOR
			ReportIgnore( "Login:BasicAuth" );
			User user = new User();
			user.Id = "UserPass_ID";
			user.Name = "McMockison";
			success();
#elif UNITY_IOS
			_login();
#endif
		}
		

		const string LOGOUT = "logout";
		[DllImport ("__Internal")]
		private static extern void _logout();
		public static void Logout( SuccessHandler success, ErrorHandler failure ) {
			SetCallbacksWithErrors( LOGOUT, success, failure );
#if UNITY_EDITOR
			ReportIgnore( "Logout" );
			success();
#elif UNITY_IOS
			_logout();
#endif
		}
		

		const string VERIFY = "verify";
		[DllImport ("__Internal")]
		private static extern void _verifyUser();
		public static void VerifyUser( SuccessHandler success, ErrorHandler failure ) {
			SetCallbacksWithErrors( VERIFY, success, failure );
#if UNITY_EDITOR
			ReportIgnore( "VerifyUser" );
			User user = new User();
			user.Id = "FakeId123";
			user.Name = "McMockison";
			user.LocationApproved = true;
			user.AgreedToTerms = true;
			success();
#elif UNITY_IOS
			_verifyUser();
#endif
		}
		

		const string FETCH_WALLET = "fetch_wallet";
		[DllImport ("__Internal")]
		private static extern void _fetchWallet();
		public static void FetchWallet( SuccessHandler success, ErrorHandler failure ) {
			callbacks[ FETCH_WALLET ] = new CallbackTuple( success, failure, ( e,d ) => {} );
#if UNITY_EDITOR
			ReportIgnore( "FetchWallet" );
			Arbiter.wallet = new Wallet();
			Arbiter.wallet.Balance = "12345";
			success();
#elif UNITY_IOS
			_fetchWallet();
#endif
		}
		

		const string SHOW_WALLET_PANEL = "wallet_panel";
		[DllImport ("__Internal")]
		private static extern void _showWalletPanel();
		public static void ShowWalletPanel( SuccessHandler callback ) {
			SetSimpleCallback( SHOW_WALLET_PANEL, callback );
#if UNITY_EDITOR
			ReportIgnore( "ShowWallet" );
			if( callback != null )
				callback();
#elif UNITY_IOS
			_showWalletPanel();
#endif
		}


		const string SEND_PROMO_CREDITS = "send_promo";
		[DllImport ("__Internal")]
		private static extern void _sendPromoCredits( string amount );
		public static void SendPromoCredits( string amount, SuccessHandler success, ErrorHandler failure ) {
			SetCallbacksWithErrors( SEND_PROMO_CREDITS, success, failure );
#if UNITY_EDITOR
			ReportIgnore( "SendPromoCredits" );
			if( success != null )
				success();
#elif UNITY_IOS
			_sendPromoCredits( amount );
#endif
		}
		

		const string REQUEST_TOURNAMENT = "request_tournament";
		[DllImport ("__Internal")]
		private static extern void _requestTournament( string buyIn, string filters );
		public static void RequestTournament( string buyIn, Dictionary<string,string> filters, SuccessHandler success, FriendlyErrorHandler failure ) {
			SetCallbacksWithFriendlyErrors( REQUEST_TOURNAMENT, success, failure );
#if UNITY_EDITOR
			ReportIgnore( "RequestTournament" );
			if( success != null )
				success();
#elif UNITY_IOS
			_requestTournament( buyIn, SerializeDictionary(filters) );
#endif
		}


		const string SHOW_TOURNAMENT_PANEL = "show_tournament_panel";
		[DllImport ("__Internal")]
		private static extern void _showTournamentDetailsPanel( string tournamentId);
		public static void ShowTournamentDetailsPanel( string tournamentId, SuccessHandler callback ) {
			SetSimpleCallback( SHOW_TOURNAMENT_PANEL, callback );
#if UNITY_EDITOR
			ReportIgnore( "ShowTournamentDetailsPanel" );
			if( callback != null )
				callback();
#elif UNITY_IOS
			_showTournamentDetailsPanel( tournamentId );
#endif
		}
		

		const string FETCH_TOURNAMENTS = "fetch_tourn";
		[DllImport ("__Internal")]
		private static extern void _fetchTournaments();
		private static Arbiter.TournamentsCallback fetchTournamentsSuccessHandler;
		private static FriendlyErrorHandler fetchTournamentsErrorHandler;
		public static void FetchTournaments( Arbiter.TournamentsCallback success, FriendlyErrorHandler failure ) {
			fetchTournamentsSuccessHandler = success;
			fetchTournamentsErrorHandler = failure;
#if UNITY_EDITOR
			ReportIgnore( "FetchTournaments" );
			List<Arbiter.Tournament> fakeTournaments = new List<Arbiter.Tournament>();
			fetchTournamentsSuccessHandler( fakeTournaments );
#elif UNITY_IOS
			_fetchTournaments();
#endif
		}
		

		const string SHOW_PREIVOUS_TOURNAMENTS = "show_prev_tourn";
		[DllImport ("__Internal")]
		private static extern void _showPreviousTournaments();
		public static void ShowPreviousTournaments( SuccessHandler success, ErrorHandler failure ) {
			SetCallbacksWithErrors( SHOW_PREIVOUS_TOURNAMENTS, success, failure );
#if UNITY_EDITOR
			ReportIgnore( "ViewPreviousTournaments" );
			success();
#elif UNITY_IOS
			_showPreviousTournaments();
#endif
		}
		
		
		[DllImport ("__Internal")]
		private static extern void _showIncompleteTournaments();
		private static Arbiter.ShowIncompleteTournamentsCallback showIncompleteTournamentsCallback;
		public static void ShowIncompleteTournaments( Arbiter.ShowIncompleteTournamentsCallback callback ) {
			showIncompleteTournamentsCallback = callback;
#if UNITY_EDITOR
			ReportIgnore( "ShowIncompleteTournaments" );
			showIncompleteTournamentsCallback( "" );
#elif UNITY_IOS
			_showIncompleteTournaments();
#endif
		}
		
		const string SHOW_UNVIEWED_TOURNAMENTS = "show_unviewed_tourn";
		[DllImport ("__Internal")]
		private static extern void _showUnviewedTournaments();
		public static void ShowUnviewedTournaments( SuccessHandler success, ErrorHandler failure ) {
			SetCallbacksWithErrors( SHOW_UNVIEWED_TOURNAMENTS, success, failure );
#if UNITY_EDITOR
			ReportIgnore( "ShowUnviewedTournaments" );
			success();
#elif UNITY_IOS
			_showUnviewedTournaments();
#endif
		}


		[DllImport ("__Internal")]
		private static extern void _fetchUnviewedTournaments();
		private static Arbiter.TournamentsCallback fetchUnviewedTournamentsSuccessHandler;
		private static ErrorHandler fetchUnviewedTournamentsErrorHandler;
		public static void FetchUnviewedTournaments( Arbiter.TournamentsCallback success, ErrorHandler failure ) {
			fetchUnviewedTournamentsSuccessHandler = success;
			fetchUnviewedTournamentsErrorHandler = failure;
#if UNITY_EDITOR
			ReportIgnore( "FetchUnviewedTournaments" );
			List<Arbiter.Tournament> fakeTournaments = new List<Arbiter.Tournament>();
			fetchUnviewedTournamentsSuccessHandler( fakeTournaments );
#elif UNITY_IOS
			_fetchUnviewedTournaments();
#endif
		}
		

		const string REPORT_SCORE = "report_score";
		[DllImport ("__Internal")]
		private static extern void _reportScore( string tournamentId, string score );
		private static Arbiter.ReportScoreCallback reportScoreSuccessHandler;
		private static ErrorHandler reportScoreErrorHandler;
		public static void ReportScore( string tournamentId, int score, Arbiter.ReportScoreCallback success, ErrorHandler failure ) {
			reportScoreSuccessHandler = success;
			reportScoreErrorHandler = failure;
#if UNITY_EDITOR
			ReportIgnore( "ReportScore" );
			reportScoreSuccessHandler( new Arbiter.Tournament( "1234", Arbiter.Tournament.StatusType.Initializing, new List<Arbiter.TournamentUser>(), new List<string>() ));
#elif UNITY_IOS
			_reportScore( tournamentId, score.ToString() );
#endif
		}



// TODO: This still needs to be implemented on the obj-c side
//		const string MARK_VIEWED_TOURNAMENT = "mark_view_tourn";
//		[DllImport ("__Internal")]
//		private static extern void _markViewedTournament( string tournamentId );
//		public static void MarkViewedTournament( string tournamentId, ErrorHandler failure ) {
//			SetCallbacksWithErrors( MARK_VIEWED_TOURNAMENT, null, failure );
//#if UNITY_EDITOR
//			ReportIgnore( "MarkViewedTournament" );
//#elif UNITY_IOS
//			_markViewedTournament( tournamentId );
//#endif
//		}


		[DllImport ("__Internal")]
		private static extern void _requestCashChallenge( string filters );
		private static Arbiter.RequestCashChallengeCallback requestCashChallengeSuccessHandler;
		private static FriendlyErrorHandler requestCashChallengeErrorHandler;
		public static void RequestCashChallenge( Dictionary<string,string> filters, Arbiter.RequestCashChallengeCallback success, FriendlyErrorHandler failure ) {
			requestCashChallengeSuccessHandler = success;
			requestCashChallengeErrorHandler = failure;
#if UNITY_EDITOR
			ReportIgnore( "RequestCashChallenge" );
			if( success != null )
				success( new Arbiter.CashChallenge( "1234", "55", "100", "200", Arbiter.CashChallenge.StatusType.Busy, null ));
#elif UNITY_IOS
			_requestCashChallenge( SerializeDictionary(filters) );
#endif
		}
		
		
		const string ACCEPT_SCORE_CHALLENGE = "accept_cash_challenge";
		[DllImport ("__Internal")]
		private static extern void _acceptCashChallenge( string challengeId );
		public static void AcceptCashChallenge( string challengeId, SuccessHandler success, FriendlyErrorHandler failure ) {
			SetCallbacksWithFriendlyErrors( ACCEPT_SCORE_CHALLENGE, success, failure );
#if UNITY_EDITOR
			ReportIgnore( "AcceptCashChallenge" );
#elif UNITY_IOS
			_acceptCashChallenge( challengeId );
#endif
		}
		
		
		const string REJECT_SCORE_CHALLENGE = "reject_cash_challenge";
		[DllImport ("__Internal")]
		private static extern void _rejectCashChallenge( string challengeId );
		public static void RejectCashChallenge( string challengeId, SuccessHandler callback ) {
			SetSimpleCallback( REJECT_SCORE_CHALLENGE, callback );
#if UNITY_EDITOR
			ReportIgnore( "RejectCashChallenge" );
			if( callback != null )
				callback();
#elif UNITY_IOS
			_rejectCashChallenge( challengeId );
#endif
		}
		
		
		
		[DllImport ("__Internal")]
		private static extern void _reportScoreForChallenge( string challengeId, string score );
		private static Arbiter.ReportScoreForChallengeCallback reportScoreForChallengeSuccessHandler;
		private static FriendlyErrorHandler reportScoreForChallengeErrorHandler;
		public static void ReportScoreForChallenge( string challengeId, string score, Arbiter.ReportScoreForChallengeCallback success, FriendlyErrorHandler failure ) {
			reportScoreForChallengeSuccessHandler = success;
			reportScoreForChallengeErrorHandler = failure;
#if UNITY_EDITOR
			ReportIgnore( "ReportScoreForChallenge" );
#elif UNITY_IOS
			_reportScoreForChallenge( challengeId, score );
#endif
		}
		
		
		const string SHOW_SCORE_CHALLENGE_RULES = "show_cash_challenge_rules";
		[DllImport ("__Internal")]
		private static extern void _showCashChallengeRules( string challengeId );
		public static void ShowCashChallengeRules( string challengeId, SuccessHandler callback ) {
			SetCallbacksWithErrors( SHOW_SCORE_CHALLENGE_RULES, callback, null );
#if UNITY_EDITOR
			ReportIgnore( "ShowCashChallengeRules" );
#elif UNITY_IOS
			_showCashChallengeRules( challengeId );
#endif
		}
		
		
		
		const string SHOW_WALK_THROUGH = "show_walk_through";
		[DllImport ("__Internal")]
		private static extern void _showWalkThrough( string walkThroughId );
		public static void ShowWalkThrough( string walkThroughId, SuccessHandler callback ) {
			SetCallbacksWithErrors( SHOW_WALK_THROUGH, callback, null );
#if UNITY_EDITOR
			ReportIgnore( "ShowWalkThrough" );
#elif UNITY_IOS
			_showWalkThrough( walkThroughId );
#endif
		}


		[DllImport ("__Internal")]
		private static extern void _dumpLogs( string logData );
		public static void DumpLogs( string logData ) {
#if UNITY_EDITOR
			ReportIgnore( "DumpLogs" );
#elif UNITY_IOS
			_dumpLogs( logData );
#endif
		}
		
		
#region Plugin response handling

		public void InitHandler( string jsonString ) {
			SimpleCallback( INIT, jsonString );
		}

		public void LoginAsAnonymousHandler( string jsonString ) {
			SimpleCallback( LOGIN_ANONYMOUS, jsonString );
		}

		public void LoginWithGameCenterHandler( string jsonString ) {
			SimpleCallback( LOGIN_GAME_CENTER, jsonString );
		}

		public void LoginHandler( string jsonString ) {
			SimpleCallback( LOGIN, jsonString );
		}
		
		public void LogoutHandler( string emptyString ) {
			SimpleCallback( LOGOUT );
		}

		public void VerifyUserHandler( string jsonString ) {
			SimpleCallback( VERIFY, jsonString );
		}
		
		public void FetchWalletHandler( string jsonString ) {
			SimpleCallback( FETCH_WALLET, jsonString );
		}

		public void ShowWalletPanelHandler( string emptyString ) {
			SimpleCallback( SHOW_WALLET_PANEL );
		}
		
		public void SendPromoCreditsHandler( string jsonString ) {
			SimpleCallback( SEND_PROMO_CREDITS, jsonString );
		}
		
		public void RequestTournamentHandler( string jsonString ) {
			SimpleCallback( REQUEST_TOURNAMENT, jsonString );
		}
		
		
		public void FetchTournamentsHandler( string jsonString ) {
			JSONNode json = JSON.Parse( jsonString );
			
			if( wasSuccess( json )) {
				JSONNode tournamentsNode = json["tournaments"];
				fetchTournamentsSuccessHandler( TournamentProtocol.ParseTournaments( tournamentsNode["results"] ));
			} else {
				fetchTournamentsErrorHandler( getErrors( json ), getDescriptions( json ));
			}
		}
		public void FetchUnviewedTournamentsHandler( string jsonString ) {
			JSONNode json = JSON.Parse( jsonString );
			
			if( wasSuccess( json )) {
				JSONNode tournamentsNode = json["tournaments"];
				fetchUnviewedTournamentsSuccessHandler( TournamentProtocol.ParseTournaments( tournamentsNode["results"] ));
			} else {
					fetchUnviewedTournamentsErrorHandler( getErrors( json ));
			}
		}

// TODO: This still needs to be implemented on the obj-c side
//		public void MarkViewedTournamentHandler( string jsonString ) {
//			SimpleCallback( MARK_VIEWED_TOURNAMENT, jsonString );
//		}

		public void ShowTournamentDetailsPanelHandler( string emptyString ) {
			SimpleCallback( SHOW_TOURNAMENT_PANEL );
		}
		
		public void ShowPreviousTournamentsHandler( string emptyString ) {
			SimpleCallback( SHOW_PREIVOUS_TOURNAMENTS );
		}
		
		public void ShowUnviewedTournamentsHandler( string emptyString ) {
			SimpleCallback( SHOW_UNVIEWED_TOURNAMENTS );
		}
		
		public void ShowIncompleteTournamentsHandler( string tournamentId ) {
			showIncompleteTournamentsCallback( tournamentId );
		}	
		
		
		public void RequestCashChallengeHandler( string jsonString ) {
			JSONNode json = JSON.Parse( jsonString );
			if( wasSuccess( json )) {
				JSONClass challenge = json["challenge"] as JSONClass;
				requestCashChallengeSuccessHandler( CashChallengeProtocol.ParseCashChallenge( challenge ) );
			} else {
				requestCashChallengeErrorHandler( getErrors( json ), getDescriptions( json ));
			}
		}
		
		public void AcceptCashChallengeHandler( string jsonString ) {
			SimpleCallback( ACCEPT_SCORE_CHALLENGE, jsonString );
		}
		
		public void RejectCashChallengeHandler( string emptyString ) {
			SimpleCallback( REJECT_SCORE_CHALLENGE );
		}
		
		public void ReportScoreForChallengeHandler( string jsonString ) {
			JSONNode json = JSON.Parse( jsonString );
			if( wasSuccess( json )) {
				JSONClass challenge = json["challenge"] as JSONClass;
				reportScoreForChallengeSuccessHandler( CashChallengeProtocol.ParseCashChallenge( challenge ) );
			} else {
				reportScoreForChallengeErrorHandler( getErrors( json ), getDescriptions( json ));
			}
		}
		
		
		public void ShowWalkThroughHandler( string emptyString ) {
			SimpleCallback( SHOW_WALK_THROUGH );
		}
		
		public void ShowCashChallengeRulesHandler( string emptyString ) {
			SimpleCallback( SHOW_SCORE_CHALLENGE_RULES );
		}
		
		public void ReportScoreHandler( string jsonString ) {
			JSONNode json = JSON.Parse( jsonString );
			if( wasSuccess( json )) {
				_fetchWallet();
				JSONClass tournamentNode = json["tournament"] as JSONClass;
				if( reportScoreSuccessHandler != null )
					reportScoreSuccessHandler( TournamentProtocol.ParseTournament( tournamentNode ));
			} else {
				reportScoreErrorHandler( getErrors( json ));
			}
		}


		public struct CallbackTuple {
			public CallbackTuple( SuccessHandler success, ErrorHandler failure, FriendlyErrorHandler friendlyFailure ) {
				Success = success;
				Failure = failure;
				FriendlyFailure = friendlyFailure;
			}
			public SuccessHandler Success;
			public ErrorHandler Failure;
			public FriendlyErrorHandler FriendlyFailure;
		}
		private static Dictionary<string,CallbackTuple> callbacks = new Dictionary<string,CallbackTuple>();
		private static void SetCallbacksWithFriendlyErrors( string key, SuccessHandler success, FriendlyErrorHandler failure ) {
			if( success == null )
				success = () => {};
			if( failure == null )
				failure = (e,d) => {};
			callbacks[ key ] = new CallbackTuple( success, ( e ) => {}, failure );
		}
		private static void SetCallbacksWithErrors( string key, SuccessHandler success, ErrorHandler failure ) {
			if( success == null )
				success = () => {};
			if( failure == null )
				failure = (e) => {};
			callbacks[ key ] = new CallbackTuple( success, failure, ( e,d ) => {} );
		}
		private static void SetSimpleCallback( string key, SuccessHandler callback ) {
			if( callback == null )
				callback = () => {};
			callbacks[ key ] = new CallbackTuple( callback, ( e ) => {}, ( e,d ) => {} );
		}
		private void SimpleCallback( string callKey, string pluginResponse ) {
			CallbackTuple callback = callbacks[ callKey ];

			if( pluginResponse == null || pluginResponse.Equals("") ) {
				string err = "ArbiterBinding Parse Error: Was expecting a non-null/non-empty string response from native plugin. Recieved:"+pluginResponse;
				Debug.LogError( err );
				callback.Failure( new List<string>(){ err } );
			} else {
				JSONNode json = JSON.Parse( pluginResponse );

				if( wasSuccess( json )) {
					callback.Success();
				} else {
					callback.Failure( getErrors( json ));
					callback.FriendlyFailure( getErrors( json ), getDescriptions( json ));
				}
			}
		}
		private void SimpleCallback( string callKey ) {
			callbacks[ callKey ].Success();
		}
#endregion

		
		
#if UNITY_EDITOR
		private static void ReportIgnore( string functionName ) {
			Debug.Log( "Shorting call to Arbiter::"+functionName+" since this is running in editor. Will return default params to callbacks instead." );
		}
#endif
		
		
		private bool wasSuccess( JSONNode json ) {
			return json["success"].AsBool;
		}
		
		private bool isVerified( JSONNode userNode) {
			return string.Equals( userNode["agreed_to_terms"].Value, "true" ) && string.Equals( userNode["location_approved"].Value, "true");
		}
		

		private List<string> getErrors( JSONNode json ) {
			List<string> rv = new List<string>();
			JSONArray errors = json["errors"].AsArray;
			IEnumerator enumerator = errors.GetEnumerator();
			while( enumerator.MoveNext() ) {
				rv.Add( ((JSONData)(enumerator.Current)).Value );
			}
			return rv;
		}
		private List<string> getDescriptions( JSONNode json ) {
			List<string> rv = new List<string>();
			JSONArray errors = json["descriptions"].AsArray;
			IEnumerator enumerator = errors.GetEnumerator();
			while( enumerator.MoveNext() ) {
				rv.Add( ((JSONData)(enumerator.Current)).Value );
			}
			return rv;
		}
		
		
		private static string SerializeDictionary( Dictionary<string,string> dict )
		{
			var entries = dict.Select( kvp => 
			                          string.Format( "\"{0}\": \"{1}\" ", kvp.Key, kvp.Value )
			                          ).ToArray();
			return "{" + string.Join( ",", entries ) + "}";
		}
		
	}
}
