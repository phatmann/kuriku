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

@property (weak, nonatomic) IBOutlet UITextField *titleField;
@property (weak, nonatomic) IBOutlet UISlider *urgencySlider;
@property (weak, nonatomic) IBOutlet UISlider *importanceSlider;
@property (weak, nonatomic) IBOutlet UITextView *notesField;
@property (weak, nonatomic) IBOutlet UISlider *commitmentSlider;
@property (weak, nonatomic) IBOutlet UILabel *dueDateLabel;
@property (weak, nonatomic) IBOutlet UILabel *holdDateLabel;
@property (weak, nonatomic) IBOutlet UILabel *urgencyLabel;
@property (weak, nonatomic) IBOutlet UILabel *repeatLabel;

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
        self.titleField.text         = self.todo.title;
        self.urgencySlider.value     = self.todo.urgency;
        self.importanceSlider.value  = self.todo.importance;
        self.commitmentSlider.value  = commitmentToSliderValue(self.todo.commitment);
        self.notesField.text         = self.todo.notes;
        self.dueDateLabel.text       = dateToString(self.todo.dueDate);
        self.holdDateLabel.text      = dateToString(self.todo.holdDate);
        self.repeatLabel.text        = daysToString(self.todo.repeatDays);
        
        self.navigationItem.title    = @"Edit Todo";
    } else {
        self.urgencySlider.value     = TodoUrgencyDefaultValue;
        self.importanceSlider.value  = TodoImportanceDefaultValue;
        self.commitmentSlider.value  = commitmentToSliderValue(TodoCommitmentDefaultValue);
        self.navigationItem.title    = @"New Todo";
        self.dueDateLabel.text       = NoDateString;
        self.holdDateLabel.text      = NoDateString;
        self.repeatLabel.text        = NoDaysString;
        
        [self.titleField becomeFirstResponder];
    }
    
    [self updateControls];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    UITableViewCell *cell = sender;
    
    if ([segue.identifier isEqualToString:@"Choose date"]) {
        DatePickerViewController *datePickerViewController = segue.destinationViewController;
        self.selectedDateLabel = (UILabel *)[cell viewWithTag:1];
        datePickerViewController.date = stringToDate(self.selectedDateLabel.text);
        datePickerViewController.delegate = self;
    } else if ([segue.identifier isEqualToString:@"Choose repeat"]) {
        RepeatViewController *repeatViewController = segue.destinationViewController;
        repeatViewController.days = stringToDays(self.repeatLabel.text);
        repeatViewController.delegate = self;
    }
}

- (IBAction)titleDidChange {
    [self updateControls];
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
    
    NSDate *holdDate = stringToDate(self.holdDateLabel.text);
    
    if (!datesEqual(self.todo.holdDate, holdDate)) {
        self.todo.holdDate = holdDate;
    }
    
    if (!self.todo.dueDate)
        self.todo.urgency = self.urgencySlider.value;
    
    self.todo.title      = self.titleField.text;
    self.todo.importance = self.importanceSlider.value;
    self.todo.commitment = sliderValueToCommitment(self.commitmentSlider.value);
    self.todo.notes      = self.notesField.text;
    self.todo.repeatDays = stringToDays(self.repeatLabel.text);
    
    [[IBCoreDataStore mainStore] save];
    [self.delegate todoWasEdited:self.todo];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)sliderValueChanged:(UISlider *)slider {
    [slider setValue:roundf(slider.value) animated:YES];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    [self saveButtonWasTapped];
    return NO;
}

#pragma mark - Date Picker View Controller Delegate

- (void)datePickerViewControllerDateChanged:(DatePickerViewController *)dateViewController {
    NSString *dateString = dateToString(dateViewController.date);
    
    if (![dateString isEqualToString:self.selectedDateLabel.text]) {
        self.selectedDateLabel.text = dateString;
        
        if (self.selectedDateLabel == self.dueDateLabel) {
            self.urgencySlider.value = [Todo urgencyFromDueDate:dateViewController.date];
            [self updateControls];
        }
    }
}

#pragma mark - Repeat View Controller Delegate

- (void)repeatViewControllerDaysChanged:(RepeatViewController *)repeatViewController {
    self.repeatLabel.text = daysToString(repeatViewController.days);
}

#pragma mark -

- (void)updateControls {
    self.urgencySlider.enabled = [self.dueDateLabel.text isEqualToString:NoDateString];
    self.urgencyLabel.enabled  = self.urgencySlider.enabled;
    self.navigationItem.rightBarButtonItem.enabled = (self.titleField.text.length > 0);
}

#pragma mark -

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
    
    return [string intValue];
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

int commitmentToSliderValue(TodoCommitment commitment) {
    switch (commitment) {
        case TodoCommitmentMaybe:
            return 0;
        case TodoCommitmentMust:
            return 1;
        case TodoCommitmentToday:
            return 2;
    }
}

TodoCommitment sliderValueToCommitment(int value) {
    switch (value) {
        case 0:
            return TodoCommitmentMaybe;
        case 2:
            return TodoCommitmentToday;
        default:
            return TodoCommitmentMust;
    }
}

@end
