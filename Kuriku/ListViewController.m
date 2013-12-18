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
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) Todo *selectedTodo;
@end

@implementation ListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self createFetchedResultsController];
    self.fetchedResultsController.delegate = self;
    NSError *error;
    [self.fetchedResultsController performFetch:&error];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    Todo *todo = sender;
    EditTodoViewController *entryViewController = segue.destinationViewController;
    entryViewController.todo = todo;
}

#pragma mark -

- (void)showTodoActionSheet:(Todo *)todo {
    self.selectedTodo = todo;
    NSString *completionActionName = todo.status == TodoStatusNormal ? @"Mark completed" : @"Unmark completed";
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:completionActionName, @"Take action", nil];
    [actionSheet showInView:self.view];
}

- (void)showEditTodoView:(Todo *)todo {
    [self performSegueWithIdentifier:@"Edit todo" sender:todo];
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
    int markCompletedButtonIndex = actionSheet.firstOtherButtonIndex;
    int takeActionButtonIndex    = markCompletedButtonIndex + 1;
    
    Todo *todo = (Todo *)self.selectedTodo;
    
    if (buttonIndex == markCompletedButtonIndex) {
        if (todo.status == TodoStatusNormal)
            todo.status = TodoStatusCompleted;
        else
            todo.status = TodoStatusNormal;
        
        Entry *entry = [Entry create];
        entry.todo = todo;
        entry.type = EntryTypeCompleteTodo;
        
    } else if (buttonIndex == takeActionButtonIndex) {
        Entry *entry = [Entry create];
        entry.todo = todo;
        entry.type = EntryTypeTakeAction;
    }
    
    [[IBCoreDataStore mainStore] save];
}

#pragma mark - Fetched Results Controller Delegate

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
    [self.tableView reloadData];
}

#pragma mark - 

- (void)createFetchedResultsController
{
    // Subclasses override
}

@end
