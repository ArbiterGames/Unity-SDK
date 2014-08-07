using System;
using System.Collections.Generic;

using ArbiterInternal;


public partial class Arbiter { 

	public class Tournament {
		
		public enum StatusType {
			Unknown,
			Initializing,
			InProgress,
			Complete
		}
		
		public string Id                		{ get { return this.id; } }
		public StatusType Status        		{ get { return this.status; } }
		public List<TournamentUser> Users     	{ get { return this.users; } }
		public List<string> Winners				{ get { return this.winners; } }
		
		
		public Tournament( string id, StatusType status, List<TournamentUser> users, List<string> winners ) {
			this.id = id;
			this.status = status;
			this.users = users;
			this.winners = winners;
		}
		
		public bool GetScoreForUserId( string userId, out int score ) {
			foreach( var user in this.users ) {
				if( user.Id == userId && user.HasScore ) {
					score = user.Score.Value;
					return true;
				}
			}
			score = 0;
			return false;
		}
		
		public bool GetScoreForOtherUserId( string userId, out int score ) {
			foreach( var user in this.users ) {
				if( user.Id != userId && user.HasScore ) {
					score = user.Score.Value;
					return true;
				}
			}
			score = 0;
			return false;
		}
		
		
		public bool UserCanReportScore( string id ) {
			bool rv = false;
			this.users.ForEach( user => {
				if( user.Id == id && user.Paid && !user.HasScore ) {
					rv = true;
				}
			});
			return rv;
		}
		
		
		public override string ToString() {
			string rv = "[Tournament "+
				"id:"+this.id+", "+
					"status:"+this.status+", "+
					"users:[";
			this.users.ForEach( user => {
				rv += user +", ";
			});
			rv += "]]";
			return rv;
		}
		
		
		private string id;
		private StatusType status;
		private List<TournamentUser> users;
		private List<string> winners;
	}
	
	public class TournamentUser {

		public string Id            { get { return this.id; } }
		public bool Paid			{ get { return this.paid; } set { this.paid = value; } }
		public bool HasScore		{ get { return this.score.HasValue; } }
		public int? Score           { get { return this.score; } set { this.score = value; } }

		
		public TournamentUser( string id ) {
			this.id = id;
			this.paid = false;
			this.score = null;
		}

		public void SetScore( int score ) {
			this.score = score;
		}
		
		public override string ToString() {
			return "[Id:"+Id+", paid:"+paid+", score:"+Score+"]";
		}
		
		private string id;
		private bool paid;
		private int? score;
		
	}

}
