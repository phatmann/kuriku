//
//  RepeatViewController.m
//  Kuriku
//
//  Created by Tony Mann on 12/29/13.
//  Copyright (c) 2013 7Actions. All rights reserved.
//

#import "RepeatViewController.h"

@interface RepeatViewController ()

@property (weak, nonatomic) IBOutlet UITextField *daysField;
@property (strong, nonatomic) IBOutletCollection(UITableViewCell) NSArray *standardCells;
@property (weak, nonatomic) IBOutlet UITableViewCell *customCell;

@end

@implementation RepeatViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    UITableViewCell *cell = [self cellForDays];
    cell.accessoryType = UITableViewCellAccessoryCheckmark;
    
    if (cell.tag == self.customCell.tag)
        self.daysField.text = [@(self.days) stringValue];
}

- (void)setDays:(int)days {
    _days = days;
    [self.delegate repeatViewControllerDaysChanged:self];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    [self checkCell:cell];
    
    self.days = cell.tag;
}

- (IBAction)daysFieldWasChanged {
    [self checkCell:self.customCell];
    self.days = [self.daysField.text intValue];
}

- (UITableViewCell *)cellForDays {
    for (UITableViewCell *cell in self.standardCells) {
        if (cell.tag == self.days)
            return cell;
    }
    
    return self.customCell;
}

- (void)checkCell:(UITableViewCell *)cell {
    UITableViewCell *oldCell = [self cellForDays];
    oldCell.accessoryType = UITableViewCellAccessoryNone;
    cell.accessoryType = UITableViewCellAccessoryCheckmark;
}

@end
