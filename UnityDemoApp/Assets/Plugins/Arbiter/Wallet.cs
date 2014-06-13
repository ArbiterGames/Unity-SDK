
namespace ArbiterInternal {
    public class Wallet {

		// TODO: Add pending balance
        public string Balance;
        public string DepositAddress;
        public string DepositQrCode;
        public string WithdrawAddress;


        public static Wallet CreateMockWallet() {
            Wallet rv = new Wallet();
            rv.Balance = "0";
            rv.DepositAddress = "1234567890MockWalletDepositAddress";
            rv.DepositQrCode = "http://mockurl.com";
            rv.WithdrawAddress = "123456789MockWalletWithdrawAddress";
            return rv;
        }
        
    }
} // namespace ArbiterInternal
