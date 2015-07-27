using UnityEngine;
using UnityEngine.UI;
using System.Collections;

public class DynamicTextField : MonoBehaviour {
	
	
	void Start () {
		Initialize();
	}

	protected virtual void Initialize() {
		text = GetComponent<Text>();
	}

	public void SetText( string text ) {
		this.text.text = text;
	}
	
	private Text text;

}
