using UnityEngine;
using System;
using System.Collections;
using System.Collections.Generic;



[RequireComponent (typeof (GUIText))]
public class ProblemsPoller : MonoBehaviour {
	

    void Start() {
        game = GameObject.Find( "Game" ).GetComponent<Game>();
        textField = gameObject.GetComponent<GUIText>();
    }
    private Game game;
    private GUIText textField;


	void Update () {
        if( game.Problems != null )
            textField.text = game.Problems;
    }


}