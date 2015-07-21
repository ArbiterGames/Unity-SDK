using UnityEngine;


public class ArbiterErrorCodes {

	public const string INSUFFICIENT_FUNDS = "nsf";

	/* ttt
	public static SuccessHandler ActionFor( string code, SuccessHandler done ) {
		switch( code ) {

		case INSUFFICIENT_FUNDS:
			SuccessHandler show = () => { Arbiter.DisplayWalletDashboardOnDepositTab( done ); };
			return show;

		default:
			Debug.LogError( "Unknown errorcode: "+code );
			return done;
		}
	}
*/
}
