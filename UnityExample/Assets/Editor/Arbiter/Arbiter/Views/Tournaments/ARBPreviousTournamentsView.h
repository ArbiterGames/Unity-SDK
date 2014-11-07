//
//  ARBPreviousTournamentsView.h
//  Unity-iPhone
//
//  Created by Andy Zinsser on 9/9/14.
//
//

#import "ARBPanelView.h"
#import "ARBUITableView.h"
#import "Arbiter.h"

@interface ARBPreviousTournamentsView : ARBPanelView <UITableViewDelegate, UITableViewDataSource>

@property (strong) NSArray *tournaments;
@property (strong) void (^callback)(void);
@property (strong) ARBUITableView *tournamentTable;
@property (strong) UILabel *title;
@property (strong) NSMutableArray *markAsViewedQueue;
@property BOOL excludeViewed;
@property int currentHead;
@property int currentTail;
@property int currentPage;
@property int total;

@property (strong) IBOutlet UIButton *backButton;
@property (strong) IBOutlet UIButton *nextButton;

- (id)init:(Arbiter *)arbiter excludeViewed:(BOOL)excludeViewed;

@end
