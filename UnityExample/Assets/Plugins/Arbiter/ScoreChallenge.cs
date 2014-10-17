using System;
using System.Collections.Generic;

using ArbiterInternal;


public partial class Arbiter { 
	
	public class ScoreChallenge {
		
		public enum StatusType {
			Unknown,
			Open,
			Busy,
			Closed
		}
		
		public string Id                		{ get { return this.id; } }
		public string ScoreToBeat				{ get { return this.scoreToBeat; } }
		public string EntryFee					{ get { return this.entryFee; } }
		public string Prize						{ get { return this.prize; } }
		public StatusType Status        		{ get { return this.status; } }
		public ScoreChallengeWinner Winner		{ get { return this.winner; } }
		public bool DidUserWin					{ get { return this.winner != null && this.winner.Id == Arbiter.UserId; } }
		
		
		public ScoreChallenge( string id, string scoreToBeat, string entryFee, string prize, StatusType status, Arbiter.ScoreChallengeWinner winner ) {
			this.id = id;
			this.scoreToBeat = scoreToBeat;
			this.entryFee = entryFee;
			this.prize = prize;
			this.status = status;
			this.winner = winner;
		}
		
		
		public override string ToString() {
			string rv = "[ScoreChallenge "+
						"id:"+this.id+", "+
						"scoreToBeat:"+this.ScoreToBeat+", "+
						"entryFee:"+this.EntryFee+", "+
						"prize:"+this.Prize+", "+
						"status:"+this.status+"]]";
			return rv;
		}
		
		
		private string id;
		private string scoreToBeat;
		private string entryFee;
		private string prize;
		private StatusType status;
		private ScoreChallengeWinner winner;
	}
	
	public class ScoreChallengeWinner {
		
		public string Id            { get { return this.id; } }
		public string Score         { get { return this.score; } }
		
		
		public ScoreChallengeWinner( string id, string score ) {
			this.id = id;
			this.score = score;
		}
		
		public override string ToString() {
			return "[Id:"+Id+", score:"+Score+"]";
		}
		
		private string id;
		private string score;
		
	}
}
