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
			SetSimpleCallbacks( INIT, success, failure );
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
			SetSimpleCallbacks( LOGIN_ANONYMOUS, success, failure );
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
			SetSimpleCallbacks( LOGIN_GAME_CENTER, success, failure );
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
			SetSimpleCallbacks( LOGIN, success, failure );
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
			SetSimpleCallbacks( LOGOUT, success, failure );
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
			SetSimpleCallbacks( VERIFY, success, failure );
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
			simpleCallbacks[ FETCH_WALLET ] = new CallbackTuple( success, failure );
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
			SetSimpleCallbacks( SEND_PROMO_CREDITS, success, failure );
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
		public static void RequestTournament( string buyIn, Dictionary<string,string> filters, SuccessHandler success, ErrorHandler failure ) {
			SetSimpleCallbacks( REQUEST_TOURNAMENT, success, failure );
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
		private static ErrorHandler fetchTournamentsErrorHandler;
		public static void FetchTournaments( Arbiter.TournamentsCallback success, ErrorHandler failure ) {
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
			SetSimpleCallbacks( SHOW_PREIVOUS_TOURNAMENTS, success, failure );
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


		const string MARK_VIEWED_TOURNAMENT = "mark_view_tourn";
		[DllImport ("__Internal")]
		private static extern void _markViewedTournament( string tournamentId );
		public static void MarkViewedTournament( string tournamentId, ErrorHandler failure ) {
			SetSimpleCallbacks( MARK_VIEWED_TOURNAMENT, null, failure );
#if UNITY_EDITOR
			ReportIgnore( "MarkViewedTournament" );
#elif UNITY_IOS
			_markViewedTournament( tournamentId );
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
		
		public void SendPromoCreditsHandler( string emptyString ) {
			SimpleCallback( SEND_PROMO_CREDITS );
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
				fetchTournamentsErrorHandler( getErrors( json ));
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

		public void MarkViewedTournamentHandler( string jsonString ) {
			SimpleCallback( MARK_VIEWED_TOURNAMENT, jsonString );
		}

		public void ShowTournamentDetailsPanelHandler( string emptyString ) {
			SimpleCallback( SHOW_TOURNAMENT_PANEL );
		}
		
		public void ViewPreviousTournamentsHandler( string emptyString ) {
			SimpleCallback( SHOW_PREIVOUS_TOURNAMENTS );
		}
		
		public void ShowIncompleteTournamentsHandler( string tournamentId ) {
			showIncompleteTournamentsCallback( tournamentId );
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
			public CallbackTuple( SuccessHandler success, ErrorHandler failure ) {
				Success = success;
				Failure = failure;
			}
			public SuccessHandler Success;
			public ErrorHandler Failure;
		}
		private static Dictionary<string,CallbackTuple> simpleCallbacks = new Dictionary<string,CallbackTuple>();
		private static void SetSimpleCallbacks( string key, SuccessHandler success, ErrorHandler failure ) {
			if( success == null )
				success = () => {};
			if( failure == null )
				failure = (e) => {};
			simpleCallbacks[ key ] = new CallbackTuple( success, failure );
		}
		private static void SetSimpleCallback( string key, SuccessHandler callback ) {
			if( callback == null )
				callback = () => {};
			simpleCallbacks[ key ] = new CallbackTuple( callback, ( e ) => {} );
		}
		private void SimpleCallback( string callKey, string pluginResponse ) {
			JSONNode json = JSON.Parse( pluginResponse );
			if( wasSuccess( json )) {
				simpleCallbacks[ callKey ].Success();
			} else {
				simpleCallbacks[ callKey ].Failure( getErrors( json ));
			}
		}
		private void SimpleCallback( string callKey ) {
			simpleCallbacks[ callKey ].Success();
		}
#endregion

		
		
#if UNITY_EDITOR
		private static void ReportIgnore( string functionName ) {
			Debug.Log( "Shorting call to Arbiter::"+functionName+" since this is running in editor. Will return default params to callbacks instead." );
		}
#endif
		
		
		private bool wasSuccess( JSONNode json ) {
			return (string.Equals( json["success"].Value, "true"));
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
		
		
		private static string SerializeDictionary( Dictionary<string,string> dict )
		{
			var entries = dict.Select( kvp => 
			                          string.Format( "\"{0}\": \"{1}\" ", kvp.Key, kvp.Value )
			                          ).ToArray();
			return "{" + string.Join( ",", entries ) + "}";
		}
		
	}
}
