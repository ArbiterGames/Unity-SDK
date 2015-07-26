using UnityEngine;
using UnityEngine.UI;
using System.Collections;

public class TextFieldPoller : MonoBehaviour {
	
	
	void Start () {
		text = GetComponent<Text>();
	}
	
	protected Text text;

}
