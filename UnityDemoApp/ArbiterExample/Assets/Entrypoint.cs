using UnityEngine;
using System.Collections;

public class Entrypoint : MonoBehaviour {
	
	void Start () {
        ArbiterOptionalStep();
    }


    void ArbiterOptionalStep() {
        // ttt TODO: Custom Override Error Handler registration!

        ArbiterStep1();
    }
    
    void ArbiterStep1() {
		Arbiter.Initialize( ArbiterStep2 );
	}
    
    void ArbiterStep2() {
        Arbiter.VerifyUser( ArbiterStep3 );
    }
    
    void ArbiterStep3() {
        Arbiter.AddWalletListener( UpdateWalletElements );
        Arbiter.AddWalletListener( SomeOtherHandler );

        ArbiterDoTheseAsOftenAsYouWant();
    }
    
    
    
    void ArbiterDoTheseAsOftenAsYouWant() { // But only after initialization is complete!
        Arbiter.QueryWallet();
    }



    void UpdateWalletElements() {
        string balance = Arbiter.Balance;
        string depositAddress = Arbiter.DepositAddress;
        string depositQrCode = Arbiter.DepositQrCode;
        string withdrawAddress = Arbiter.WithdrawAddress;

        Debug.Log( "Update elements if needed.\n"+
            "balance="+balance+"\n"+
            "deposit="+depositAddress+"\n"+
            "depositQr="+depositQrCode+"\n"+
            "withdraw="+withdrawAddress
        );
    }


    void SomeOtherHandler() {
        Debug.Log( "Example of other wallet listeners triggering." );
    }
}