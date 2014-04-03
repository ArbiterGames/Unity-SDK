using UnityEngine;
using System.Collections;

public class Globals : MonoBehaviour {

	public string SelectedUnfinishedCompetitionId;
	
	void Start() {
		DontDestroyOnLoad( this.gameObject );
	}
}
