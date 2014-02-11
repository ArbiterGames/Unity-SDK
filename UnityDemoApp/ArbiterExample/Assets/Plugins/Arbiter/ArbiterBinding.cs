﻿using UnityEngine;
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
    public static void Init( LoginCallback callback ) {
        initCallback = callback;
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
    public static void LoginWithGameCenter( LoginCallback callback ) {
        loginWithGameCenterCallback = callback;
#if UNITY_EDITOR
        ReportIgnore( "Login:GameCenter" );
        User user = new User();
        user.Id = "0";
        user.Name = "McMockison";
        loginWithGameCenterCallback( user, false, null );
#elif UNITY_IOS
//            Debug.Log("ttt checkpoint3");
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
        getWalletCallback( new Wallet() );
#elif UNITY_IOS
		_getWallet();
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
        JSONNode userNode = json["user"];
        User user = new User();
        user.Id = userNode["id"].Value;
        user.Name = userNode["username"].Value;
        bool verified = isVerified( userNode );
        Wallet wallet = null;
        if( json["wallet"] != null ) {
            wallet = parseWallet( json["wallet"] );
        }

        initCallback( user, verified, wallet );
	}

    public void LoginWithGameCenterHandler( string jsonString ) {
//        Debug.Log(" ttt native response="+jsonString);
        loginWithGameCenterCallback( null, true, null );
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


    private Wallet parseWallet( JSONNode json ) {
        Wallet rv = new Wallet();
        rv.Balance = json["balance"].Value;
        rv.DepositAddress = json["deposit_address"].Value;
        rv.DepositQrCode = json["deposit_address_qr_code"].Value;
        rv.WithdrawAddress = json["withdraw_address"].Value;
        return rv;
    }
}


} // namespace ArbiterInternal