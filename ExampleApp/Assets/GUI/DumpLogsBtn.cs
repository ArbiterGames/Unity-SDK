using UnityEngine;
using ArbiterInternal;


public class DumpLogsBtn : MonoBehaviour {
	
	void OnMouseUpAsButton() {
		string customData = "Example custom data";
		GameObject gameGo = GameObject.Find( "Game" );
		if( gameGo != null ) {
			Game game = gameGo.GetComponent<Game>();
			if( game != null )
				customData = game.Problems;
		}
		Arbiter.DumpLogs( customData );
	}
	
}