using UnityEngine;
using System.Collections;
using System.Runtime.InteropServices;



public class Arbiter : MonoBehaviour {


	public string Token;
	public string ApiKey;

	
	void Start () {
		_init( ApiKey, Token );
	}
	
	
	[DllImport("__Internal")]
	extern static public void _init( string apiKey, string token );
}
