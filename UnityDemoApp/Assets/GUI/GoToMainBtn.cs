using UnityEngine;
using UnityEngine.SocialPlatforms;
using System;
using System.Collections;
using System.Collections.Generic;



public class GoToMainBtn : MonoBehaviour {
	
	void OnMouseUpAsButton() {
        Application.LoadLevel( "SecondScene" );
    }

}