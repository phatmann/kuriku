//
//  JournalViewController.h
//  Kuriku
//
//  Created by Tony Mann on 12/11/13.
//  Copyright (c) 2013 7Actions. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <InnerBand/InnerBand.h>
#import "RepeatViewController.h"
#import "EditTodoViewController.h"

@class EntryCell;

@interface JournalViewController : UIViewController  <UITableViewDelegate,
                                                      UITableViewDataSource,
                                                      UIActionSheetDelegate,
                                                      NSFetchedResultsControllerDelegate,
                                                      RepeatViewControllerDelegate,
                                                      UIGestureRecognizerDelegate,
                                                      EditTodoViewControllerDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) NSFetchedResultsController *fetchedResultsController;

- (void)cell:(EntryCell *)cell textViewDidBeginEditing:(UITextView *)textView;
- (void)cell:(EntryCell *)cell textViewDidEndEditing:(UITextView *)textView;
- (void)cell:(EntryCell *)cell textViewDidChange:(UITextView *)textView;

@end
