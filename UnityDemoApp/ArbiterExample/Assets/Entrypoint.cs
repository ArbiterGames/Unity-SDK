using UnityEngine;
using System.Collections;

public class Entrypoint : MonoBehaviour {
	
	void Start () {
        ArbiterStep1();
    }
    
    
    void ArbiterStep1() {
		Arbiter.Initialize( ArbiterStep2 );
	}
    
    void ArbiterStep2() {
        Arbiter.VerifyUser( ArbiterStep3 );
    }
    
    void ArbiterStep3() {
        ArbiterDoTheseAsOftenAsYouWant();
    }
    
    
    
    void ArbiterDoTheseAsOftenAsYouWant() { // But only after initialization is complete!
        Arbiter.QueryWallet( UpdateWalletElements );
    }

    void UpdateWalletElements() {
        // ttt update the wallet totals and stuff
    }
}