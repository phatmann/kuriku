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
#import <InnerBand.h>
#import "TMGrowingTextView.h"

static const float_t PriorityFilterShowAll __unused     = 0.0;
static const float_t PriorityFilterShowActive           = 0.1;
static const float_t PriorityFilterShowHigh __unused    = 1.0;

@interface JournalViewController ()

@property (strong, nonatomic) Entry *selectedEntry;
@property (strong, nonatomic) NSIndexPath *pinchIndexPath;
@property (nonatomic) CGFloat pinchInitialImportance;
@property (nonatomic) float_t priorityFilter;
@property (nonatomic) EntryCell *activeCell;
@property (weak, nonatomic) IBOutlet UINavigationItem *navigationBarItem;
@property (strong, nonatomic) UIBarButtonItem *addButton;
@property (strong, nonatomic) UIBarButtonItem *doneButton;
@property (strong, nonatomic) UIActionSheet *todoActionSheet;
@property (strong, nonatomic) UIActionSheet *deleteActionSheet;
@property (weak, nonatomic) IBOutlet UISlider *filterSlider;

@end

@implementation JournalViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];

    self.tableView.estimatedRowHeight = 44;
    
    UIPinchGestureRecognizer *pinchRecognizer = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(tableViewWasPinched:)];
	[self.tableView addGestureRecognizer:pinchRecognizer];
    
    float_t savedPriorityFilter = [[NSUserDefaults standardUserDefaults] floatForKey:@"priorityFilter"];
    
    if (savedPriorityFilter > 0)
        self.priorityFilter = savedPriorityFilter;
    else
        [self reloadData];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"Repeat todo"]) {
        UINavigationController *navigationController = segue.destinationViewController;
        RepeatViewController *repeatViewController = [navigationController.viewControllers firstObject];
        repeatViewController.delegate = self;
    }
 }

- (IBAction)longPressGestureRecognizerWasChanged:(UILongPressGestureRecognizer *)recognizer {
    static CGPoint startPoint;
    static CGFloat initialUrgency;
    static CGFloat initialFrostiness;
    static EntryCell *draggedCell;
    
    CGPoint pt = [recognizer locationInView:self.tableView];
    
    switch (recognizer.state) {
        case UIGestureRecognizerStateBegan:
            {
                NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:pt];
                
                if (indexPath) {
                    draggedCell = (EntryCell *)[self.tableView cellForRowAtIndexPath:indexPath];
                    draggedCell.dragType = EntryDragTypePending;
                    startPoint = pt;
                }
            }
            break;
            
        case UIGestureRecognizerStateChanged:
            {
                CGFloat offsetX = pt.x - startPoint.x;
                CGFloat offsetY = pt.y - startPoint.y;
                
                if (draggedCell) {
                    if (draggedCell.dragType == EntryDragTypeUrgency) {
                        CGFloat urgencyDelta = offsetY / 200.0;
                        draggedCell.entry.todo.urgency = MIN(1.0, MAX(0.0, initialUrgency - urgencyDelta));
                        [draggedCell statusWasChanged];
                    } else if (draggedCell.dragType == EntryDragTypeFrostiness) {
                        CGFloat frostinessDelta = offsetX / 200.0;
                        draggedCell.entry.todo.frostiness = MIN(1.0, MAX(0.0, initialFrostiness + frostinessDelta));
                        [draggedCell statusWasChanged];
                    } else if (fabs(offsetY) > 5) {
                        draggedCell.dragType = EntryDragTypeUrgency;
                        initialUrgency = draggedCell.entry.todo.urgency;
                        startPoint = pt;
                    } else if (fabs(offsetX) > 5) {
                        draggedCell.dragType = EntryDragTypeFrostiness;
                        initialFrostiness = draggedCell.entry.todo.frostiness;
                        startPoint = pt;
                    }
                }
            }
            break;
            
        default:
            draggedCell.dragType = EntryDragTypeNone;
            draggedCell = nil;
            break;
    }
}

- (void)setPriorityFilter:(float_t)priorityFilter {
    _priorityFilter = priorityFilter;
    self.filterSlider.value = priorityFilter;
    
    [[NSUserDefaults standardUserDefaults] setFloat:priorityFilter forKey:@"priorityFilter"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    [self reloadData];
}

#pragma mark - Private

- (void)keyboardWillShow:(NSNotification*)notification {
    NSDictionary *userInfo = notification.userInfo;
    
    CGRect keyboardRect = [self.tableView convertRect:[userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue] fromView:nil];
    
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationCurve:[userInfo[UIKeyboardAnimationCurveUserInfoKey] intValue]];
    [UIView setAnimationDuration:[userInfo[UIKeyboardAnimationDurationUserInfoKey] floatValue]];
    
    UIEdgeInsets newInset = self.tableView.contentInset;
    newInset.bottom = keyboardRect.size.height - (CGRectGetMaxY(keyboardRect) - CGRectGetMaxY(self.tableView.bounds));
    self.tableView.contentInset = newInset;
    self.tableView.scrollIndicatorInsets = newInset;
    
    [UIView commitAnimations];
}

- (void)keyboardWillHide:(NSNotification*)notification {
    NSDictionary *userInfo = notification.userInfo;
    
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationCurve:[userInfo[UIKeyboardAnimationCurveUserInfoKey] intValue]];
    [UIView setAnimationDuration:[userInfo[UIKeyboardAnimationDurationUserInfoKey] floatValue]];
    
    self.tableView.contentInset = UIEdgeInsetsMake(0, 0, 0, 0);
    self.tableView.scrollIndicatorInsets = self.tableView.contentInset;
    
    [UIView commitAnimations];
}


- (Entry *)entryAtIndexPath:(NSIndexPath *)indexPath {
    return (Entry *)[self.fetchedResultsController objectAtIndexPath:indexPath];
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
        Entry* entry =  [self entryAtIndexPath:self.pinchIndexPath];
        self.pinchInitialImportance = entry.todo.importance;
        [self updateImportanceForPinchScale:pinchRecognizer.scale];
    }
    else {
        if (pinchRecognizer.state == UIGestureRecognizerStateChanged) {
            [self updateImportanceForPinchScale:pinchRecognizer.scale];
        }
        else if ((pinchRecognizer.state == UIGestureRecognizerStateCancelled) || (pinchRecognizer.state == UIGestureRecognizerStateEnded)) {
            self.pinchIndexPath = nil;
        }
    }
}

- (void)updateRowHeights {
    [self.tableView beginUpdates];
    [self.tableView endUpdates];
}

- (void)updateImportanceForPinchScale:(CGFloat)scale {
    
    if (self.pinchIndexPath && (self.pinchIndexPath.section != NSNotFound) && (self.pinchIndexPath.row != NSNotFound)) {
        Entry* entry =  [self entryAtIndexPath:self.pinchIndexPath];
        CGFloat notches = (self.pinchInitialImportance * 100) + 1;
		notches = MAX(1.0, MIN(101.0, notches * scale));
        entry.todo.importance = (notches - 1) / 100.0f;
        EntryCell *cell = (EntryCell *)[self.tableView cellForRowAtIndexPath:self.pinchIndexPath];
        [cell importanceWasChanged];
        [self updateRowHeights];
    }
}

- (void)showTodoActionSheet:(Entry *)entry {
    self.selectedEntry = entry;
    NSString *completionActionName = (entry.todo.lastEntry.type == EntryTypeComplete) ?  @"No" : @"Yes";
    
    self.todoActionSheet = [[UIActionSheet alloc]
                              initWithTitle:@"Did you complete the todo?"
                              delegate:self
                              cancelButtonTitle:@"Cancel"
                              destructiveButtonTitle:nil
                              otherButtonTitles:completionActionName, @"Made progress", @"Repeat", nil];
    
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

- (void)showRepeatView:(Todo *)todo {
    [self performSegueWithIdentifier:@"Repeat todo" sender:todo];
}

- (void)createFetchedResultsController {
    NSManagedObjectContext *context = [[IBCoreDataStore mainStore] context];
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"Entry"];
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"timestamp" ascending:NO];
    [fetchRequest setSortDescriptors:@[sortDescriptor]];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"priority >= %f", self.priorityFilter];
    [fetchRequest setPredicate:predicate];
    self.fetchedResultsController = [[NSFetchedResultsController alloc]
                                     initWithFetchRequest:fetchRequest
                                     managedObjectContext:context
                                     sectionNameKeyPath:@"journalDateString"
                                     cacheName:nil];
}

- (IBAction)filterSliderValueChanged:(UISlider *)filterSlider {
    self.priorityFilter = filterSlider.value;
}

- (IBAction)addButtonTapped {
    if (self.priorityFilter > PriorityFilterShowActive) {
        self.priorityFilter = PriorityFilterShowActive;
    }
    
    [Todo create];
    [self reloadData];
    
    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
    [cell becomeFirstResponder];
}

- (void)doneButtonTapped {
    self.filterSlider.enabled = YES;
    [self.activeCell resignFirstResponder];
    self.activeCell = nil;
    [self reloadData];
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
    NSInteger doAgainButtonIndex       = takeActionButtonIndex + 1;
    
    Todo *todo = self.selectedEntry.todo;
    
    if (buttonIndex == markCompletedButtonIndex) {
        [todo createEntry:(todo.lastEntry.type == EntryTypeComplete) ? EntryTypeReady : EntryTypeComplete];
        [[IBCoreDataStore mainStore] save];
        [self reloadData];
    } else if (buttonIndex == takeActionButtonIndex) {
        [todo createEntry:EntryTypeAction];
        [[IBCoreDataStore mainStore] save];
        [self reloadData];
    } else if (buttonIndex == doAgainButtonIndex) {
        [self showRepeatView:todo];
    }
}

- (void)deleteActionSheetButtonClicked:(NSInteger)buttonIndex {
    if (buttonIndex == self.deleteActionSheet.destructiveButtonIndex) {
        [self.selectedEntry.todo destroy];
    } else {
        [self.selectedEntry destroy];
    }
    
    [IBCoreDataStore save];
    [self reloadData];
}   

#pragma mark - Table View Delegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.fetchedResultsController.sections.count;
}

- (NSInteger)tableView:(UITableView *)table numberOfRowsInSection:(NSInteger)section {
    if (self.fetchedResultsController.sections.count > 0) {
        id <NSFetchedResultsSectionInfo> sectionInfo = self.fetchedResultsController.sections[section];
        return [sectionInfo numberOfObjects];
    }
    
    return 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    static TMGrowingTextView *sizingTextView;
    
    if (!sizingTextView) {
        sizingTextView = [TMGrowingTextView new];
    }
    
    Entry *entry = [self entryAtIndexPath:indexPath];
    
    sizingTextView.text = entry.todo.title;
    sizingTextView.font = [UIFont systemFontOfSize:[EntryCell fontSizeForImportance:entry.todo.importance]];
    
    static const CGFloat margin =  21;
    CGFloat width = 280;
    CGFloat height = [sizingTextView sizeThatFits:CGSizeMake(width, 0)].height;
    
    return height + margin;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    EntryCell *cell = [tableView dequeueReusableCellWithIdentifier:@"EntryCell" forIndexPath:indexPath];
    cell.entry = [self entryAtIndexPath:indexPath];
    cell.journalViewController = self;
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self.tableView deselectRowAtIndexPath:indexPath animated:NO];
    
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    [cell becomeFirstResponder];
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

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
    return UITableViewCellEditingStyleDelete;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        Entry *entry = [self entryAtIndexPath:indexPath];
        
        if (entry.type == EntryTypeNew) {
            [entry.todo destroy];
            [self reloadData];
        } else {
            [self showDeleteActionSheet:[self entryAtIndexPath:indexPath]];
        }
    }
}

#pragma mark - Repeat Controller Delegate

- (void)repeatViewControllerDaysChanged:(RepeatViewController *)repeatViewController {
    [self.selectedEntry.todo createEntry:EntryTypeComplete];
    
    switch (repeatViewController.days) {
        case -1:
            break;
            
        case 0:
            [self.selectedEntry.todo createEntry:EntryTypeReady];
            break;
            
        default:
        {
            self.selectedEntry.todo.startDate = [[NSDate today] dateByAddingDays:repeatViewController.days];
        }
    }
    
    [IBCoreDataStore save];
    [self reloadData];
}
    
#pragma Text View Delegate
    
- (void)scrollCaretIntoView:(UITextView *)textView {
    CGRect caretRect = [textView caretRectForPosition:textView.selectedTextRange.start];
    caretRect = [self.tableView convertRect:caretRect fromView:textView];
    caretRect.size.height += 8;
    [self.tableView scrollRectToVisible:caretRect animated:NO];
}

- (void)cell:(EntryCell *)cell textViewDidChange:(UITextView *)textView {
    [self updateRowHeights];
    [self scrollCaretIntoView:textView];
}

- (void)cell:(EntryCell *)cell textViewDidBeginEditing:(UITextView *)textView {
    self.filterSlider.enabled = NO;
    self.activeCell = cell;
    
    if (!self.doneButton) {
        self.doneButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(doneButtonTapped)];
        self.addButton = self.navigationBarItem.rightBarButtonItem;
    }
    
    self.navigationBarItem.rightBarButtonItem = self.doneButton;
    
    [self updateRowHeights];
    [self scrollCaretIntoView:textView];
}

- (void)cell:(EntryCell *)cell textViewDidEndEditing:(UITextView *)textView {
    self.navigationBarItem.rightBarButtonItem = self.addButton;
    [self updateRowHeights];
}

@end
