using UnityEngine;
using System;
using System.Linq;
using System.Collections;
using System.Collections.Generic;
using System.Runtime.InteropServices;
using SimpleJSON;

namespace ArbiterInternal {



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


        public void ShowWalletPanelHandler() {
            showWalletCallback();
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
    }


} // namespace ArbiterInternal
