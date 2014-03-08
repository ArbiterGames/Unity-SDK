using UnityEngine;
using UnityEngine.SocialPlatforms;
using System;
using System.Collections;
using System.Collections.Generic;



public class ViewWalletBtn : MonoBehaviour {
	
	void OnMouseUpAsButton() {
        Arbiter.ShowWalletPanel( null );
    }

}