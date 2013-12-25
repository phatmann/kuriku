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
@property (weak, nonatomic) IBOutlet UISwitch *committedSwitch;
@property (weak, nonatomic) IBOutlet UILabel *dueDateLabel;
@property (weak, nonatomic) IBOutlet UILabel *startDateLabel;

@property (weak, nonatomic) UILabel *selectedDateLabel;

@end

@implementation EditTodoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
	
    if (self.todo) {
        self.titleField.text         = self.todo.title;
        self.urgencySlider.value     = self.todo.urgency;
        self.importanceSlider.value  = self.todo.importance;
        self.committedSwitch.on      = self.todo.committed;
        self.notesField.text         = self.todo.notes;
        self.dueDateLabel.text       = [self.todo.dueDate formattedDateStyle:NSDateFormatterShortStyle];
        self.startDateLabel.text     = [self.todo.startDate formattedDateStyle:NSDateFormatterShortStyle];
        self.navigationItem.title    = @"Edit Todo";
    } else {
        self.urgencySlider.value     = TodoUrgencyDefaultValue;
        self.importanceSlider.value  = TodoImportanceDefaultValue;
        self.committedSwitch.on      = TodoCommittedDefaultValue;
        self.navigationItem.title    = @"New Todo";
        self.dueDateLabel.text       = @"None";
        self.startDateLabel.text     = @"None";
        [self.titleField becomeFirstResponder];
    }
    
    [self titleDidChange];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    DatePickerViewController *datePickerViewController = segue.destinationViewController;
    UITableViewCell *cell = sender;
    
    self.selectedDateLabel = (UILabel *)[cell viewWithTag:1];
    NSString *dateString   = self.selectedDateLabel.text;
    
    datePickerViewController.date     = [NSDate dateFromString:dateString withFormat:NSDateFormatterShortStyle];
    datePickerViewController.delegate = self;
}

- (IBAction)titleDidChange {
    self.navigationItem.rightBarButtonItem.enabled = (self.titleField.text.length > 0);
}
    
- (IBAction)cancelButtonWasTapped:(UIBarButtonItem *)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}
    
- (IBAction)saveButtonWasTapped {
    if (!self.todo) {
        self.todo = [Todo create];
    }
    
    self.todo.title      = self.titleField.text;
    self.todo.urgency    = self.urgencySlider.value;
    self.todo.importance = self.importanceSlider.value;
    self.todo.committed  = self.committedSwitch.on;
    self.todo.notes      = self.notesField.text;
    self.todo.dueDate    = [NSDate dateFromString:self.dueDateLabel.text withFormat:NSDateFormatterShortStyle];
    self.todo.startDate  = [NSDate dateFromString:self.startDateLabel.text withFormat:NSDateFormatterShortStyle];
    
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
    self.selectedDateLabel.text = [dateViewController.date formattedDateStyle:NSDateFormatterShortStyle];
}


@end
