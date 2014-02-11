using UnityEngine;
using System;


public class Poller : MonoBehaviour {

    public bool Verbose = true;
        
    public void SetAction( Action<Action> poll ) {
        this.poll = poll;
        Reset();
    }
    

    public void Reset() {
        this.currentPollTime = 1.0f;
        this.nextPollPeriod = 2.0f;
        this.waitingForResponse = false; 
    }


    void Update() {
        if( !this.waitingForResponse ) {
            this.currentPollTime -= Time.deltaTime;
            if( this.currentPollTime < 0 ) {
                this.nextPollPeriod *= 2.0f;
                this.currentPollTime = nextPollPeriod;
                this.waitingForResponse = true;
                          
                if( Verbose ) Debug.Log( "Poll timer complete. Will poll again in " + currentPollTime + " seconds." );                                
                                
                this.poll( callback );
            }
        }
    }
        
        
    private void callback() {
        this.waitingForResponse = false;
    }

        

    private Action<Action> poll;
    private float nextPollPeriod;
    private float currentPollTime;
    private bool waitingForResponse = true;
}