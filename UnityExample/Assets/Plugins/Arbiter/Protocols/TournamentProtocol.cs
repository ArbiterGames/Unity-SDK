using System.Collections;
using System.Collections.Generic;
using UnityEngine;

using SimpleJSON;


namespace ArbiterInternal {
	public class TournamentProtocol {
		

		public static List<Arbiter.Tournament> ParseTournaments( JSONNode tournamentsNode ) {
			List<Arbiter.Tournament> rv = new List<Arbiter.Tournament>();
			JSONArray rawTournaments = tournamentsNode.AsArray;
			IEnumerator enumerator = rawTournaments.GetEnumerator();
			while( enumerator.MoveNext() ) {
				JSONClass tournament = enumerator.Current as JSONClass;
				rv.Add( ParseTournament( tournament ));
			}
			return rv;
		}


		public static Arbiter.Tournament ParseTournament( JSONClass tournamentNode ) {
			Arbiter.Tournament.StatusType status = Arbiter.Tournament.StatusType.Unknown;
			
			switch( tournamentNode["status"] ) {
			case "initializing":
				status = Arbiter.Tournament.StatusType.Initializing;
				break;
			case "inprogress":
				status = Arbiter.Tournament.StatusType.InProgress;
				break;
			case "complete":
				status = Arbiter.Tournament.StatusType.Complete;
				break;
			default:
				Debug.LogError( "Unknown status encountered: " + tournamentNode["status"] );
				break;
			}
			
			List<Arbiter.TournamentUser> users = ParseUsers( tournamentNode["users"] );
			List<string> winners = ParseWinners( tournamentNode["winners"] );
			Arbiter.Tournament rv = new Arbiter.Tournament( tournamentNode["id"], status, users, winners );
			
			return rv;
		}


		// I'm sure the is a more elegant way of converting items in the JSON array in a c# list of strings, but this solves the type casting issue for now
		public static List<string> ParseWinners( JSONNode winnersNode ) {
			List<string> winners = new List<string>();
			if ( winnersNode != null ) {
				JSONArray rawNode = winnersNode.AsArray;
				IEnumerator enumerator = rawNode.GetEnumerator();
				while( enumerator.MoveNext() ) {
					JSONData winnerId = enumerator.Current as JSONData;
					winners.Add( winnerId.Value );
				}
			}	
			return winners;
		}


		// Parses the Tournament.Users JSON array returned from the server and converts each item into a c# TournamentUser
		public static List<Arbiter.TournamentUser> ParseUsers( JSONNode usersNode ) {
			List<Arbiter.TournamentUser> rv = new List<Arbiter.TournamentUser>();
			JSONArray rawUsers = usersNode.AsArray;
			IEnumerator enumerator = rawUsers.GetEnumerator();
			while( enumerator.MoveNext() ) {
				JSONClass userNode = enumerator.Current as JSONClass;
				string id = userNode["id"];
				string username = userNode["username"];
				bool paid = userNode["paid"].AsBool;
				string score = userNode["score"];
				
				// TODO: Parse if the user has viewed this tournament. For now assume they have not
				bool viewed = false;

				Arbiter.TournamentUser user = new Arbiter.TournamentUser( id );
				user.Paid = paid;
				user.Username = username;
				user.Viewed = viewed;
				
				if( score != null && score != "null" && score != "<null>" )                	
					user.Score = int.Parse( score );
				
				rv.Add( user );
			}
			return rv;
		}


	}
}