using UnityEngine;
using ArbiterInternal;


public class DumpLogsBtn : MonoBehaviour {
	
	void OnMouseUpAsButton() {
		ArbiterInternal.Logger.Dump();
	}
	
}