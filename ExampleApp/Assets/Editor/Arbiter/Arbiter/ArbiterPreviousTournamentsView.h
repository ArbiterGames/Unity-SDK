//
//  ArbiterPreviousTournamentsView.h
//  Unity-iPhone
//
//  Created by Andy Zinsser on 9/9/14.
//
//

#import "ArbiterPanelView.h"
#import "ArbiterUITableView.h"
#import "Arbiter.h"

@interface ArbiterPreviousTournamentsView : ArbiterPanelView <UITableViewDelegate, UITableViewDataSource>

@property (strong) NSArray *tournaments;
@property (strong) ArbiterUITableView *tournamentTable;
@property (strong) UILabel *title;
@property int currentHead;
@property int currentTail;
@property int currentPage;
@property int total;

@property (strong) IBOutlet UIButton *backButton;
@property (strong) IBOutlet UIButton *nextButton;

- (id)init:(Arbiter *)arbiter;

@end