using UnityEngine;
using System.Collections;

public class GameState : MonoBehaviour {
	
	public static GameState instance;
	public string CurrentTournamentId;
	
	void Awake() {
		if ( !instance ) {
			instance = this;
			DontDestroyOnLoad( gameObject );
		} else {
			Destroy( gameObject );
		}
	}
	
}
