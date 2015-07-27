using UnityEngine;
using System.Collections;

public class GameCenterLinker : MonoBehaviour {


	public void LinkWithGameCenter() {
		Debug.Log("ttt Unity button clicked.");
		Arbiter.LoginWithGameCenter( null, LastErrorField.ShowGlobalError ); //ttt handle these

	}


}
