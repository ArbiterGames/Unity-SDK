using UnityEngine;
using UnityEngine.UI;
using System.Collections;

public class UserIdPoller : DynamicTextField {

	void Update () {
		SetText( Arbiter.UserId );
	}

}
