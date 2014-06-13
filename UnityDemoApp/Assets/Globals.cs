using UnityEngine;
using System.Collections;

public class Globals : MonoBehaviour {

	public string SelectedUnfinishedTournamentId;
	
	void Start() {
		DontDestroyOnLoad( this.gameObject );
	}
}
