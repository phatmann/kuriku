//
//  EditTodoViewController.m
//  Kuriku
//
//  Created by Tony Mann on 12/13/13.
//  Copyright (c) 2013 7Actions. All rights reserved.
//

#import "EditTodoViewController.h"
#import "Todo.h"
#import "Entry.h"
#import <InnerBand/InnerBand.h>

@interface EditTodoViewController ()

@property (weak, nonatomic) IBOutlet UITextView *titleField;
@property (weak, nonatomic) IBOutlet UISlider *urgencySlider;
@property (weak, nonatomic) IBOutlet UISlider *temperatureSlider;
@property (weak, nonatomic) IBOutlet UITextView *notesField;
@property (weak, nonatomic) IBOutlet UILabel *dueDateLabel;
@property (weak, nonatomic) IBOutlet UILabel *startDateLabel;
@property (weak, nonatomic) IBOutlet UILabel *urgencyLabel;

@property (weak, nonatomic) UILabel *selectedDateLabel;

@end

static NSString* NoDateString       = @"Never";

static NSString* NoDaysString       = @"Never";
static NSString* ImmediatelyString  = @"Immedately";
static NSString* DailyString        = @"Daily";
static NSString* WeeklyString       = @"Weekly";
static NSString* MonthlyString      = @"Monthly";
static NSString* YearlyString       = @"Yearly";

enum {
    NoDaysValue       = -1,
    ImmediatelyValue  = 0,
    DailyValue        = 1,
    WeeklyValue       = 7,
    MonthlyValue      = 30,
    YearlyValue       = 365
};

@implementation EditTodoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
	
    if (self.todo) {
        self.navigationItem.title = @"Edit Todo";
        
        self.titleField.text                        = self.todo.title;
        //self.urgencySlider.value                    = self.todo.urgency;
        self.temperatureSlider.value                     = self.todo.temperature;
        self.dueDateLabel.text                      = dateToString(self.todo.dueDate);
        self.startDateLabel.text                    = dateToString(self.todo.startDate);
        self.notesField.text                        = self.todo.notes;
    } else {
        self.navigationItem.title = @"New Todo";
        
        self.titleField.text                        = nil;
        self.urgencySlider.value                    = 0;
        self.temperatureSlider.value                     = TodoTemperatureDefaultValue;
        self.dueDateLabel.text                      = NoDateString;
        self.startDateLabel.text                    = NoDateString;
        self.notesField.text                        = nil;
        
        [self.titleField becomeFirstResponder];
    }
    
    [self updateControls];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    UITableViewCell *cell = sender;
    DatePickerViewController *datePickerViewController = segue.destinationViewController;
    self.selectedDateLabel = (UILabel *)[cell viewWithTag:1];
    datePickerViewController.date = stringToDate(self.selectedDateLabel.text);
    datePickerViewController.delegate = self;
}
    
- (IBAction)cancelButtonWasTapped:(UIBarButtonItem *)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}
    
- (IBAction)saveButtonWasTapped {
    if (!self.todo) {
        self.todo = [Todo create];
    }
    
    // TODO: make Todo model smarter so messing with due date does not mess up urgency
    
    NSDate *dueDate = stringToDate(self.dueDateLabel.text);
    
    if (!datesEqual(self.todo.dueDate, dueDate))
        self.todo.dueDate = dueDate;
    
    NSDate *startDate = stringToDate(self.startDateLabel.text);

    if (!datesEqual(self.todo.startDate, startDate)) {
        self.todo.startDate = startDate;
    }
    
    //if (!self.todo.dueDate)
        //self.todo.urgency = self.urgencySlider.value;
    
    self.todo.title      = self.titleField.text;
    self.todo.temperature     = self.temperatureSlider.value;
    self.todo.notes      = self.notesField.text;
    
    [[IBCoreDataStore mainStore] save];
    [self.delegate todoWasEdited:self.todo];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)sliderValueChanged:(UISlider *)slider {
}

#pragma mark - Date Picker View Controller Delegate

- (void)datePickerViewControllerDateChanged:(DatePickerViewController *)dateViewController {
    NSString *dateString = dateToString(dateViewController.date);
    
    if (![dateString isEqualToString:self.selectedDateLabel.text]) {
        self.selectedDateLabel.text = dateString;
        
        if (self.selectedDateLabel == self.dueDateLabel) {
            [self updateControls];
        }
    }
}

#pragma mark - Table View Delegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        return self.titleField.intrinsicContentSize.height + 16;
    } else if (indexPath.section == 4) {
        return self.notesField.intrinsicContentSize.height + 44;
    } else {
        return tableView.rowHeight;
    }
}

#pragma mark - Text View Delegate

- (void)textViewDidChange:(UITextView *)textView {
    [self.tableView beginUpdates];
    [self.tableView endUpdates];
    
    CGRect caretRect = [textView caretRectForPosition:textView.selectedTextRange.start];
    caretRect = [self.tableView convertRect:caretRect fromView:textView];
    caretRect.size.height += 8;
    [self.tableView scrollRectToVisible:caretRect animated:YES];
    
    [self updateControls];
}

#pragma mark - Private

- (void)updateControls {
    self.navigationItem.rightBarButtonItem.enabled = (self.titleField.text.length > 0);
}

#pragma mark - Conversion functions

NSDate *stringToDate(NSString *string) {
    if ([string isEqualToString:NoDateString])
        return nil;
    
    return [NSDate dateFromString:string withFormat:NSDateFormatterShortStyle];
}

NSString *dateToString(NSDate *date) {
    if (!date)
        return NoDateString;
    
    return [date formattedDateStyle:NSDateFormatterShortStyle];
}

int stringToDays(NSString *string) {
    if ([string isEqualToString:NoDaysString])
        return NoDaysValue;
    
    if ([string isEqualToString:ImmediatelyString])
        return ImmediatelyValue;
    
    if ([string isEqualToString:DailyString])
        return DailyValue;
    
    if ([string isEqualToString:WeeklyString])
        return WeeklyValue;
    
    if ([string isEqualToString:MonthlyString])
        return MonthlyValue;
    
    if ([string isEqualToString:YearlyString])
        return YearlyValue;
    
    NSArray *components = [string componentsSeparatedByString: @" "];
    return [components[1] intValue];
}

NSString *daysToString(int days) {
    switch (days) {
        case NoDaysValue:       return NoDaysString;
        case ImmediatelyValue:  return ImmediatelyString;
        case DailyValue:        return DailyString;
        case WeeklyValue:       return WeeklyString;
        case MonthlyValue:      return MonthlyString;
        case YearlyValue:       return YearlyString;
    }
    
    return [NSString stringWithFormat:@"Every %d days", days];
}

BOOL datesEqual(NSDate *date1, NSDate *date2) {
    if (!date1 && !date2)
        return true;
    
    if (!date1 || !date2)
        return false;
    
    return [date1 isEqualToDate:date2];
}

@end
