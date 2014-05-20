using System.Collections.Generic;

using ArbiterInternal;


public partial class Arbiter { // TODO: Cleanup the namespace usage. Causes somewhat awkard usage that this isn't actually a namespace
    public class Competition {

        public enum StatusType {
            Unknown,
            Initializing,
            InProgress,
            Complete
        }
        public string Id                { get { return this.id; } }
        public StatusType Status        { get { return this.status; } }
        public List<Player> Players     { get { return this.players; } }
        public Jackpot Jackpot          { get { return this.jackpot; } }

        public Player Winner;


        public Competition( string id, StatusType status, List<Player> players, Jackpot jackpot ) {
            this.id = id;
            this.status = status;
            this.players = players;
            this.jackpot = jackpot;
        }


        /// <summary>
        /// Attempts to retrieve the score for a player wrapped around the given userId.
        /// </summary>
        /// <returns><c>true</c>, if score was retrieved, <c>false</c> otherwise.</returns>
        public bool GetScoreForUserId( string userId, out int score ) {
            foreach( var player in this.players ) {
                if( player.User.Id == userId ) {
                    score = player.Score;
                    return true;
                }
            }
            score = 0;
            return false;
        }


        /// <summary>
        /// Attempts to retrieve the score for a player NOT wrapped around the given userId.
        /// This call usually only makes sense for 2-player games
        /// </summary>
        /// <returns><c>true</c>, if score was retrieved, <c>false</c> otherwise.</returns>
        public bool GetScoreForOtherUserId( string userId, out int score ) {
            foreach( var player in this.players ) {
                if( player.User.Id != userId ) {
                    score = player.Score;
                    return true;
                }
            }
            score = 0;
            return false;
        }


        public bool UserCanReportScore( User user ) {
			if( this.jackpot == null )
				return false;

            bool rv = false;
            this.players.ForEach( player => {
                if( player.User == user && player.Score == 0 ) {
	            	rv = true;
				}
            });
            return rv;
        }


        public override string ToString() {
            string rv = "[Competition "+
                "id:"+this.id+", "+
                "status:"+this.status+", "+
                "players:[";
            this.players.ForEach( player => {
                rv += player +", ";
            });
            rv += "]]";
            return rv;
        }


        private string id;
        private StatusType status;
        private List<Player> players;
		private Jackpot jackpot;

    }


    public class Player {

        public int Score            { get { return this.score; } }
        public User User            { get { return this.user; } }


        public void SetScore( int score ) {
            this.score = score;
        }

        public Player( User user ) {
            this.user = user;
        }


        public override string ToString() {
            return "[Player user:"+User+", score:"+Score+"]";
        }


        private int score;
        private User user;

    }


    public class Jackpot {

        public string Id;
		public string BuyIn;
		public string Balance;

        public override string ToString() {
            return "[Jackpot id:"+Id+", buyIn:"+BuyIn+", balance:"+Balance+"]";
        }
    }
}
