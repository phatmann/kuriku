//
//  ListViewController.m
//  
//
//  Created by Tony Mann on 12/16/13.
//
//

#import "ListViewController.h"
#import "EditTodoViewController.h"
#import "Todo.h"
#import "Entry.h"

@interface ListViewController ()
@property (strong, nonatomic) Todo *selectedTodo;
@end

@implementation ListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.tableView.estimatedRowHeight = 44;
    [self reloadData];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"Edit todo"]) {
        Todo *todo = sender;
        UINavigationController *navigationController = segue.destinationViewController;
        EditTodoViewController *entryViewController = [navigationController.viewControllers firstObject];
        entryViewController.delegate = self;
        entryViewController.todo = todo;
    }
}
#pragma mark -

- (void)reloadData {
    [self createFetchedResultsController];
    self.fetchedResultsController.delegate = self;
    NSError *error;
    [self.fetchedResultsController performFetch:&error];
    [self.tableView reloadData];
}

#pragma mark - Table View Delegate

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    // Subclasses override
    return nil;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return [[self.fetchedResultsController sections] count];
}

- (NSInteger)tableView:(UITableView *)table numberOfRowsInSection:(NSInteger)section {
    if ([[self.fetchedResultsController sections] count] > 0) {
        id <NSFetchedResultsSectionInfo> sectionInfo = [self.fetchedResultsController sections][section];
        return [sectionInfo numberOfObjects];
    }
    
    return 0;
}

#pragma mark - Action Sheet Delegate

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    NSInteger markCompletedButtonIndex = actionSheet.firstOtherButtonIndex;
    NSInteger takeActionButtonIndex    = markCompletedButtonIndex + 1;
    NSInteger editButtonIndex          = takeActionButtonIndex + 1;
    
    Todo *todo = (Todo *)self.selectedTodo;
    
    if (buttonIndex == markCompletedButtonIndex) {
        todo.completed = !todo.completed;
        [[IBCoreDataStore mainStore] save];
    } else if (buttonIndex == takeActionButtonIndex) {
        [todo createEntry:EntryTypeTakeAction];
        [[IBCoreDataStore mainStore] save];
    } else if (buttonIndex == editButtonIndex) {
        [self showEditTodoView:todo];
    }
}

#pragma mark - Fetched Results Controller Delegate

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
    [self.tableView reloadData];
}

#pragma mark - Edit Todo Controller Delegate

- (void)todoWasEdited:(Todo *)todo {
    // Subclasses can override
}

#pragma mark - 

- (void)createFetchedResultsController
{
    // Subclasses override
}

- (Todo *)todoAtIndexPath:(NSIndexPath *)indexPath {
    // Subclasses override
    return nil;
}

#pragma mark - Private

- (IBAction)cellWasLongPressed:(UILongPressGestureRecognizer *)gestureRecognizer {
    if (gestureRecognizer.state == UIGestureRecognizerStateBegan) {
        CGPoint point = [gestureRecognizer locationInView:self.tableView];
        NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:point];
        
        if (indexPath != nil) {
            UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
            
            if (cell.isHighlighted) {
                [self showEditTodoView:[self todoAtIndexPath:indexPath]];
            }
        }
    }
}

- (void)showTodoActionSheet:(Todo *)todo {
    self.selectedTodo = todo;
    NSString *completionActionName = todo.completed ?  @"Unmark completed" : @"Mark completed";
    UIActionSheet *actionSheet = [[UIActionSheet alloc]
                                  initWithTitle:nil
                                       delegate:self
                              cancelButtonTitle:@"Cancel"
                         destructiveButtonTitle:nil
                              otherButtonTitles:completionActionName, @"Take action", @"Edit", nil];
    
    [actionSheet showFromTabBar:self.tabBarController.tabBar];
}

- (void)showEditTodoView:(Todo *)todo {
    [self performSegueWithIdentifier:@"Edit todo" sender:todo];
}

@end
