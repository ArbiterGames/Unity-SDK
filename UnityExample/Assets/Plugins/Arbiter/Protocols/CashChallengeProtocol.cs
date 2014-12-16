using System.Collections;
using System.Collections.Generic;
using UnityEngine;

using SimpleJSON;


namespace ArbiterInternal {

	public class CashChallengeProtocol {
		
		public static Arbiter.CashChallenge ParseCashChallenge( JSONClass node ) {
			Arbiter.CashChallenge.StatusType status = Arbiter.CashChallenge.StatusType.Unknown;
			
			switch( node["status"] ) {
			case "open":
				status = Arbiter.CashChallenge.StatusType.Open;
				break;
			case "busy":
				status = Arbiter.CashChallenge.StatusType.Busy;
				break;
			case "closed":
				status = Arbiter.CashChallenge.StatusType.Closed;
				break;
			default:
				Debug.LogError( "Unknown status encountered: " + node["status"] );
				break;
			}
			
			Arbiter.CashChallengeWinner winner = ParseWinner( node["winner"] );
			Arbiter.CashChallenge rv = new Arbiter.CashChallenge( node["id"], 
																  node["score_to_beat"], 
																  node["entry_fee"],
																  node["prize"],
																  status, 
																  winner );
			return rv;
		}
		
		public static Arbiter.CashChallengeWinner ParseWinner( JSONNode node ) {
			if ( node != null ) {
				string id = node["id"];
				string score = node["score"];
				return new Arbiter.CashChallengeWinner( id, score );
			} else {
				return null;
			}
		}
	}
}