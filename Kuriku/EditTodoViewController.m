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
@property (weak, nonatomic) IBOutlet UISlider *temperatureSlider;
@property (weak, nonatomic) IBOutlet UITextView *notesField;
@property (weak, nonatomic) IBOutlet UILabel *dueDateLabel;
@property (weak, nonatomic) IBOutlet UILabel *startDateLabel;

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
        self.navigationItem.title    = @"Edit Todo";
        self.titleField.text         = self.todo.title;
        self.temperatureSlider.value = self.todo.temperature;
        self.dueDateLabel.text       = dateToString(self.todo.dueDate);
        self.startDateLabel.text     = dateToString(self.todo.startDate);
        self.notesField.text         = self.todo.notes;
    } else {
        self.navigationItem.title    = @"New Todo";
        self.titleField.text         = nil;
        self.temperatureSlider.value = TodoTemperatureDefaultValue;
        self.dueDateLabel.text       = NoDateString;
        self.startDateLabel.text     = NoDateString;
        self.notesField.text         = nil;
        
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
    
    self.todo.dueDate     = stringToDate(self.dueDateLabel.text);
    self.todo.startDate   = stringToDate(self.startDateLabel.text);
    self.todo.title       = self.titleField.text;
    self.todo.temperature = self.temperatureSlider.value;
    self.todo.notes       = self.notesField.text;
    
    [[IBCoreDataStore mainStore] save];
    [self.delegate todoWasEdited:self.todo];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)sliderValueChanged:(UISlider *)slider {
    // TODO: set background color
}

#pragma mark - Date Picker View Controller Delegate

- (void)datePickerViewControllerDateChanged:(DatePickerViewController *)dateViewController {
    NSString *dateString = dateToString(dateViewController.date);
    
    if (![dateString isEqualToString:self.selectedDateLabel.text]) {
        self.selectedDateLabel.text = dateString;
        
        float_t temperature = self.temperatureSlider.value;
        NSDate *startDate   = stringToDate(self.startDateLabel.text);
        NSDate *dueDate     = stringToDate(self.dueDateLabel.text);
        [Todo updateTemperature:&temperature fromStartDate:startDate andDueDate:dueDate];
        self.temperatureSlider.value = temperature;
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

@end
