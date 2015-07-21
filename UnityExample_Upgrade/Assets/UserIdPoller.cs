using UnityEngine;
using UnityEngine.UI;
using System.Collections;

public class UserIdPoller : MonoBehaviour {


	void Start () {
		text = GetComponent<Text>();
	}
	

	void Update () {
		text.text = Arbiter.UserId;
	}

	Text text;
}
