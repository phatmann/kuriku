//
//  ListViewController.h
//  
//
//  Created by Tony Mann on 12/16/13.
//
//

#import <UIKit/UIKit.h>
#import <InnerBand/InnerBand.h>

@class Todo;

@interface ListViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, UIActionSheetDelegate, NSFetchedResultsControllerDelegate>

@property (strong, nonatomic) NSFetchedResultsController *fetchedResultsController;

- (void)showTodoActionSheet:(Todo *)todo;
- (void)showEditTodoView:(Todo *)todo;

@end
