using UnityEngine;
using System;
using System.Collections.Generic;
using System.Linq;
using ArbiterInternal;


public partial class Arbiter : MonoBehaviour
{
	static Arbiter() {
		// Add a GO to the scene for iOS to send responses back to
		GameObject go = new GameObject( "ArbiterBinding" );
		go.AddComponent<ArbiterBinding>();
		GameObject.DontDestroyOnLoad( go );
        wallet = new Wallet();
        user = new User();

		walletPoller = Poller.Create( "ArbiterWalletPoller" );
		competitionPoller = Poller.Create( "ArbiterCompetitionPoller" );
		DontDestroyOnLoad( walletPoller.gameObject );
		DontDestroyOnLoad( competitionPoller.gameObject );
		walletPoller.Verbose = false;
		competitionPoller.Verbose = true;
	}


    public static string    UserId                      { get { return user.Id; } }
    public static string    Username                    { get { return user.Name; } }
    public static bool      Verified                    { get { return verified == VerificationStatus.Verified; } }
    public static string    Balance                     { get { return wallet.Balance; } }
    public static string    DepositAddress              { get { return wallet.DepositAddress; } }
    public static string    DepositQrCode               { get { return wallet.DepositQrCode; } }
    public static string    WithdrawAddress             { get { return wallet.WithdrawAddress; } }



	public static void Initialize( string gameApiKeyFromDashboard, Action done ) {
        ArbiterBinding.LoginCallback parse = ( responseUser, responseVerified, responseWallet ) => {    // TODO: These anon functions will call the first "done" callback for every call--need to provide proper function closures!
            parseLoginResponse( responseUser, responseVerified, responseWallet, done );
        };
        ArbiterBinding.Init( gameApiKeyFromDashboard, parse, initializeErrorHandler );
	}
    public static Action<List<string>> InitializeErrorHandler { set { initializeErrorHandler = ( errors ) => value( errors ); } }


#if UNITY_IOS
    /// <summary>
    /// Uses Game Center credentials to log in to an Arbiter Account.
    /// </summary>
    /// <param name="done">Called when login was completed successfully</param>
    public static void LoginWithGameCenter( Action done ) {
        ArbiterBinding.LoginCallback parse = ( responseUser, responseVerified, responseWallet ) => {
            parseLoginResponse( responseUser, responseVerified, responseWallet, done );
        };
        ArbiterBinding.LoginWithGameCenter( parse, loginWithGameCenterErrorHandler );
    }
    public static Action<List<string>> LoginWithGameCenterErrorHandler { set { loginWithGameCenterErrorHandler = ( errors ) => value( errors ); } }
#endif


    public static void VerifyUser( Action done ) {
        ArbiterBinding.VerifyUserCallback parse = ( response ) => {
            if( response == true )
                verified = VerificationStatus.Verified;
            if( done != null )
                done();
        };
        verified = VerificationStatus.Unverified;
        ArbiterBinding.VerifyUser( parse, verifyUserErrorHandler );
    }
    public static Action<List<string>> VerifyUserErrorHandler { set { verifyUserErrorHandler = ( errors ) => value( errors ); } }
    
    
    public static void AddWalletListener( Action listener ) {
        if( !walletQueryListeners.Contains( listener ))
            walletQueryListeners.Add( listener );
    }
    public static void RemoveWalletListener( Action listener ) {
        walletQueryListeners.Remove( listener );
    }


    public static void QueryWallet() {
        if( user == null )
            Debug.LogWarning( "Cannot query an Arbiter Wallet without first logging in. Did you call Arbiter.Initialize()?" );
        else if( verified == VerificationStatus.Unknown )
            Debug.LogWarning( "This user has not yet been verified and cannot query an Arbiter wallet. Did you call Arbiter.VerifyUser()?" );

        queryWalletIfAble( null );
    }
    private static void queryWalletIfAble( Action callback ) {
        walletSuccessCallback = callback;

        if( user == null || verified != VerificationStatus.Verified ) {
            if( walletSuccessCallback != null )
                walletSuccessCallback();
            return;
        }

        ArbiterBinding.GetWallet( walletSuccessHandler, walletErrorHandler );
    }
    private static void walletSuccessHandler( Wallet responseWallet ) {
        wallet = responseWallet;
        walletQueryListeners.ForEach( listener => listener() );
        if( walletSuccessCallback != null )
            walletSuccessCallback();
    }


    public static void ShowWalletPanel( Action callback ) {
        ArbiterBinding.ShowWalletPanel( callback );
    }

	
    public delegate void GetScorableCompetitionCallback( Competition competition );
	/// <summary>
	/// Finds an existing competition that you could join. If no available competitions are found, requests a new one and returns that.
	/// </summary>
    public static void GetScorableCompetition( string buyIn, Dictionary<string,string> filters, GetScorableCompetitionCallback callback ) {
        getScorableCompetitionCallback = callback; // ttt kill the class member?

		Func<Competition,bool> isScorableByCurrentUser = ( competition ) => {
			return (competition.Status == Competition.StatusType.Initializing || competition.Status == Competition.StatusType.InProgress) &&
				competition.UserCanReportScore( user );
		};

		GetCompetitionsCallback gotCompetitionsPollHelper = ( competitions ) => {
			Debug.Log("ttt competitions poll helper....");
			List<Competition> joinableCompetitions = competitions.Where( iComp => isScorableByCurrentUser( iComp )).ToList();
			if( joinableCompetitions.Count > 0 ) {
				Debug.Log("ttt found one!");
				competitionPoller.Stop();
				callback( joinableCompetitions[0] );
			} else {
				Debug.Log("ttt not found. Waiting for poller to ask again. !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!");
				Debug.Log("***************************************************************************");
			}
		};

		Action askAgain = () => {
			Debug.Log("ttt ask again....");
			ArbiterBinding.GetCompetitions( gotCompetitionsPollHelper, getCompetitionsErrorHandler );
		};
		
		RequestCompetitionCallback gotRequestResponse = () => {
			competitionPoller.SetAction( askAgain );
		};

		GetCompetitionsCallback gotCompetitionsFirstTimeHelper = ( competitions ) => {
			List<Competition> joinableCompetitions = competitions.Where( iComp => isScorableByCurrentUser( iComp )).ToList();
			Debug.Log("ttt gotCompetitionsFirstTime. Found scorable count="+joinableCompetitions.Count);
			joinableCompetitions.ForEach( comp => Debug.Log( "ttt comp="+comp.Id ));
			
			if( joinableCompetitions.Count > 0 ) {
				callback( joinableCompetitions[0] );
			} else {
				RequestCompetition( buyIn, filters, gotRequestResponse );
			}
		};





		ArbiterBinding.GetCompetitions( gotCompetitionsFirstTimeHelper, getCompetitionsErrorHandler );


		// ttt OLD....
		// Assume that the poll function called here will request a new competition if it doesn't find any acceptable ones on the first try.
		//pollUntilScorableCompetitionFound( buyIn, filters );
    }
	/* ttt
	private GetCompetitionsCallback GotCompetitionsFirstTimeHelper( List<Competition> competitions ) {
		List<Competition> joinableCompetitions = competitions.Where( c => isJoinable( c ));
		joinableCompetitions.ForEach( comp => Debug.Log( "ttt comp="+comp.Id ));
		
		if( joinableCompetitions.Count > 0 ) {
			return joinableCompetitions[0];
		} else {
			RequestCompetition( buyIn, filters, GotCompetitionsSecondTimeHelper );
		}
	}
	private bool IsJoinable( Competition competition ) {
		return true;
	}
	private GetCompetitionsCallback GotCompetitionsSecondTimeHelper( List<Competition> competitions ) {
		Debug.Log("ttt got competitions 2nd time helper....");
		List<Competition> joinableCompetitions = competitions.Where( c => isJoinable( c ));
		if( 
	}
	*/


    public delegate void RequestCompetitionCallback();
	/// <summary>
	/// Requests a new Competition. See also GetScorableCompetition(...).
	/// </summary>
    public static void RequestCompetition( Dictionary<string,string> filters, RequestCompetitionCallback callback ) {
        RequestCompetition( null, filters, callback );
    }
    public static void RequestCompetition( string buyIn, Dictionary<string,string> filters, RequestCompetitionCallback callback ) {
        if( filters == null ) {
            filters = new Dictionary<string,string>();
        }
        
		Debug.Log("ttt reqeusting competition from the binding...");
        ArbiterBinding.RequestCompetition( buyIn, filters, callback, defaultErrorHandler );
    }


	/// <summary>
	/// Asks the server for a list of competitions in various stages.
	/// </summary>
    public static void QueryCompetitions( Action callback ) {
        getCompetitionsCallback = callback;
        ArbiterBinding.GetCompetitions( GetCompetitionsSuccessHandler, getCompetitionsErrorHandler );
    }
    public delegate void GetCompetitionsCallback( List<Competition> competitions );
    public static void GetCompetitionsSuccessHandler( List<Competition> competitions ) {
        initializingCompetitions = competitions.Where( c => c.Status == Competition.StatusType.Initializing ).ToList();
        inProgressCompetitions = competitions.Where( c => c.Status == Competition.StatusType.InProgress ).ToList();
        completeCompetitions = competitions.Where( c => c.Status == Competition.StatusType.Complete ).ToList();
        getCompetitionsCallback();
    }


	public static List<Competition> InitializingCompetitions {
        get {
			return initializingCompetitions;
        }
    }
    public static List<Competition> InProgressCompetitions {
        get {
            return inProgressCompetitions;
        }
    }
    public static List<Competition> CompleteCompetitions {
        get {
            return completeCompetitions;
        }
    }


    public delegate void ViewPreviousCompetitionsCallback();
    public static void ViewPreviousCompetitions( ViewPreviousCompetitionsCallback callback ) {
        if( callback == null )
            callback = () => {};
        ArbiterBinding.ViewPreviousCompetitions( callback );
    }
    
    
	public delegate void ViewIncompleteCompetitionsCallback( string competitionId );
	public static void ViewIncompleteCompetitions( ViewIncompleteCompetitionsCallback callback ) {
		if( callback == null )
			callback = ( String competitionId ) => {};
		ArbiterBinding.ViewIncompleteCompetitions( callback );
	}


    public delegate void ReportScoreCallback( Competition competition );
    public static void ReportScore( string competitionId, int score, ReportScoreCallback callback ) {
        if( callback == null )
            Debug.LogError( "Must pass in a non-null handler to Arbiter.ReportScore" );
        ArbiterBinding.ReportScore( competitionId, score, callback, defaultErrorHandler );
    }


	/* tttk
	private static void pollUntilScorableCompetitionFound( string buyIn, Dictionary<string,string> filters ) {
        competitionPoller.SetAction( () => {
			Action findExistingFromCacheOrRequestNewCompetition = () => {
				Competition found = findScorableCompetition();
				Debug.Log("ttt found="+found);
				Debug.Log("ttt getScorableCompetitionCallback="+getScorableCompetitionCallback);
				if( found != null ) {
					if( getScorableCompetitionCallback != null )
						getScorableCompetitionCallback( found );
					getScorableCompetitionCallback = null;
					competitionRequestSemaphore = 0;
					competitionPoller.Stop();
				} else {
					requestNewCompetitionOrWait( buyIn, filters );
				}
			};
			Arbiter.QueryCompetitions( findExistingFromCacheOrRequestNewCompetition );
        });
    }
	private static Competition findScorableCompetition() {
		Debug.Log("ttt findScorableCompetition()");
        IEnumerator<Competition> e = inProgressCompetitions.GetEnumerator();
        Competition found = null;
        while( e.MoveNext() ) {
            Competition c = e.Current;
			if( c.UserHasNotReportedScore( user )) {
                found = c;
                break;
            }
        }
        
        if ( found == null ) {
        	e = initializingCompetitions.GetEnumerator();
			while( e.MoveNext() ) {
				Competition c = e.Current;
				if( c.UserHasNotReportedScore( user )) {
					found = c;
					break;
				}
			}
        }

		return found;
    }
	private static void requestNewCompetitionOrWait( string buyIn, Dictionary<string,string> filters ) {
		Debug.Log("ttt semaphore="+competitionRequestSemaphore);
		if( competitionRequestSemaphore <= 0 ) {
			competitionRequestSemaphore += 1;
			RequestCompetitionCallback tryAgain = () => {
				competitionPoller.Reset();
			};
			RequestCompetition( buyIn, filters, tryAgain );
		}
		// else wait for the poller to catch the recently-requested competition!
	}
	*/


    private static void defaultErrorHandler( List<string> errors ) {
        string msg = "";
        errors.ForEach( error => msg+=error+"\n" );
        Debug.LogError( "There were problems with an Arbiter call:\n"+msg );
    }


    private static void parseLoginResponse( User responseUser, bool responseVerified, Wallet responseWallet, Action done ) {
        user = responseUser;
        verified = responseVerified? VerificationStatus.Verified : VerificationStatus.Unknown;
        wallet = responseWallet != null? responseWallet : new Wallet();
        
        walletPoller.SetAction( queryWalletIfAble );
        done();
    }



    private static Poller walletPoller;
    private static Poller competitionPoller;
    private static User user;
    private enum VerificationStatus { Unknown, Unverified, Verified };
    private static VerificationStatus verified = VerificationStatus.Unknown;
    private static Wallet wallet;
	private static List<Competition> initializingCompetitions;
    private static List<Competition> inProgressCompetitions;
    private static List<Competition> completeCompetitions;
	private static int competitionRequestSemaphore = 0;

    private static ArbiterBinding.ErrorHandler initializeErrorHandler = defaultErrorHandler;
    private static Action walletSuccessCallback;
    private static List<Action> walletQueryListeners = new List<Action>();
    private static ArbiterBinding.ErrorHandler walletErrorHandler = defaultErrorHandler;
    private static ArbiterBinding.ErrorHandler verifyUserErrorHandler = defaultErrorHandler;
    private static GetScorableCompetitionCallback getScorableCompetitionCallback;
    private static Action getCompetitionsCallback;
    private static ArbiterBinding.ErrorHandler getCompetitionsErrorHandler = defaultErrorHandler;
	private static Action viewIncompleteCompetitionsCallback;
#if UNITY_IOS
    private static ArbiterBinding.ErrorHandler loginWithGameCenterErrorHandler = defaultErrorHandler;
#endif
}
