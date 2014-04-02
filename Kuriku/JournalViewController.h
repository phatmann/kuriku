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

@interface JournalViewController : UIViewController  <UITableViewDelegate, UITableViewDataSource, UIActionSheetDelegate, NSFetchedResultsControllerDelegate, EditTodoViewControllerDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) NSFetchedResultsController *fetchedResultsController;

- (void)textViewDidChange:(UITextView *)textView;
- (void)reloadData;
- (void)showTodoActionSheet:(Todo *)todo;
- (void)showEditTodoView:(Todo *)todo;

@end
