//
//  DatePickerViewController.h
//  Kuriku
//
//  Created by Tony Mann on 12/25/13.
//  Copyright (c) 2013 7Actions. All rights reserved.
//

#import <UIKit/UIKit.h>

@class DatePickerViewController;

@protocol DatePickerViewControllerDelegate <NSObject>

- (void)datePickerViewControllerDateChanged:(DatePickerViewController *)dateViewController;

@end

@interface DatePickerViewController : UITableViewController

@property (nonatomic, strong) NSDate *date;
@property (nonatomic, weak) id<DatePickerViewControllerDelegate> delegate;

@end
