using UnityEngine;
using System.Collections;

public class WalletBalancePoller : DynamicTextField {
	
	void Update () {
		SetText( Arbiter.Balance );
	}

}
