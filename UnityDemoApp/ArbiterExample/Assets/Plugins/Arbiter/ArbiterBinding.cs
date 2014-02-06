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
	private static Action<Dictionary<string, string>> initCallback;
	public static void Init( Action<Dictionary<string, string>> callback ) {
        initCallback = callback;
#if UNITY_EDITOR
        ReportIgnore( "Initialize" );
        Dictionary<string,string> dummyResponse = new Dictionary<string,string>();
        dummyResponse.Add( "user_id", "0" );
        initCallback( dummyResponse );
#elif UNITY_IOS
		_init();
#endif
	}


	// VerifyUser
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
    private static Action<Dictionary<string, string>> getWalletCallback;
	public static void GetWallet( Action<Dictionary<string, string>> callback ) {
        getWalletCallback = callback;
#if UNITY_EDITOR
        ReportIgnore( "GetWallet" );
        Dictionary<string,string> dummyResponse = new Dictionary<string,string>();
        getWalletCallback( dummyResponse );
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
		JSONNode json = JSON.Parse (jsonString);
		Dictionary<string, string> dict = new Dictionary<string, string>();
		dict.Add ("user_id", json["user_id"]);
		initCallback (dict);
	}

	public void VerifyUserHandler( string jsonString )
	{
        JSONNode json = JSON.Parse(jsonString);
		Dictionary<string, string> dict = new Dictionary<string, string>();
		dict.Add("success", json["success"]);
		wallet.Add("depositAddress", json["wallet"]["deposit_address"].Value);
		wallet.Add("balance", json ["wallet"] ["balance"].Value);
        bool response = dict["success"] == "true";
        verifyUserCallback( response );
	}

	public void GetWalletHandler( string jsonString )
	{
        JSONNode json = JSON.Parse(jsonString);
		Dictionary<string, string> dict = new Dictionary<string, string>();
		dict.Add ("success", json["success"]);
		wallet["depositAddress"] = json["wallet"]["deposit_address"].Value;
		wallet["balance"] = json ["wallet"] ["balance"].Value;
		getWalletCallback (dict);
	}

#if UNITY_EDITOR
    private static void ReportIgnore( string functionName ) {
        Debug.Log( "Ignoring call to Arbiter::"+functionName+" since this is running in editor. Will return default params to callbacks instead." );
    }
#endif


	private Dictionary<string, string> wallet = new Dictionary<string, string>();
}


} // namespace ArbiterInternal
