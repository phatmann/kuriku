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
#import "EntryCell.h"
#import "TMGrowingTextView.h"

@interface ListViewController ()
@property (strong, nonatomic) Todo *selectedTodo;
@property (strong, nonatomic) NSIndexPath *pinchIndexPath;
@property (nonatomic) int pinchInitialImportance;
@end

@implementation ListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.tableView.estimatedRowHeight = 44;
    
    UIPinchGestureRecognizer *pinchRecognizer = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(tableViewWasPinched:)];
	[self.tableView addGestureRecognizer:pinchRecognizer];
    
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
    
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    static TMGrowingTextView *sizingTextView;
    
    if (!sizingTextView) {
        sizingTextView = [TMGrowingTextView new];
        sizingTextView.font = [UIFont systemFontOfSize:14];
    }
    
    sizingTextView.text = [[self todoAtIndexPath:indexPath ] title];
    CGFloat width = self.tableView.bounds.size.width - 60;
    return [sizingTextView sizeThatFits:CGSizeMake(width, 0)].height + 35;
}



- (void)tableViewWasPinched:(UIPinchGestureRecognizer *)pinchRecognizer {
    if (pinchRecognizer.state == UIGestureRecognizerStateBegan) {
        CGPoint pinchLocation = [pinchRecognizer locationInView:self.tableView];
        self.pinchIndexPath = [self.tableView indexPathForRowAtPoint:pinchLocation];
        Todo* todo =  [self todoAtIndexPath:self.pinchIndexPath];
        self.pinchInitialImportance = todo.importance;
        
        [self updateImportanceForPinchScale:pinchRecognizer.scale];
    }
    else {
        if (pinchRecognizer.state == UIGestureRecognizerStateChanged) {
            [self updateImportanceForPinchScale:pinchRecognizer.scale];
        }
        else if ((pinchRecognizer.state == UIGestureRecognizerStateCancelled) || (pinchRecognizer.state == UIGestureRecognizerStateEnded)) {
            self.pinchIndexPath = nil;
            [self updateRowHeights];
        }
    }
}

- (void)updateRowHeights {
    [self.tableView beginUpdates];
    [self.tableView endUpdates];
}

- (void)updateImportanceForPinchScale:(CGFloat)scale {
    
    if (self.pinchIndexPath && (self.pinchIndexPath.section != NSNotFound) && (self.pinchIndexPath.row != NSNotFound)) {
        Todo* todo =  [self todoAtIndexPath:self.pinchIndexPath];
		todo.importance = round(MAX(0, MIN(TodoRangeMaxValue, self.pinchInitialImportance * scale)));
        EntryCell *cell = (EntryCell *)[self.tableView cellForRowAtIndexPath:self.pinchIndexPath];
        [cell refresh];
    }
}

#pragma mark - Action Sheet Delegate

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    NSInteger markCompletedButtonIndex = actionSheet.firstOtherButtonIndex;
    NSInteger takeActionButtonIndex    = markCompletedButtonIndex + 1;
    NSInteger editButtonIndex          = takeActionButtonIndex + 1;
    
    Todo *todo = (Todo *)self.selectedTodo;
    
    if (buttonIndex == markCompletedButtonIndex) {
        todo.status = (todo.status == TodoStatusCompleted) ? TodoStatusNormal : TodoStatusCompleted;
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
    NSString *completionActionName = (todo.status == TodoStatusCompleted) ?  @"Unmark completed" : @"Mark completed";
    UIActionSheet *actionSheet = [[UIActionSheet alloc]
                                  initWithTitle:nil
                                       delegate:self
                              cancelButtonTitle:@"Cancel"
                         destructiveButtonTitle:nil
                              otherButtonTitles:completionActionName, @"Take action", @"Edit", nil];
    
    [actionSheet showInView:self.view];
}

- (void)showEditTodoView:(Todo *)todo {
    [self performSegueWithIdentifier:@"Edit todo" sender:todo];
}

@end
