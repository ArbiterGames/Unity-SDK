using System.Collections;
using System.Collections.Generic;
using UnityEngine;

using SimpleJSON;


namespace ArbiterInternal {

	public class ScoreChallengeProtocol {
		
		public static Arbiter.ScoreChallenge ParseScoreChallenge( JSONClass node ) {
			Arbiter.ScoreChallenge.StatusType status = Arbiter.ScoreChallenge.StatusType.Unknown;
			
			switch( node["status"] ) {
			case "open":
				status = Arbiter.ScoreChallenge.StatusType.Open;
				break;
			case "busy":
				status = Arbiter.ScoreChallenge.StatusType.Busy;
				break;
			case "closed":
				status = Arbiter.ScoreChallenge.StatusType.Closed;
				break;
			default:
				Debug.LogError( "Unknown status encountered: " + node["status"] );
				break;
			}
			
			Arbiter.ScoreChallengeWinner winner = ParseWinner( node["winner"] );
			Arbiter.ScoreChallenge rv = new Arbiter.ScoreChallenge( node["id"], 
																	node["score_to_beat"], 
																	node["entry_fee"],
																	node["prize"],
																	status, 
																	winner );
			return rv;
		}
		
		public static Arbiter.ScoreChallengeWinner ParseWinner( JSONNode node ) {
			if ( node != null ) {
				string id = node["id"];
				string score = node["score"];
				return new Arbiter.ScoreChallengeWinner( id, score );
			} else {
				return null;
			}
		}
	}
}