//
//  DatePickerViewController.m
//  Kuriku
//
//  Created by Tony Mann on 12/25/13.
//  Copyright (c) 2013 7Actions. All rights reserved.
//

#import "DatePickerViewController.h"
#import <InnerBand/InnerBand.h>

@interface DatePickerViewController ()
@property (weak, nonatomic) IBOutlet UIDatePicker *datePicker;
@property (weak, nonatomic) IBOutlet UILabel *dateLabel;
@property (weak, nonatomic) IBOutlet UISegmentedControl *dateButtons;
@end

@implementation DatePickerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    if (self.date) {
        self.datePicker.date = self.date;
    }
    
    [self datePickerValueWasChanged];
}

- (void)setDate:(NSDate *)date {
    _date = date;
    
    if ([self.delegate respondsToSelector:@selector(datePickerViewControllerDateChanged:)])
        [self.delegate datePickerViewControllerDateChanged:self];
}

- (IBAction)cancelButtonWasTapped {
    [self dismissViewControllerAnimated:YES completion:nil];
    
    if ([self.delegate respondsToSelector:@selector(datePickerViewControllerCanceled:)])
        [self.delegate datePickerViewControllerCanceled:self];
}

- (IBAction)doneButtonWasTapped {
    [self dismissViewControllerAnimated:YES completion:nil];
    
    if ([self.delegate respondsToSelector:@selector(datePickerViewControllerDismissed:)])
        [self.delegate datePickerViewControllerDismissed:self];
}

- (IBAction)datePickerValueWasChanged {
    self.date = [self.datePicker.date dateAtStartOfDay];
    BOOL isToday = [self.date isEqualToDate:[[NSDate date] dateAtStartOfDay]];
    self.dateButtons.selectedSegmentIndex = isToday ? 1 : -1;
    self.dateLabel.text = [self.date formattedDateStyle:NSDateFormatterLongStyle];
}

- (IBAction)dateButtonsChanged {
    switch (self.dateButtons.selectedSegmentIndex) {
        case 0:
            self.datePicker.hidden = YES;
            self.date = nil;
            self.dateLabel.text = @"None";
            break;
            
        case 1:
            self.datePicker.hidden = NO;
            self.datePicker.date = [NSDate date];
            [self datePickerValueWasChanged];
            break;
    }
}

@end
