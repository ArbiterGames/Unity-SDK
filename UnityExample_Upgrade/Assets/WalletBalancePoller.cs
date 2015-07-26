using UnityEngine;
using System.Collections;

public class WalletBalancePoller : TextFieldPoller {
	
	void Update () {
		text.text = Arbiter.Balance;
	}

}
