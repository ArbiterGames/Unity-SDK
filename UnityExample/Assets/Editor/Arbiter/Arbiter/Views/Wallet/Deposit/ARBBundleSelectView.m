//
//  ARBBundleSelectView.m
//  Unity-iPhone
//
//  Created by Andy Zinsser on 9/4/14.
//
//

#import "ARBTracking.h"
#import "ARBBundleSelectView.h"

#define CELL_LABEL_TAG 10
#define CELL_VALUE_TAG 11

@implementation ARBBundleSelectView

- (id)initWithBundles:(NSMutableArray *)availableBundles andSelectionCallback:(void(^)(NSDictionary *))selectionCallback
{
    self = [super init];
    if ( self ) {
        self.availableBundles = availableBundles;
        self.selectionCallback = selectionCallback;
    }
    return self;
}

# pragma mark TableView Delegate Methods

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary *bundle = [self.availableBundles objectAtIndex:indexPath.row];
    [[ARBTracking arbiterInstance] track:@"Selected Credit Amount" properties:@{@"amount": [bundle objectForKey:@"value"]}];
    self.selectionCallback(bundle);
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.availableBundles count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 40.0;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UILabel *label = [[UILabel alloc] init];
    label.frame = CGRectMake(0.0, 10.0, tableView.frame.size.width, 20.0);
    label.font = [UIFont boldSystemFontOfSize:17.0];
    label.textColor = [UIColor whiteColor];
    label.text = @"How many credits?";
    UIView *headerView = [[UIView alloc] init];
    [headerView addSubview:label];
    return headerView;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *i = @"BundleOptionsTableCell";
    UILabel *label, *value;
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:i];
    NSDictionary *bundle = [self.availableBundles objectAtIndex:indexPath.row];
    CALayer *topBorder = [CALayer layer];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:i];
        cell.backgroundColor = [UIColor clearColor];
        
        label = [[UILabel alloc] initWithFrame:CGRectMake(0.0, 0.0, cell.frame.size.width / 2, cell.frame.size.height)];
        label.tag = CELL_LABEL_TAG;
        label.textColor = [UIColor whiteColor];
        [cell.contentView addSubview:label];
        
        value = [[UILabel alloc] initWithFrame:CGRectMake(cell.frame.size.width / 2 - 20.0, 0.0, cell.frame.size.width / 2, cell.frame.size.height)];
        value.tag = CELL_VALUE_TAG;
        value.textAlignment = NSTextAlignmentRight;
        value.textColor = [UIColor whiteColor];
        [cell.contentView addSubview:value];

        topBorder.frame = CGRectMake(0.0, 0.0, cell.frame.size.width, 0.5f);
        topBorder.backgroundColor = [[UIColor whiteColor] CGColor];
        topBorder.opacity = 0.2;
        [cell.contentView.layer addSublayer:topBorder];
        
    } else {
        label = (UILabel *)[cell.contentView viewWithTag:CELL_LABEL_TAG];
        value = (UILabel *)[cell.contentView viewWithTag:CELL_VALUE_TAG];
    }
    
    [label setText:[NSString stringWithFormat:@"%@ credits", [self addThousandsSeparatorToString:[bundle objectForKey:@"value"]]]];
    [value setText:[NSString stringWithFormat:@"$%@ USD", [bundle objectForKey:@"price"]]];
    
    return cell;
}


# pragma mark helpers

- (NSString *)addThousandsSeparatorToString:(NSString *)original
{
    NSNumberFormatter *separatorFormattor = [[NSNumberFormatter alloc] init];
    [separatorFormattor setFormatterBehavior: NSNumberFormatterBehavior10_4];
    [separatorFormattor setNumberStyle: NSNumberFormatterDecimalStyle];
    
    NSNumberFormatter *stringToNumberFormatter = [[NSNumberFormatter alloc] init];
    [stringToNumberFormatter setNumberStyle:NSNumberFormatterDecimalStyle];
    NSNumber *origNumber = [stringToNumberFormatter numberFromString:original];
    
    return [separatorFormattor stringFromNumber:origNumber];
}

@end
