using UnityEngine;
using UnityEngine.SocialPlatforms;
using System;
using System.Collections;
using System.Collections.Generic;



public class Game : MonoBehaviour {
	

    public int Score;


	void Start() {
        RequestCompetition();
    }


    private void RequestCompetition() {
        Arbiter.RequestCompetition();
    }


    private void PlayGame() {
        Score = (int)UnityEngine.Random.Range( 0f, 100f );

    }


}