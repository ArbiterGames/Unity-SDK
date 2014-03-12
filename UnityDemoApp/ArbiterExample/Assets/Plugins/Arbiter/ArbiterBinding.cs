using UnityEngine;
using System;
using System.Linq;
using System.Collections;
using System.Collections.Generic;
using System.Runtime.InteropServices;
using SimpleJSON;


namespace ArbiterInternal {

// TODO: Replace all the boilerplate with some helpers

    /// <summary>
    /// Bridge to the objective c functions for the Arbiter SDK
    /// </summary>
    public class ArbiterBinding : MonoBehaviour
    {
    	[DllImport ("__Internal")]
    	private static extern void _init();
        public delegate void LoginCallback( User user, bool isVerified, Wallet wallet );
        private static LoginCallback initCallback;
        private static ErrorHandler initErrorHandler;
        public static void Init( LoginCallback callback, ErrorHandler errorHandler ) {
            initCallback = callback;
            initErrorHandler = errorHandler;
#if UNITY_EDITOR
            ReportIgnore( "Initialize" );
            User user = new User();
            user.Id = "0";
            user.Name = "McMockison";
            initCallback( user, false, null );
#elif UNITY_IOS
    		_init();
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
    	private static extern void _verifyUser();
        public delegate void VerifyUserCallback( bool isVerified );    
        private static VerifyUserCallback verifyUserCallback;
        private static ErrorHandler verifyUserErrorHandler;
    	public static void VerifyUser( VerifyUserCallback callback, ErrorHandler errorHandler ) {
            verifyUserCallback = callback;
            verifyUserErrorHandler = errorHandler;
#if UNITY_EDITOR
            ReportIgnore( "VerifyUser" );
            verifyUserCallback( true );
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
    	private static extern void _copyDepositAddressToClipboard();
    	public static void CopyDepositAddressToClipboard() {
#if UNITY_EDITOR
            ReportIgnore( "CopyDepositAddressToClipboard" );
#elif UNITY_IOS
            _copyDepositAddressToClipboard();
#endif
    	}


        [DllImport ("__Internal")]
        private static extern void _requestCompetition( string gameName, string buyIn, string filters );
        private static Arbiter.RequestCompetitionCallback requestCompetitionCallback;
        private static ErrorHandler requestCompetitionErrorHandler;
        public static void RequestCompetition( string gameName, string buyIn, Dictionary<string,string> filters, Arbiter.RequestCompetitionCallback callback, ErrorHandler errorHandler ) {
            requestCompetitionCallback = callback;
            requestCompetitionErrorHandler = errorHandler;
#if UNITY_EDITOR
            ReportIgnore( "RequestCompetition" );
            requestCompetitionCallback();
#elif UNITY_IOS
            _requestCompetition( gameName, buyIn, SerializeDictionary(filters) );
#endif
        }


        [DllImport ("__Internal")]
        private static extern void _getCompetitions();
        private static Arbiter.GetCompetitionsCallback getCompetitionsCallback;
        private static ErrorHandler getCompetitionsErrorHandler;
        public static void GetCompetitions( Arbiter.GetCompetitionsCallback callback, ErrorHandler errorHandler ) {
            getCompetitionsCallback = callback;
            getCompetitionsErrorHandler = errorHandler;
#if UNITY_EDITOR
            ReportIgnore( "GetCompetitions" );
            List<Arbiter.Competition> fakeCompetitions = new List<Arbiter.Competition>();
            getCompetitionsCallback( fakeCompetitions );
#elif UNITY_IOS
            _getCompetitions();
#endif
        }


        [DllImport ("__Internal")]
        private static extern void _viewPreviousCompetitions();
        private static Arbiter.ViewPreviousCompetitionsCallback viewPreviousCompetitionsCallback;
        private static ErrorHandler viewPreviousCompetitionsErrorHandler;
        public static void ViewPreviousCompetitions( Arbiter.ViewPreviousCompetitionsCallback callback, ErrorHandler errorHandler ) {
            viewPreviousCompetitionsCallback = callback;
            viewPreviousCompetitionsErrorHandler = errorHandler;
#if UNITY_EDITOR
            ReportIgnore( "ViewPreviousCompetitions" );
            viewPreviousCompetitionsCallback();
#elif UNITY_IOS
            _viewPreviousCompetitions();
#endif
        }


        [DllImport ("__Internal")]
        private static extern void _reportScore( string competitionId, string score );
        private static Arbiter.ReportScoreCallback reportScoreCallback;
        private static ErrorHandler reportScoreErrorHandler;
        public static void ReportScore( string competitionId, int score, Arbiter.ReportScoreCallback callback, ErrorHandler errorHandler ) {
            reportScoreCallback = callback;
            reportScoreErrorHandler = errorHandler;
#if UNITY_EDITOR
            ReportIgnore( "ReportScore" );
            reportScoreCallback( new Arbiter.Competition( "1234", Arbiter.Competition.StatusType.Open, new List<Arbiter.Player>() ));
#elif UNITY_IOS
            _reportScore( competitionId, score.ToString() );
#endif
        }



    	// Response handlers for APIs
    	//////////////////////////////

    	public void InitHandler( string jsonString ) {
    		JSONNode json = JSON.Parse( jsonString );
            if( wasSuccess( json )) {
                User user = parseUser( json["user"] );
                bool verified = isVerified( json["user"] );
                Wallet wallet = null;
                if( json["wallet"] != null ) {
                    wallet = parseWallet( json["wallet"] );
                }
                initCallback( user, verified, wallet );
            } else {
                initErrorHandler( getErrors( json ));
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


    	public void VerifyUserHandler( string jsonString ) {
            JSONNode json = JSON.Parse( jsonString );
            if( wasSuccess( json )) {
                bool verified = isVerified( json["user"] );
                verifyUserCallback( verified );
            } else {
                verifyUserErrorHandler( getErrors( json ));
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


        public void RequestCompetitionHandler( string jsonString ) {
            JSONNode json = JSON.Parse( jsonString );
            if( wasSuccess( json )) {
                requestCompetitionCallback();
            } else {
                requestCompetitionErrorHandler( getErrors( json ));
            }
        }


        public void GetCompetitionsHandler( string jsonString ) {
            JSONNode json = JSON.Parse( jsonString );
            if( wasSuccess( json )) {
                getCompetitionsCallback( parseCompetitions( json["competitions"] ));
            } else {
                getCompetitionsErrorHandler( getErrors( json ));
            }
        }


        public void ViewPreviousCompetitionsHandler( string emptyString ) {
            viewPreviousCompetitionsCallback();
        }


        public void ReportScoreHandler( string jsonString ) {
            JSONNode json = JSON.Parse( jsonString );
            if( wasSuccess( json )) {
                reportScoreCallback( parseCompetition( json["competition"] ));
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
            return string.Equals( userNode["is_verified"].Value, "true" );
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
            return rv;
        }


        private Wallet parseWallet( JSONNode walletNode ) {
            Wallet rv = new Wallet();
            rv.Balance = walletNode["balance"].Value;
            rv.DepositAddress = walletNode["deposit_address"].Value;
            rv.DepositQrCode = walletNode["deposit_address_qr_code"].Value;
            rv.WithdrawAddress = walletNode["withdraw_address"].Value;
            return rv;
        }


        private List<Arbiter.Competition> parseCompetitions( JSONNode competitionsNode ) {
            List<Arbiter.Competition> rv = new List<Arbiter.Competition>();
            JSONArray rawCompetitions = competitionsNode.AsArray;
            IEnumerator enumerator = rawCompetitions.GetEnumerator();
            while( enumerator.MoveNext() ) {
                JSONNode competitionNode = ((JSONData)(enumerator.Current)).Value;
                rv.Add( parseCompetition( competitionNode ));
            }
            return rv;
        }
        private Arbiter.Competition parseCompetition( JSONNode competitionNode ) {
            Debug.LogWarning("ttt node=");
            Debug.LogWarning(competitionNode);
            Arbiter.Competition.StatusType status = Arbiter.Competition.StatusType.Unknown;
            switch( competitionNode["status"] ) {
                case "open":
                    status = Arbiter.Competition.StatusType.Open;
                    break;
                case "in_progress":
                    status = Arbiter.Competition.StatusType.InProgress;
                    break;
                case "complete":
                    status = Arbiter.Competition.StatusType.Complete;
                    break;
                default:
                    Debug.LogError( "Unknown status encountered: " + competitionNode["status"] );
                    break;
            }
            List<Arbiter.Player> players = new List<Arbiter.Player>();
            return new Arbiter.Competition( competitionNode["id"], status, players );
        }

    }


} // namespace ArbiterInternal
