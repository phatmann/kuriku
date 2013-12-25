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
@end

@implementation DatePickerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    if (self.date) {
        self.datePicker.date = self.date;
    }
    
    [self datePickerValueWasChanged];
}

- (IBAction)datePickerValueWasChanged {
    self.date = [self.datePicker.date dateAtStartOfDay];
    self.dateLabel.text = [self.date formattedDateStyle:NSDateFormatterLongStyle];
    [self.delegate datePickerViewControllerDateChanged:self];
}

@end
