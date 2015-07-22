using SimpleJSON;


namespace ArbiterInternal {
	public class UserProtocol {


		public static User Parse( string jsonString ) {
			if( jsonString == null || jsonString == "" )
				return null;

			User rv = new User();
			fillUser( ref rv, JSON.Parse( jsonString ));
			return rv;
		}


		public static bool Update( ref User user, string jsonString ) {
			if( jsonString == null || jsonString == "" ) {
				user = null;
				return false;
			} else {
				JSONNode jsonNode = JSON.Parse( jsonString );
				string rawId = jsonNode["id"].Value;
				if( user != null && user.Id == rawId ) {
					fillUser( ref user, jsonNode );
					return true;
				} else {
					return false;
				}
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