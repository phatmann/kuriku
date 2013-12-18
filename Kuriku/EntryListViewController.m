//
//  EntryListViewController.m
//  
//
//  Created by Tony Mann on 12/16/13.
//
//

#import "EntryListViewController.h"
#import "TodoCell.h"
#import "ActionCell.h"
#import "EditTodoViewController.h"
#import "Entry.h"
#import "Todo.h"
#import "Action.h"

@interface EntryListViewController ()
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) Entry *selectedEntry;
@end

@implementation EntryListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.tableView registerNib:[UINib nibWithNibName:@"TodoCell" bundle:nil] forCellReuseIdentifier:@"TodoCell"];
    [self.tableView registerNib:[UINib nibWithNibName:@"ActionCell" bundle:nil] forCellReuseIdentifier:@"ActionCell"];
    [self performFetch];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    TodoCell *cell = sender;
    EditTodoViewController *entryViewController = segue.destinationViewController;
    entryViewController.todo = cell.todo;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - Table View Delegate

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

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    Entry *entry = [self entryAtIndexPath:indexPath];
    
    if ([entry isKindOfClass:[Todo class]]) {
        TodoCell *cell = [tableView dequeueReusableCellWithIdentifier:@"TodoCell" forIndexPath:indexPath];
        cell.todo = (Todo *)entry;
        return cell;
    }
    
    ActionCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ActionCell" forIndexPath:indexPath];
    cell.action = (Action *)entry;
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    self.selectedEntry = [self entryAtIndexPath:indexPath];
    
    if ([self.selectedEntry  isKindOfClass:[Todo class]]) {
        Todo *todo = (Todo *)self.selectedEntry;
        
        NSString *completionActionName = todo.status == TodoStatusNormal ? @"Mark completed" : @"Unmark completed";
        
        UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:completionActionName, @"Take action", nil];
        [actionSheet showInView:self.view];
    }
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        Entry *entry = [self entryAtIndexPath:indexPath];
        [entry destroy];
        [[IBCoreDataStore mainStore] save];
    }
}

- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    
    if ([cell isKindOfClass:[TodoCell class]])
        [self performSegueWithIdentifier:@"edit entry" sender:cell];
}

#pragma mark - Action Sheet Delegate

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    int markCompletedButtonIndex = actionSheet.firstOtherButtonIndex;
    int takeActionButtonIndex    = markCompletedButtonIndex + 1;
    
    Todo *todo = (Todo *)self.selectedEntry;
    
    if (buttonIndex == markCompletedButtonIndex) {
        if (todo.status == TodoStatusNormal)
            todo.status = TodoStatusCompleted;
        else
            todo.status = TodoStatusNormal;
    } else if (buttonIndex == takeActionButtonIndex) {
        Action *action = [Action create];
        action.title = todo.title;
        action.todo  = todo;
    }
    
    [[IBCoreDataStore mainStore] save];
}

#pragma mark - Fetched Results Controller Delegate

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
    [self.tableView reloadData];
}

#pragma mark - 

- (void)performFetch
{
    // Subclasses override
}

#pragma mark -

- (Entry *)entryAtIndexPath:(NSIndexPath *)indexPath {
    return (Entry *)[self.fetchedResultsController objectAtIndexPath:indexPath];
}

@end
