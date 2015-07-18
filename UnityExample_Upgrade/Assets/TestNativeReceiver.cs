using UnityEngine;
using System.Collections;
using System.Runtime.InteropServices;


public class TestNativeReceiver : MonoBehaviour {

	public string Token;
	public string ApiKey;

	
	void Start() {
		_init( Token, ApiKey );
	}


	public void SimpleUnityFunction( string param ) {
		Debug.Log( "Simple Unity Function. Param="+param );
	}


	
	[DllImport("__Internal")]
	extern static public void _init( string apiKey, string token );
}
