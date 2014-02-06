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


/// <summary>
/// Bridge to the objective c functions for the Arbiter SDK
/// </summary>
public class ArbiterBinding : MonoBehaviour
{
	
	public static Dictionary<string, string> wallet = new Dictionary<string, string>();
	
	static ArbiterSDK() {
		// Add a GO to the scene for iOS to send responses back to
		GameObject go = new GameObject ("ArbiterBinding");
		go.AddComponent< ArbiterSDK > ();
		GameObject.DontDestroyOnLoad (go);
	}
	
	// Init
	[DllImport ("__Internal")]
	private static extern void _init();
	public static Action<Dictionary<string, string>> initCallback;
	public static void Init(Action<Dictionary<string, string>> callback) {
		if (Application.platform != RuntimePlatform.OSXEditor) {
			_init();
		} else {
			Debug.Log ("Passing on InitializeUser since we are in the editor ");
		}
		initCallback = callback;
	}
	
	// VerifyUser
	[DllImport ("__Internal")]
	private static extern void _verifyUser ();
	public static Action verifyUserCallback;
	public static void VerifyUser(Action callback) {
		if (Application.platform != RuntimePlatform.OSXEditor) {
			_verifyUser();
		} else {
			Debug.Log ("Passing on VerifyUser since we are in the editor ");
		}
		verifyUserCallback = callback;
	}
	
	// GetWallet
	[DllImport ("__Internal")]
	private static extern void _getWallet ();
	public static Action<Dictionary<string, string>> getWalletCallback;
	public static void GetWallet(Action<Dictionary<string, string>> callback) {
		if (Application.platform != RuntimePlatform.OSXEditor) {
			_getWallet();
		} else {
			Debug.Log ("Passing on GetWallet since we are in the editor ");
		}
		getWalletCallback = callback;
	}
	
	// CopyDepositAddressToClipboard
	[DllImport ("__Internal")]
	private static extern void _copyDepositAddressToClipboard ();
	public static void CopyDepositAddressToClipboard() {
		if (Application.platform != RuntimePlatform.OSXEditor) {
			_copyDepositAddressToClipboard();
		} else {
			Debug.Log ("Passing on CopyDepositAddressToClipboard since we are in the editor ");
		}
	}
	
	
	// Response handlers for APIs
	//////////////////////////////
	
	public void InitHandler( string jsonString )
	{
		var json = JSON.Parse (jsonString);
		Dictionary<string, string> dict = new Dictionary<string, string>();
		dict.Add ("user_id", json["user_id"]);
		initCallback (dict);
	}
	
	public void VerifyUserHandler( string jsonString )
	{
		var json = JSON.Parse(jsonString);
		Dictionary<string, string> dict = new Dictionary<string, string>();
		dict.Add ("success", json["success"]);	
		wallet.Add ("depositAddress", json["wallet"]["deposit_address"].Value);
		wallet.Add ("balance", json ["wallet"] ["balance"].Value);
		verifyUserCallback ();
	}
	
	public void GetWalletHandler( string jsonString )
	{
		var json = JSON.Parse(jsonString);
		Dictionary<string, string> dict = new Dictionary<string, string>();
		dict.Add ("success", json["success"]);	
		wallet["depositAddress"] = json["wallet"]["deposit_address"].Value;
		wallet["balance"] = json ["wallet"] ["balance"].Value;
		getWalletCallback (dict);
	}
}
