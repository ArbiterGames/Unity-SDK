using UnityEngine;
using System.Collections;

public class ViewResultsButton : MonoBehaviour {

	Game game;
	
	void Awake() {
		GameObject gameObject = GameObject.Find ("Game");
		game = gameObject.GetComponent<Game>();
	}
	
	void OnMouseUpAsButton() {
		Arbiter.ShowTournamentDetails( game.TournamentId, OnDetailsClosed );
	}
	
	void OnDetailsClosed() {
		Debug.Log ("Tournament Details callback");
	}
}
