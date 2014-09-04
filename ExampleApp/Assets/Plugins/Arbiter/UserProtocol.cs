using SimpleJSON;


namespace ArbiterInternal {
	public class UserProtocol {


		public static User Parse( JSONNode userNode ) {
			User rv = new User();
			fillUser( ref rv, userNode );
			return rv;
		}


		public static bool Update( ref User user, JSONNode userNode ) {
			string rawId = userNode["id"].Value;
			if( user.Id == rawId ) {
				fillUser( ref user, userNode );
				return true;
			} else {
				return false;
			}
		}


		private static void fillUser( ref User user, JSONNode userNode ) {
			user.Id = userNode["id"].Value;
			user.Name = userNode["username"].Value;
			user.LocationApproved = userNode["location_approved"].Value.Equals("true");
			user.AgreedToTerms = userNode["agreed_to_terms"].Value.Equals("true");
			
			// Want to keep the logic of what it takes to be verified in the native plugin, so call down to it rather than duplicate the logic
			user.Verified = ArbiterBinding.IsUserVerified();		
		}

	}
}