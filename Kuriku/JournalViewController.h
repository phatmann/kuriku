//
//  JournalViewController.h
//  Kuriku
//
//  Created by Tony Mann on 12/11/13.
//  Copyright (c) 2013 7Actions. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <InnerBand/InnerBand.h>
#import "EditTodoViewController.h"
#import "RepeatViewController.h"
#import "DatePickerViewController.h"

@class EntryCell;

@interface JournalViewController : UIViewController  <UITableViewDelegate,
                                                      UITableViewDataSource,
                                                      UIActionSheetDelegate,
                                                      NSFetchedResultsControllerDelegate,
                                                      EditTodoViewControllerDelegate,
                                                      RepeatViewControllerDelegate,
                                                      DatePickerViewControllerDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) NSFetchedResultsController *fetchedResultsController;

- (void)statusWasTappedForCell:(EntryCell *)cell;
- (void)cell:(EntryCell *)cell textViewDidBeginEditing:(UITextView *)textView;
- (void)cell:(EntryCell *)cell textViewDidEndEditing:(UITextView *)textView;
- (void)cell:(EntryCell *)cell textViewDidChange:(UITextView *)textView;

@end
