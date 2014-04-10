//
//  JournalViewController.m
//  Kuriku
//
//  Created by Tony Mann on 12/11/13.
//  Copyright (c) 2013 7Actions. All rights reserved.
//

#import "JournalViewController.h"
#import "Entry.h"
#import "Todo.h"
#import "EntryCell.h"
#import "EditTodoViewController.h"
#import "TMGrowingTextView.h"

typedef enum {
    FilterAll,
    FilterActive,
    FilterInactive
} Filter;

@interface JournalViewController ()

@property (strong, nonatomic) Entry *selectedEntry;
@property (strong, nonatomic) NSIndexPath *pinchIndexPath;
@property (nonatomic) int pinchInitialImportance;
@property (nonatomic) Filter filter;
@property (nonatomic) BOOL isAdding;
@property (nonatomic) EntryCell *activeCell;
@property (weak, nonatomic) IBOutlet UINavigationItem *navigationBarItem;
@property (strong, nonatomic) UIBarButtonItem *addButton;
@property (strong, nonatomic) UIBarButtonItem *doneButton;
@property (strong, nonatomic) UIActionSheet *todoActionSheet;
@property (strong, nonatomic) UIActionSheet *deleteActionSheet;

@end

@implementation JournalViewController

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

#pragma mark - Private

- (Entry *)entryAtIndexPath:(NSIndexPath *)indexPath {
    return (Entry *)[self.fetchedResultsController objectAtIndexPath:indexPath];
}

- (Todo *)todoAtIndexPath:(NSIndexPath *)indexPath {
    return [[self entryAtIndexPath:indexPath] todo];
}

- (void)reloadData {
    [self createFetchedResultsController];
    self.fetchedResultsController.delegate = self;
    NSError *error;
    [self.fetchedResultsController performFetch:&error];
    [self.tableView reloadData];
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

- (void)showTodoActionSheet:(Entry *)entry {
    self.selectedEntry = entry;
    NSString *completionActionName = (entry.todo.status == TodoStatusCompleted) ?  @"Unmark completed" : @"Mark completed";
    
    self.todoActionSheet = [[UIActionSheet alloc]
                              initWithTitle:nil
                              delegate:self
                              cancelButtonTitle:@"Cancel"
                              destructiveButtonTitle:nil
                              otherButtonTitles:completionActionName, @"Take action", @"Edit", nil];
    
    [self.todoActionSheet showInView:self.view];
}

- (void)showDeleteActionSheet:(Entry *)entry {
    self.selectedEntry = entry;
    
    self.deleteActionSheet = [[UIActionSheet alloc]
                                initWithTitle:nil
                                delegate:self
                                cancelButtonTitle:@"Cancel"
                                destructiveButtonTitle:@"Delete Todo"
                                otherButtonTitles:@"Delete This Entry", nil];
    
    [self.deleteActionSheet showInView:self.view];
}

- (void)showEditTodoView:(Todo *)todo {
    [self performSegueWithIdentifier:@"Edit todo" sender:todo];
}

- (void)createFetchedResultsController {
    NSString *filter;
    
    switch (self.filter) {
        case FilterAll:
            filter = nil;
            break;
        case FilterActive:
            filter = @"state = 0";
            break;
        case FilterInactive:
            filter = @"state != 0";
            break;
    }

    NSManagedObjectContext *context = [[IBCoreDataStore mainStore] context];
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"Entry"];
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"timestamp" ascending:NO];
    NSPredicate *predicate = filter ? [NSPredicate predicateWithFormat:filter] : nil;
    [fetchRequest setSortDescriptors:@[sortDescriptor]];
    [fetchRequest setPredicate:predicate];
    self.fetchedResultsController = [[NSFetchedResultsController alloc]
                                     initWithFetchRequest:fetchRequest
                                     managedObjectContext:context
                                     sectionNameKeyPath:@"journalDateString"
                                     cacheName:nil];
}

- (IBAction)filterChooserValueChanged:(UISegmentedControl *)filterChooser {
    self.filter = filterChooser.selectedSegmentIndex;
    [self reloadData];
}

- (IBAction)addButtonTapped {
    [Todo create];
    self.isAdding = YES;
}

- (void)doneButtonTapped {
    self.activeCell.isEditing = NO;
    self.isAdding = NO;
    self.navigationBarItem.rightBarButtonItem = self.addButton;
    
    Todo *todo = self.activeCell.entry.todo;
    
    if (todo.title.length > 0)
        [IBCoreDataStore save];
    else
        [todo destroy];
}

#pragma mark - Action Sheet Delegate

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (actionSheet == self.todoActionSheet) {
        [self todoActionSheetButtonClicked:buttonIndex];
    } else if (actionSheet == self.deleteActionSheet) {
        [self deleteActionSheetButtonClicked:buttonIndex];
    }
}

- (void)todoActionSheetButtonClicked:(NSInteger)buttonIndex {
    NSInteger markCompletedButtonIndex = self.todoActionSheet.firstOtherButtonIndex;
    NSInteger takeActionButtonIndex    = markCompletedButtonIndex + 1;
    NSInteger editButtonIndex          = takeActionButtonIndex + 1;
    
    Todo *todo = self.selectedEntry.todo;
    
    if (buttonIndex == markCompletedButtonIndex) {
        todo.status = (todo.status == TodoStatusCompleted) ? TodoStatusNormal : TodoStatusCompleted;
        [[IBCoreDataStore mainStore] save];
    } else if (buttonIndex == takeActionButtonIndex) {
        [todo createEntry:EntryTypeAction];
        [[IBCoreDataStore mainStore] save];
    } else if (buttonIndex == editButtonIndex) {
        [self showEditTodoView:todo];
    }
}

- (void)deleteActionSheetButtonClicked:(NSInteger)buttonIndex {
    if (buttonIndex == self.deleteActionSheet.destructiveButtonIndex) {
        [self.selectedEntry.todo destroy];
    } else {
        [self.selectedEntry.todo removeEntriesObject:self.selectedEntry];
        [self.selectedEntry destroy];
    }
    
    [IBCoreDataStore save];
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

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    EntryCell *cell = [tableView dequeueReusableCellWithIdentifier:@"EntryCell" forIndexPath:indexPath];
    cell.entry = [self entryAtIndexPath:indexPath];
    cell.journalViewController = self;
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    [self showTodoActionSheet:[self entryAtIndexPath:indexPath]];
}

- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath {
    if (!tableView.isEditing) {
        Entry *entry = [self entryAtIndexPath:indexPath];
        [self showEditTodoView:entry.todo];
    }
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if ([[self.fetchedResultsController sections] count] > 0) {
        static NSDateFormatter *longDateFormatter;
        
        if (!longDateFormatter) {
            longDateFormatter = [NSDateFormatter new];
            [longDateFormatter setDateFormat:@"E MMM d"];
        }
        
        id <NSFetchedResultsSectionInfo> sectionInfo = [self.fetchedResultsController sections][section];
        NSDate *date = [Entry journalDateFromString:sectionInfo.name];
        return [longDateFormatter stringFromDate:date];
    }
    
    return nil;
}

#ifdef SHOW_INDEX
- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView {
    return [self.fetchedResultsController sectionIndexTitles];
}
    
- (NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index {
    return [self.fetchedResultsController sectionForSectionIndexTitle:title atIndex:index];
}
#endif

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
    return UITableViewCellEditingStyleDelete;
    //Entry *entry = [self entryAtIndexPath:indexPath];
    //return entry.type == EntryTypeCreateTodo ? UITableViewCellEditingStyleDelete : UITableViewCellEditingStyleNone;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        Entry *entry = [self entryAtIndexPath:indexPath];
        
        if (entry.todo.entries.count > 1) {
            [self showDeleteActionSheet:[self entryAtIndexPath:indexPath]];
        } else {
            [entry.todo destroy];
        }
    }
}

#pragma mark - Fetched Results Controller Delegate

#ifdef SHOW_INDEX
- (NSString *)controller:(NSFetchedResultsController *)controller sectionIndexTitleForSectionName:(NSString *)sectionName {
    static NSDateFormatter *tinyDateFormatter;
    
    if (!tinyDateFormatter) {
        tinyDateFormatter = [NSDateFormatter new];
        [tinyDateFormatter setDateFormat:@"MMM d"];
    }
    
    NSDate *date = [Entry journalDateFromString:sectionName];
    return [tinyDateFormatter stringFromDate:date];
}
#endif

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
    [self.tableView reloadData];
    
    if (self.isAdding) {
        self.activeCell = (EntryCell *)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
        self.activeCell.isEditing = YES;
        
        if (!self.doneButton) {
            self.doneButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(doneButtonTapped)];
            self.addButton = self.navigationBarItem.rightBarButtonItem;
        }
        
        self.navigationBarItem.rightBarButtonItem = self.doneButton;
    }
}


#pragma mark - Edit Todo Controller Delegate

- (void)todoWasEdited:(Todo *)todo {
    [self.tableView reloadData];
}
    
#pragma Text View Delegate
    
- (void)textViewDidChange:(UITextView *)textView {
    // TODO: share common code with EditTodoViewController
    [self.tableView beginUpdates];
    [self.tableView endUpdates];
    
    CGRect caretRect = [textView caretRectForPosition:textView.selectedTextRange.start];
    caretRect = [self.tableView convertRect:caretRect fromView:textView];
    caretRect.size.height += 8;
    [self.tableView scrollRectToVisible:caretRect animated:YES];
}

#pragma mark -



@end
