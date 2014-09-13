using UnityEngine;


public class ShowUnviewedTournaments : MonoBehaviour {
	
	void OnMouseUpAsButton() {
		Arbiter.ShowUnviewedTournaments( Done );
	}


	void Done() {
		Debug.Log( "Done showing tournaments." );
	}
	
}