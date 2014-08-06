using UnityEngine;
using System.Collections;

public class ViewResultsButton : MonoBehaviour {

	void OnMouseUpAsButton() {
		Arbiter.DisplayTournamentDetails( "TODO: GET THE REAL TOURNAMENT ID", OnDetailsClosed );
	}
	
	void OnDetailsClosed() {
		Debug.Log ("Tournament Details callback");
	}
}
