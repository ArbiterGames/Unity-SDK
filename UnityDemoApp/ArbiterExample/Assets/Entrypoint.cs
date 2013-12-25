using UnityEngine;
using System.Collections;

public class Entrypoint : MonoBehaviour {
	
	// Use this for initialization
	void Start () {
		Debug.Log( "Started the Unity test app." );
		NativeBinding.Foo();
	}
	
	// Update is called once per frame
	void Update () {
		
	}
}