//
//  ListViewController.h
//  
//
//  Created by Tony Mann on 12/16/13.
//
//

#import <UIKit/UIKit.h>
#import <InnerBand/InnerBand.h>
#import "EditTodoViewController.h"

@class Todo;

@interface ListViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, UIActionSheetDelegate, NSFetchedResultsControllerDelegate, EditTodoViewControllerDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) NSFetchedResultsController *fetchedResultsController;

- (void)reloadData;
- (void)showTodoActionSheet:(Todo *)todo;
- (void)showEditTodoView:(Todo *)todo;

@end
