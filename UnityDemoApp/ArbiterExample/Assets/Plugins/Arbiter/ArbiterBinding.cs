using UnityEngine;
using System;
using System.Linq;
using System.Collections;
using System.Collections.Generic;
using System.Runtime.InteropServices;
using SimpleJSON;


// ttt I'm pretty sure this is old/startig point. Probably can just remove this class.
/*
public class NativeBinding : MonoBehaviour {

	static NativeBinding() {
		GameObject go = new GameObject( "ArbiterBinding" );
		go.AddComponent< NativeBinding >();
		GameObject.DontDestroyOnLoad( go );
	}

	public void ReceiveMessage( string msg ){
		Debug.Log( "===== Received message from iOS =====" );
		Debug.Log( msg );
	}

	public static void Foo() {
#if UNITY_IOS && !UNITY_EDITOR
		foo("Hi from Unity");
#else
		Debug.Log( "Call was made to native function. Has no effect in editor." );
#endif
	}


	[DllImport ("__Internal")]
	private static extern float foo( string msg );

}
*/

namespace ArbiterInternal {


/// <summary>
/// Bridge to the objective c functions for the Arbiter SDK
/// </summary>
public class ArbiterBinding : MonoBehaviour
{
	[DllImport ("__Internal")]
	private static extern void _init();
    public delegate void InitializeCallback( string userId, Wallet wallet );
	private static InitializeCallback initCallback;
	public static void Init( InitializeCallback callback ) {
        initCallback = callback;
#if UNITY_EDITOR
        ReportIgnore( "Initialize" );
        initCallback( "0", null );
#elif UNITY_IOS
		_init();
#endif
	}


	[DllImport ("__Internal")]
	private static extern void _verifyUser();
    private static Action<bool> verifyUserCallback;
	public static void VerifyUser( Action<bool> callback ) {
        verifyUserCallback = callback;
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
	public static void GetWallet( GetWalletCallback callback ) {
        getWalletCallback = callback;
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

	public void InitHandler( string jsonString )
	{
		JSONNode json = JSON.Parse(jsonString);
        string userId = json["user_id"];
        Wallet wallet = null;
        if( json["wallet"] != null ) {
            wallet = parseWallet( json["wallet"] );
        }
		initCallback( userId, wallet );
	}

	public void VerifyUserHandler( string jsonString )
	{
        JSONNode json = JSON.Parse(jsonString);
		Dictionary<string, string> dict = new Dictionary<string, string>();
            // ttt TODO: Properly parse the wallet from a verify call? Is it really needed?
		dict.Add("success", json["success"]);
		wallet.Add("depositAddress", json["wallet"]["deposit_address"].Value);
		wallet.Add("balance", json ["wallet"] ["balance"].Value);
        bool response = dict["success"] == "true";
        verifyUserCallback( response );
	}

	public void GetWalletHandler( string jsonString )
	{
        JSONNode json = JSON.Parse(jsonString);
        if( wasSuccess( json )) {
            getWalletCallback( parseWallet( json["wallet"] ));
        } else {
            throw new NotImplementedException(); // TODO: Implement failure handlers
        }
	}

#if UNITY_EDITOR
    private static void ReportIgnore( string functionName ) {
        Debug.Log( "Ignoring call to Arbiter::"+functionName+" since this is running in editor. Will return default params to callbacks instead." );
    }
#endif


    private bool wasSuccess( JSONNode json ) {
        return json["success"] == "true";
    }


    private Wallet parseWallet( JSONNode json ) {
        Wallet rv = new Wallet();
        rv.Balance = json["balance"].Value;
        rv.DepositAddress = json["deposit_address"].Value;
        rv.DepositQrCode = json["deposit_address_qr_code"].Value;
        rv.WithdrawAddress = json["withdraw_address"].Value;
        return rv;
    }

	private Dictionary<string, string> wallet = new Dictionary<string, string>();
}


} // namespace ArbiterInternal
