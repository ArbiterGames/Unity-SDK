using UnityEngine;
using System.Collections;

public class GameflowDriver : MonoBehaviour {
	
	void Start () {
		Arbiter.DoOnceOnAuthenticated( LoadMenuHub );
		Arbiter.LoginWithDeviceId( null, null ); // ttt report these
	}

	void LoadMenuHub() {
		Application.LoadLevel( "HubMenu" );
	}

}
