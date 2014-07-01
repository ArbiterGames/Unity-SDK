using UnityEngine;
using System;
using System.Collections;
using System.Collections.Generic;



[RequireComponent (typeof (GUIText))]
public class TournamentIdPoller : MonoBehaviour {
	

    void Awake() {
        textField = gameObject.GetComponent<GUIText>();
        game = GameObject.Find( "Game" ).GetComponent<Game>();
    }
    private GUIText textField;
    private Game game;


	void OnGUI() {
        textField.text = game.TournamentId;
    }


}