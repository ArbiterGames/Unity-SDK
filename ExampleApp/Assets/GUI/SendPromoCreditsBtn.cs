using UnityEngine;
using UnityEngine.SocialPlatforms;
using System;
using System.Collections;
using System.Collections.Generic;



public class SendPromoCreditsBtn : MonoBehaviour {
	
	void OnMouseUpAsButton() {
		Arbiter.SendPromoCredits( "10", SendPromoCreditsCallback );
	}
	
	void SendPromoCreditsCallback() {
		Debug.Log ("Wallet balance should have gone up by 10");
	}
	
}
