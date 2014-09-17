using UnityEngine;
using System.Collections;

public class ShowWalkThroughBtn : MonoBehaviour {

	void OnMouseUpAsButton() {
		Arbiter.ShowWalkThrough( "Overview", OnWalkThroughClosed );
	}
	
	void OnWalkThroughClosed() {
		Debug.Log("Walk through closed");
	}
}
