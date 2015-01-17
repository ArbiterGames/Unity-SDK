using System;
using UnityEngine;


[IntegrationTest.DynamicTest("TestSuite")]
[IntegrationTest.SucceedWithAssertions]
[IntegrationTest.Timeout(1)]
public class BasicTest : MonoBehaviour {
	
	
	void Start() {
		IntegrationTest.Pass ();
    }
    

}