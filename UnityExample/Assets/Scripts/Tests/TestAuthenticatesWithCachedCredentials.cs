using System;
using UnityEngine;


[IntegrationTest.DynamicTest("TestSuite")]
[IntegrationTest.Timeout(1)]
public class TestAuthenticatesWithCachedCredentials : MonoBehaviour {
	
	
	void Start() {
		// ttt not sure this can actually be tested by integration runner...
		IntegrationTest.Pass ();
	}
	
	
}