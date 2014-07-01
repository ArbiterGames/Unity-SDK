using UnityEngine;
using UnityEngine.SocialPlatforms;
using System;
using System.Collections;
using System.Collections.Generic;



public class ViewPreviousGamesBtn : MonoBehaviour {
	
	void OnMouseUpAsButton() {
        Arbiter.ViewPreviousTournaments( null );
    }

}