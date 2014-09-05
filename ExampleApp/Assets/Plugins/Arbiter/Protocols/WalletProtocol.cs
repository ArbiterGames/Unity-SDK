using SimpleJSON;


namespace ArbiterInternal {
	public class WalletProtocol {


		public static Wallet Parse( string jsonString ) {
			if( jsonString == null || jsonString == "" )
				return null;

			Wallet rv = new Wallet();
			fillWallet( ref rv, JSON.Parse( jsonString ));
			return rv;
		}


		public static void Update( ref Wallet wallet, string jsonString ) {
			if( jsonString == null || jsonString == "" ) {
				wallet = null;
				return;
			}

			JSONNode jsonNode = JSON.Parse( jsonString );
			fillWallet( ref wallet, jsonNode );
		}


		private static void fillWallet( ref Wallet wallet, JSONNode walletNode ) {
			wallet.Balance = walletNode["balance"].Value;
		}

	}
}