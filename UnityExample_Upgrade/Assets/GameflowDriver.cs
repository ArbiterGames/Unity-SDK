using UnityEngine;
using System.Collections;

public class GameflowDriver : MonoBehaviour {
	
	void Start () {
		Arbiter.DoOnceOnAuthenticated( LoadMenuHub );
	}

	void LoadMenuHub() {
		Application.LoadLevel( "HubMenu" );
	}

}
