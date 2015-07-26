using UnityEngine;
using UnityEngine.UI;
using System.Collections;

public class UserIdPoller : TextFieldPoller {

	void Update () {
		text.text = Arbiter.UserId;
	}

}
