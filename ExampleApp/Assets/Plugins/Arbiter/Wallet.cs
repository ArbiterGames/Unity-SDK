
namespace ArbiterInternal {
    public class Wallet {

        public string Balance;
      

        public static Wallet CreateMockWallet() {
            Wallet rv = new Wallet();
            rv.Balance = "0";
            return rv;
        }
        
    }
} // namespace ArbiterInternal
