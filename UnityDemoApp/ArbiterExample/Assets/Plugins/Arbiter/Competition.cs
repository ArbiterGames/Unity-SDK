using System.Collections.Generic;

using ArbiterInternal;


public partial class Arbiter { // TODO: Cleanup the namespace usage. Causes somewhat awkard usage that this isn't actually a namespace
    public class Competition {

        public enum StatusType {
            Unknown,
            Open,
            InProgress,
            Complete
        }
        public string Id                { get { return this.id; } }
        public StatusType Status        { get { return this.status; } }
        public List<Player> Players     { get { return this.players; } }

        public Competition( string id, StatusType status, List<Player> players ) {
            this.id = id;
            this.status = status;
            this.players = players;
        }

        private string id;
        private StatusType status;
        private List<Player> players;

    }


    public class Player {

        public void SetScore( int score ) {
            this.score = score;
        }

        public Player( User user ) {
            this.user = user;
        }

        private int score;
        private User user;

    }
}
