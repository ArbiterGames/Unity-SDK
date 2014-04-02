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

        public Player Winner;


        public Competition( string id, StatusType status, List<Player> players ) {
            this.id = id;
            this.status = status;
            this.players = players;
        }


        public bool ContainsUser( User user ) {
            bool rv = false;
            this.players.ForEach( player => {
                if( player.User == user && player.Score == 0 )
					rv = true;
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
}
