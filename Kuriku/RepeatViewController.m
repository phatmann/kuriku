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
}

- (void)setDays:(NSInteger)days {
    _days = days;
    [self.delegate repeatViewControllerDaysChanged:self];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    self.days = cell.tag;
}

- (IBAction)daysFieldWasChanged {
    self.days = [self.daysField.text intValue];
}

- (UITableViewCell *)cellForDays {
    for (UITableViewCell *cell in self.standardCells) {
        if (cell.tag == self.days)
            return cell;
    }
    
    return self.customCell;
}

@end
