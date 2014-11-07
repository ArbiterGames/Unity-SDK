//
//  ARBTransactionSuccessView.m
//  Unity-iPhone
//
//  Created by Andy Zinsser on 9/6/14.
//
//

#import "ARBTransactionSuccessView.h"

#define CELL_LABEL_TAG 1
#define CELL_BUTTON_TAG 2


@implementation ARBTransactionSuccessView

- (id)initWithCallback:(void(^)(void))callback
{
    self = [super init];
    if ( self ) {
        self.callback = callback;
    }
    return self;
}


# pragma mark TableView Delegate Methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 2;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *i = @"TransactionSuccessCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:i];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:i];
        [cell setBackgroundColor:[UIColor clearColor]];
        
        if ( indexPath.row == 0 ) {
            UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0.0, 0.0, cell.frame.size.width, cell.frame.size.height)];
            label.tag = CELL_LABEL_TAG;
            label.textAlignment = NSTextAlignmentCenter;
            label.textColor = [UIColor whiteColor];
            label.text = @"Your request was successful!";
            [cell.contentView addSubview:label];
        } else if ( indexPath.row == 1 ) {
            UIButton *backButton = [UIButton buttonWithType:UIButtonTypeSystem];
            [backButton setFrame:CGRectMake(0.0 , 0.0, cell.frame.size.width, cell.frame.size.height)];
            [backButton setTitle:@"Back to your Game" forState:UIControlStateNormal];
            [backButton.titleLabel setFont:[UIFont boldSystemFontOfSize:17.0]];
            [backButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            [backButton addTarget:self action:@selector(backButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
            [cell.contentView addSubview:backButton];
        }
    }
    
    return cell;
}

- (void)backButtonClicked:(id)sender
{
    self.callback();
}


@end
