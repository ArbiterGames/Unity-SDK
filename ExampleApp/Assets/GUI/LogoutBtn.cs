using UnityEngine;
using System.Collections;



public class LogoutBtn : MonoBehaviour {
	
	void OnMouseUpAsButton() {
        Arbiter.Logout( LogoutCallback );
    }
    
    void LogoutCallback() {
    	Application.LoadLevel("StartupScene");
    }

}