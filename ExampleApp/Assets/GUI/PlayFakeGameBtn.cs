using UnityEngine;
using UnityEngine.SocialPlatforms;
using System;
using System.Collections;
using System.Collections.Generic;



public class PlayFakeGameBtn : MonoBehaviour {
	
	void OnMouseUpAsButton() {
        Application.LoadLevel( "FakeGameScene" );
    }

}