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
		[DllImport ("__Internal")]
		private static extern void _init( string gameApiKey, string accessToken );
		private static ErrorHandler initErrorHandler;
		private static void initCallback() {
			Debug.Log ("Arbiter successfully initialized.");
		}
		public static void Init( string gameApiKey, string accessToken, ErrorHandler errorHandler ) {
			initErrorHandler = errorHandler;
#if UNITY_EDITOR
			ReportIgnore( "Initialize" );
			initCallback();
#elif UNITY_IOS
			_init( gameApiKey, accessToken );
#endif
		}
		
		
		[DllImport ("__Internal")]
		private static extern void _loginAsAnonymous();
		public delegate void LoginCallback( User user, bool isVerified, Wallet wallet );
		private static LoginCallback loginAsAnonymousCallback;
		private static ErrorHandler loginAsAnonymousErrorHandler;
		public static void LoginAsAnonymous( LoginCallback callback, ErrorHandler errorHandler ) {
			loginAsAnonymousCallback = callback;
			loginAsAnonymousErrorHandler = errorHandler;
#if UNITY_EDITOR
			ReportIgnore( "Login:Anonymous" );
			User user = new User();
			user.Id = "0";
			user.Name = "AnonymousMcMockison";
			loginAsAnonymousCallback( user, false, null );
#elif UNITY_IOS
			_loginAsAnonymous();
#endif
		}
		
		
		[DllImport ("__Internal")]
		private static extern void _loginWithGameCenterPlayer();
		public delegate void LoginWithGameCenterCallback( User user, bool isVerified, Wallet wallet );
		private static LoginCallback loginWithGameCenterCallback;
		private static ErrorHandler loginWithGameCenterErrorHandler;
		public static void LoginWithGameCenter( LoginCallback callback, ErrorHandler errorHandler ) {
			loginWithGameCenterCallback = callback;
			loginWithGameCenterErrorHandler = errorHandler;
#if UNITY_EDITOR
			ReportIgnore( "Login:GameCenter" );
			User user = new User();
			user.Id = "0";
			user.Name = "McMockison";
			loginWithGameCenterCallback( user, false, null );
#elif UNITY_IOS
			_loginWithGameCenterPlayer();
#endif
		}
		
		
		[DllImport ("__Internal")]
		private static extern void _login();
		private static LoginCallback loginCallback;
		private static ErrorHandler loginErrorHandler;
		public static void Login( LoginCallback callback, ErrorHandler errorHandler ) {
			loginCallback = callback;
			loginErrorHandler = errorHandler;
#if UNITY_EDITOR
			ReportIgnore( "Login:BasicAuth" );
			User user = new User();
			user.Id = "0";
			user.Name = "McMockison";
			loginCallback( user, false, null );
#elif UNITY_IOS
			_login();
#endif
		}
		
		
		[DllImport ("__Internal")]
		private static extern void _logout();
		public delegate void LogoutCallback();
		private static LogoutCallback logoutCallback;
		public static void Logout( LogoutCallback callback ) {
			logoutCallback = callback;
#if UNITY_EDITOR
			ReportIgnore( "Logout" );
			logoutCallback();
#elif UNITY_IOS
			_logout();
#endif
		}
		
		
		[DllImport ("__Internal")]
		private static extern void _verifyUser();
		public delegate void VerifyUserCallback( User user );    
		private static VerifyUserCallback verifyUserCallback;
		private static ErrorHandler verifyUserErrorHandler;
		public static void VerifyUser( VerifyUserCallback callback, ErrorHandler errorHandler ) {
			verifyUserCallback = callback;
			verifyUserErrorHandler = errorHandler;
#if UNITY_EDITOR
			ReportIgnore( "VerifyUser" );
			User user = new User();
			user.Id = "0";
			user.Name = "McMockison";
			user.LocationApproved = true;
			user.AgreedToTerms = true;
			verifyUserCallback( user );
#elif UNITY_IOS
			_verifyUser();
#endif
		}
		
		
		[DllImport ("__Internal")]
		private static extern void _getWallet();
		public delegate void GetWalletCallback( Wallet wallet );
		private static GetWalletCallback getWalletCallback;
		private static ErrorHandler getWalletErrorHandler;
		public static void GetWallet( GetWalletCallback callback, ErrorHandler errorHandler ) {
			getWalletCallback = callback;
			getWalletErrorHandler = errorHandler;
#if UNITY_EDITOR
			ReportIgnore( "GetWallet" );
			getWalletCallback( Wallet.CreateMockWallet() );
#elif UNITY_IOS
			_getWallet();
#endif
		}
		
		
		[DllImport ("__Internal")]
		private static extern void _showWalletPanel();
		private static Action showWalletCallback;
		public static void ShowWalletPanel( Action callback ) {
			showWalletCallback = callback;
#if UNITY_EDITOR
			ReportIgnore( "ShowWallet" );
			if( showWalletCallback != null )
				showWalletCallback();
#elif UNITY_IOS
			_showWalletPanel();
#endif
		}
		
		
		[DllImport ("__Internal")]
		private static extern void _requestTournament( string buyIn, string filters );
		private static Arbiter.RequestTournamentCallback requestTournamentCallback;
		private static ErrorHandler requestTournamentErrorHandler;
		public static void RequestTournament( string buyIn, Dictionary<string,string> filters, Arbiter.RequestTournamentCallback callback, ErrorHandler errorHandler ) {
			requestTournamentCallback = callback;
			requestTournamentErrorHandler = errorHandler;
#if UNITY_EDITOR
			ReportIgnore( "RequestTournament" );
			if( requestTournamentCallback != null )
				requestTournamentCallback();
#elif UNITY_IOS
			_requestTournament( buyIn, SerializeDictionary(filters) );
#endif
		}
		
		[DllImport ("__Internal")]
		private static extern void _showTournamentDetailsPanel( string tournamentId);
		private static Action showTournamentDetailsPanelCallback;
		public static void ShowTournamentDetailsPanel( string tournamentId, Action callback ) {
			showTournamentDetailsPanelCallback = callback;
			#if UNITY_EDITOR
			ReportIgnore( "ShowTournamentDetailsPanel" );
			if( showTournamentDetailsPanelCallback != null )
				showTournamentDetailsPanelCallback();
			#elif UNITY_IOS
			_showTournamentDetailsPanel( tournamentId );
			#endif
		}
		
		
		[DllImport ("__Internal")]
		private static extern void _getTournaments();
		private static Arbiter.GetTournamentsCallback getTournamentsCallback;
		private static ErrorHandler getTournamentsErrorHandler;
		public static void GetTournaments( Arbiter.GetTournamentsCallback callback, ErrorHandler errorHandler ) {
			getTournamentsCallback = callback;
			getTournamentsErrorHandler = errorHandler;
#if UNITY_EDITOR
			ReportIgnore( "GetTournaments" );
			List<Arbiter.Tournament> fakeTournaments = new List<Arbiter.Tournament>();
			getTournamentsCallback( fakeTournaments );
#elif UNITY_IOS
			_getTournaments();
#endif
		}
		
		
		[DllImport ("__Internal")]
		private static extern void _viewPreviousTournaments();
		private static Arbiter.ViewPreviousTournamentsCallback viewPreviousTournamentsCallback;
		public static void ViewPreviousTournaments( Arbiter.ViewPreviousTournamentsCallback callback ) {
			viewPreviousTournamentsCallback = callback;
#if UNITY_EDITOR
			ReportIgnore( "ViewPreviousTournaments" );
			viewPreviousTournamentsCallback();
#elif UNITY_IOS
			_viewPreviousTournaments();
#endif
		}
		
		
		[DllImport ("__Internal")]
		private static extern void _viewIncompleteTournaments();
		private static Arbiter.ViewIncompleteTournamentsCallback viewIncompleteTournamentsCallback;
		public static void ViewIncompleteTournaments( Arbiter.ViewIncompleteTournamentsCallback callback ) {
			viewIncompleteTournamentsCallback = callback;
#if UNITY_EDITOR
			ReportIgnore( "ViewIncompleteTournaments" );
			viewIncompleteTournamentsCallback( "" );
#elif UNITY_IOS
			_viewIncompleteTournaments();
#endif
		}
		
		
		[DllImport ("__Internal")]
		private static extern void _reportScore( string tournamentId, string score );
		private static Arbiter.ReportScoreCallback reportScoreCallback;
		private static ErrorHandler reportScoreErrorHandler;
		public static void ReportScore( string tournamentId, int score, Arbiter.ReportScoreCallback callback, ErrorHandler errorHandler ) {
			reportScoreCallback = callback;
			reportScoreErrorHandler = errorHandler;
			
#if UNITY_EDITOR
			ReportIgnore( "ReportScore" );
			reportScoreCallback( new Arbiter.Tournament( "1234", Arbiter.Tournament.StatusType.Initializing, new List<Arbiter.TournamentUser>(), new List<string>() ));
#elif UNITY_IOS
			_reportScore( tournamentId, score.ToString() );
#endif
		}
		
		
		
		// Response handlers for APIs
		//////////////////////////////
		
		public void InitHandler( string jsonString ) {
			JSONNode json = JSON.Parse( jsonString );
			if( wasSuccess( json )) {
				initCallback();
			} else {
				initErrorHandler( getErrors( json ));
			}
		}
		
		
		public void LoginAsAnonymousHandler( string jsonString ) {
			JSONNode json = JSON.Parse( jsonString );
			if( wasSuccess( json )) {
				User user = parseUser( json["user"] );
				bool verified = isVerified( json["user"] );
				loginAsAnonymousCallback( user, verified, null );
			} else {
				loginAsAnonymousErrorHandler( getErrors( json ));
			}
		}
		
		
		public void LoginWithGameCenterHandler( string jsonString ) {
			JSONNode json = JSON.Parse( jsonString );
			if( wasSuccess( json )) {
				User user = parseUser( json["user"] );
				bool verified = isVerified( json["user"] );
				loginWithGameCenterCallback( user, verified, null );
			} else {
				loginWithGameCenterErrorHandler( getErrors( json ));
			}
		}
		
		public void LoginHandler( string jsonString ) {
			JSONNode json = JSON.Parse( jsonString );
			if( wasSuccess( json )) {
				User user = parseUser( json["user"] );
				bool verified = isVerified( json["user"] );
				loginCallback( user, verified, null );
			} else {
				loginErrorHandler( getErrors( json ));
			}
		}
		
		
		public void VerifyUserHandler( string jsonString ) {
			JSONNode json = JSON.Parse( jsonString );
			if( wasSuccess( json )) {
				User user = parseUser( json["user"] );
				verifyUserCallback( user );
			} else {
				verifyUserErrorHandler( getErrors( json ));
			}
		}
		
		
		public void LogoutHandler( string emptyString ) {
			if ( logoutCallback != null ) {
				logoutCallback();
			}
		}
		
		
		public void GetWalletHandler( string jsonString ) {
			JSONNode json = JSON.Parse( jsonString );
			if( wasSuccess( json )) {
				getWalletCallback( parseWallet( json["wallet"] ));
			} else {
				getWalletErrorHandler( getErrors( json ));
			}
		}
		
		
		public void ShowWalletPanelHandler( string emptyString ) {
			if ( showWalletCallback != null ) {
				showWalletCallback();
			}
		}
		
		
		public void RequestTournamentHandler( string jsonString ) {
			JSONNode json = JSON.Parse( jsonString );
			if( wasSuccess( json )) {
				if( requestTournamentCallback != null )
					requestTournamentCallback();
			} else {
				requestTournamentErrorHandler( getErrors( json ));
			}
		}
		
		
		public void GetTournamentsHandler( string jsonString ) {
			JSONNode json = JSON.Parse( jsonString );
			
			if( wasSuccess( json )) {
				JSONNode tournamentsNode = json["tournaments"];
				getTournamentsCallback( parseTournaments( tournamentsNode["results"] ));
			} else {
				getTournamentsErrorHandler( getErrors( json ));
			}
		}
		
		public void ShowTournamentDetailsPanelHandler( string emptyString ) {
			if ( showTournamentDetailsPanelCallback != null ) {
				showTournamentDetailsPanelCallback();
			}
		}
		
		
		public void ViewPreviousTournamentsHandler( string emptyString ) {
			viewPreviousTournamentsCallback();
		}
		
		
		public void ViewIncompleteTournamentsHandler( string tournamentId ) {
			viewIncompleteTournamentsCallback( tournamentId );
		}
		
		
		public void ReportScoreHandler( string jsonString ) {
			JSONNode json = JSON.Parse( jsonString );
			if( wasSuccess( json )) {
				JSONClass tournamentNode = json["tournament"] as JSONClass;
				if( reportScoreCallback != null )
					reportScoreCallback( parseTournament( tournamentNode ));
			} else {
				reportScoreErrorHandler( getErrors( json ));
			}
		}
		
		
#if UNITY_EDITOR
		private static void ReportIgnore( string functionName ) {
			Debug.Log( "Ignoring call to Arbiter::"+functionName+" since this is running in editor. Will return default params to callbacks instead." );
		}
#endif
		
		
		private bool wasSuccess( JSONNode json ) {
			return (string.Equals( json["success"].Value, "true"));
		}
		
		private bool isVerified( JSONNode userNode) {
			return string.Equals( userNode["agreed_to_terms"].Value, "true" ) && string.Equals( userNode["location_approved"].Value, "true");
		}
		
		
		public delegate void ErrorHandler( List<string> errors );
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
		private User parseUser( JSONNode userNode ) {
			User rv = new User();
			rv.Id = userNode["id"].Value;
			rv.Name = userNode["username"].Value;
			rv.LocationApproved = userNode["location_approved"].Value.Equals("true");
			rv.AgreedToTerms = userNode["agreed_to_terms"].Value.Equals("true");
			return rv;
		}
		
		
		private Wallet parseWallet( JSONNode walletNode ) {
			Wallet rv = new Wallet();
			rv.Balance = walletNode["balance"].Value;
			rv.PendingBalance = walletNode["pending_balance"].Value;
			rv.DepositAddress = walletNode["deposit_address"].Value;
			rv.DepositQrCode = walletNode["deposit_address_qr_code"].Value;
			rv.WithdrawAddress = walletNode["withdraw_address"].Value;
			return rv;
		}
		
		
		private List<Arbiter.Tournament> parseTournaments( JSONNode tournamentsNode ) {
			List<Arbiter.Tournament> rv = new List<Arbiter.Tournament>();
			JSONArray rawTournaments = tournamentsNode.AsArray;
			IEnumerator enumerator = rawTournaments.GetEnumerator();
			while( enumerator.MoveNext() ) {
				JSONClass tournament = enumerator.Current as JSONClass;
				rv.Add( parseTournament( tournament ));
			}
			return rv;
		}
		private Arbiter.Tournament parseTournament( JSONClass tournamentNode ) {
			Arbiter.Tournament.StatusType status = Arbiter.Tournament.StatusType.Unknown;
			
			switch( tournamentNode["status"] ) {
			case "initializing":
				status = Arbiter.Tournament.StatusType.Initializing;
				break;
			case "inprogress":
				status = Arbiter.Tournament.StatusType.InProgress;
				break;
			case "complete":
				status = Arbiter.Tournament.StatusType.Complete;
				break;
			default:
				Debug.LogError( "Unknown status encountered: " + tournamentNode["status"] );
				break;
			}
			
			List<Arbiter.TournamentUser> users = parseUsers( tournamentNode["users"] );
			List<string> winners = parseWinners( tournamentNode["winners"] );
			Arbiter.Tournament rv = new Arbiter.Tournament( tournamentNode["id"], status, users, winners );

			return rv;
		}
		
		// I'm sure the is a more elegant way of converting items in the JSON array in a c# list of strings, but this solves the type casting issue for now
		private List<string> parseWinners( JSONNode winnersNode ) {
			List<string> winners = new List<string>();
			if ( winnersNode != null ) {
				JSONArray rawNode = winnersNode.AsArray;
				IEnumerator enumerator = rawNode.GetEnumerator();
				while( enumerator.MoveNext() ) {
					JSONData winnerId = enumerator.Current as JSONData;
					winners.Add( winnerId.Value );
				}
			}	
			return winners;
		}
		
		// Parses the Tournament.Users JSON array returned from the server and converts each item into a c# TournamentUser
		private List<Arbiter.TournamentUser> parseUsers( JSONNode usersNode ) {
			List<Arbiter.TournamentUser> rv = new List<Arbiter.TournamentUser>();
			JSONArray rawUsers = usersNode.AsArray;
			IEnumerator enumerator = rawUsers.GetEnumerator();
			while( enumerator.MoveNext() ) {
				JSONClass userNode = enumerator.Current as JSONClass;
				string id = userNode["id"];
				string paid = userNode["paid"];
				string score = userNode["score"];
				Arbiter.TournamentUser user = new Arbiter.TournamentUser( id );
				if( paid != null && paid != "0" )
					user.Paid = true;
				if( score != null && score != "null" && score != "<null>" )                	
					user.Score = int.Parse( score );
				rv.Add( user );
			}
			return rv;
		}
		
	}
	
	
}
