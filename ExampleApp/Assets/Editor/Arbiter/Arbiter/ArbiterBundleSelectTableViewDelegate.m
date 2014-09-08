//
//  ArbiterBundleSelectView.m
//  Unity-iPhone
//
//  Created by Andy Zinsser on 9/4/14.
//
//

#import "ArbiterBundleSelectTableViewDelegate.h"

#define CELL_LABEL_TAG 10
#define CELL_VALUE_TAG 11

@implementation ArbiterBundleSelectView
{
    NSMutableArray *_availableBundles;
    void (^_selectionCallback)(NSDictionary *_selectedBundle);
}

- (id)initWithBundles:(NSMutableArray *)availableBundles andSelectionCallback:(void(^)(NSDictionary *))selectionCallback
{
    self = [super init];
    if ( self ) {
        _availableBundles = availableBundles;
        _selectionCallback = selectionCallback;
    }
    return self;
}

# pragma mark TableView Delegate Methods

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    _selectionCallback([_availableBundles objectAtIndex:indexPath.row]);
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [_availableBundles count];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return @"How many credits would you like?";
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *i = @"BundleOptionsTableCell";
    UILabel *label, *value;
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:i];
    NSDictionary *bundle = [_availableBundles objectAtIndex:indexPath.row];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:i];
        [cell setBackgroundColor:[UIColor clearColor]];
        
        label = [[UILabel alloc] initWithFrame:CGRectMake(-80.0, 0.0, cell.frame.size.width / 2, cell.frame.size.height)];
        [label setTag:CELL_LABEL_TAG];
        [label setTextColor:[UIColor whiteColor]];
        [label setAutoresizingMask:UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleHeight];
        [label setBackgroundColor:[UIColor clearColor]];
        [cell.contentView addSubview:label];
        
        value = [[UILabel alloc] initWithFrame:CGRectMake(cell.frame.size.width / 2, 0.0, cell.frame.size.width / 2, cell.frame.size.height)];
        [value setTag:CELL_VALUE_TAG];
        [value setTextAlignment:NSTextAlignmentRight];
        [value setTextColor:[UIColor grayColor]];
        [value setBackgroundColor:[UIColor clearColor]];
        [value setAutoresizingMask:UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleHeight];
        [cell.contentView addSubview:value];
    } else {
        label = (UILabel *)[cell.contentView viewWithTag:CELL_LABEL_TAG];
        value = (UILabel *)[cell.contentView viewWithTag:CELL_VALUE_TAG];
    }
    
    [label setText:[NSString stringWithFormat:@"%@ credits", [bundle objectForKey:@"value"]]];
    [value setText:[NSString stringWithFormat:@"$%@ USD", [bundle objectForKey:@"price"]]];
    
    CALayer *topBorder = [CALayer layer];
    topBorder.frame = CGRectMake(0.0, 0.0, cell.frame.size.width + 80.0, 0.5f);
    topBorder.backgroundColor = [[UIColor whiteColor] CGColor];
    topBorder.opacity = 0.2;
    [cell.contentView.layer addSublayer:topBorder];
    
    return cell;
}

@end
