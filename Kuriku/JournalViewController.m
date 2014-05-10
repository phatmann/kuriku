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
#import "GlowingTextView.h"
#import <NUI/NUISettings.h>
#import <NUI/UILabel+NUI.h>
#import <InnerBand.h>

static const CGFloat kEstimatedRowHeight = 57.0f;

@interface JournalViewController ()
{
    BOOL _isAdding;
}

@property (weak, nonatomic) IBOutlet UINavigationItem *navigationBarItem;
@property (weak, nonatomic) IBOutlet UISlider *filterSlider;
@property (weak, nonatomic) IBOutlet UIPanGestureRecognizer *panGestureRecognizer;
@property (weak, nonatomic) IBOutlet UILongPressGestureRecognizer *longPressGestureRecognizer;
@property (weak, nonatomic) IBOutlet UIRotationGestureRecognizer *rotationGestureRecognizer;
@property (weak, nonatomic) IBOutlet UIPinchGestureRecognizer *pinchGestureRecognizer;

@property (strong, nonatomic) Entry *selectedEntry;
@property (nonatomic) float_t priorityFilter;
@property (nonatomic) EntryCell *activeCell;
@property (strong, nonatomic) UIBarButtonItem *addButton;
@property (strong, nonatomic) UIBarButtonItem *doneButton;
@property (strong, nonatomic) UIActionSheet *deleteActionSheet;

@end

@implementation JournalViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];

    self.tableView.estimatedRowHeight = kEstimatedRowHeight;
    
    float_t savedPriorityFilter = [[NSUserDefaults standardUserDefaults] floatForKey:@"priorityFilter"];
    
    if (savedPriorityFilter > 0) {
        self.priorityFilter = savedPriorityFilter;
        self.filterSlider.value = self.priorityFilter;
    } else {
        [self fetchData];
        [self.tableView reloadData];
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"Repeat todo"]) {
        UINavigationController *navigationController = segue.destinationViewController;
        RepeatViewController *repeatViewController = [navigationController.viewControllers firstObject];
        repeatViewController.delegate = self;
    } else if ([segue.identifier isEqualToString:@"Edit todo"]) {
        Todo *todo = sender;
        UINavigationController *navigationController = segue.destinationViewController;
        EditTodoViewController *editTodoViewController = [navigationController.viewControllers firstObject];
        editTodoViewController.delegate = self;
        editTodoViewController.todo = todo;
    }
}

- (void)setPriorityFilter:(float_t)priorityFilter {
    if (_priorityFilter == priorityFilter)
        return;
    
    _priorityFilter = priorityFilter;
    
    [[NSUserDefaults standardUserDefaults] setFloat:priorityFilter forKey:@"priorityFilter"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    [self fetchData];
    [self.tableView reloadData];
}

#pragma mark - Gesture Handling

- (IBAction)longPressGestureRecognizerWasChanged:(UILongPressGestureRecognizer *)recognizer {
    if (recognizer.state == UIGestureRecognizerStateBegan) {
        CGPoint pt = [recognizer locationInView:self.tableView];
        NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:pt];
        
        if (indexPath) {
            Entry *entry = [self entryAtIndexPath:indexPath];
            [self performSegueWithIdentifier:@"Edit todo" sender:entry.todo];
        }
    }
}

- (IBAction)panGestureRecognizerWasChanged:(UIPanGestureRecognizer *)recognizer {
    static EntryCell *pannedCell;
    static CGFloat initialProgressBarValue;
    static BOOL shouldRepeat;
    
    NSIndexPath *indexPath;
    CGPoint pt;
    Entry *entry;
    
    CGPoint offset = [recognizer translationInView:self.tableView];
    
    switch (recognizer.state) {
        case UIGestureRecognizerStateBegan:
            pt = [recognizer locationInView:self.tableView];
            indexPath = [self.tableView indexPathForRowAtPoint:pt];
            pannedCell = nil;
            shouldRepeat = NO;
            
            if (indexPath) {
                entry = [self entryAtIndexPath:indexPath];
                
                if (entry.state == EntryStateActive) {
                    pannedCell = (EntryCell *)[self.tableView cellForRowAtIndexPath:indexPath];
                    initialProgressBarValue = pannedCell.progressBarValue;
                }
            }

            break;
        
        case UIGestureRecognizerStateChanged:
            if (pannedCell) {
                CGFloat range = pannedCell.frame.size.width;
                CGPoint velocity = [recognizer velocityInView:self.tableView];
                
                if (velocity.x > 1500 && offset.x > 100) {
                    pannedCell.progressBarValue = 1.0;
                    [self scrollToTop];
                    [pannedCell.entry.todo createEntry:EntryTypeComplete];
                    recognizer.enabled = NO;
                    recognizer.enabled = YES;
                } else {
                    pannedCell.progressBarValue = fmaxf(0.0, initialProgressBarValue + (offset.x / range));
                    shouldRepeat = fabsf(offset.y) > 50;
                    pannedCell.repeatIcon.hidden = !shouldRepeat;
                }
            }
            break;
            
        case UIGestureRecognizerStateEnded:
            if (pannedCell) {
                if (shouldRepeat) {
                    pannedCell.repeatIcon.hidden = YES;
                    self.selectedEntry = pannedCell.entry;
                    [self showRepeatView:pannedCell.entry.todo];
                    pannedCell.progressBarValue = initialProgressBarValue;
                } else {
                    CGFloat delta = pannedCell.progressBarValue - initialProgressBarValue;
                    CGFloat remaining = 1.0 - initialProgressBarValue;
                    
                    if (delta >= remaining / 4) {
                        [self scrollToTop];
                        [pannedCell.entry.todo createEntry:pannedCell.progressBarValue >= 1.0 ? EntryTypeComplete : EntryTypeAction];
                    } else {
                        pannedCell.progressBarValue = initialProgressBarValue;
                        
                        [UIView animateWithDuration:0.2 animations:^{
                            [pannedCell layoutIfNeeded];
                        }];
                    }
                
                    [IBCoreDataStore save];
                }
            }
            break;
            
        default:
            ;
    }
}

- (IBAction)pinchGestureRecognizerWasChanged:(UIPinchGestureRecognizer *)recognizer {
    static EntryCell *pinchedCell;
    static CGFloat initialImportance;
    NSIndexPath *indexPath;
    CGPoint pt;
    Entry *entry;
    
    switch (recognizer.state) {
        case UIGestureRecognizerStateBegan:
            pt = [recognizer locationInView:self.tableView];
            indexPath = [self.tableView indexPathForRowAtPoint:pt];
            pinchedCell = nil;
            
            if (indexPath) {
                entry =  [self entryAtIndexPath:indexPath];
                
                if (entry.state == EntryStateActive) {
                    pinchedCell = (EntryCell *)[self.tableView cellForRowAtIndexPath:indexPath];
                    initialImportance = entry.todo.importance;
                }
            }
            
            break;
            
        case UIGestureRecognizerStateChanged:
            if (pinchedCell) {
                CGFloat notches = (initialImportance * 100) + 1;
                notches = MAX(1.0, MIN(101.0, notches * recognizer.scale));
                pinchedCell.entry.todo.importance = (notches - 1) / 100.0f;
                [pinchedCell importanceWasChanged];
            }

            break;
            
        case UIGestureRecognizerStateEnded:
            [self updateRowHeights];
            [IBCoreDataStore save];
            break;
            
        default:
            ;
    }
}

- (IBAction)rotationGestureRecognizerWasChanged:(UIRotationGestureRecognizer *)recognizer {
    static const CGFloat kWellSize = 0.4f;
    
    static EntryCell *rotatedCell;
    static CGFloat initialValue;
    static const CGFloat range = M_PI_4 / 2;
    
    NSIndexPath *indexPath;
    CGPoint pt;
    Entry *entry;
    
    switch (recognizer.state) {
        case UIGestureRecognizerStateBegan:
            pt = [recognizer locationInView:self.tableView];
            indexPath = [self.tableView indexPathForRowAtPoint:pt];
            rotatedCell = nil;
            
            if (indexPath) {
                entry = [self entryAtIndexPath:indexPath];
                
                if (entry.state == EntryStateActive) {
                    rotatedCell = (EntryCell *)[self.tableView cellForRowAtIndexPath:indexPath];
                    initialValue = entry.todo.temperature + copysign(kWellSize / 2, recognizer.rotation);
                }
            }
            
            break;
            
        case UIGestureRecognizerStateChanged:
            if (rotatedCell) {
                CGFloat value = (recognizer.rotation / range) + initialValue;
                
                if (fabsf(value) < kWellSize / 2)
                    rotatedCell.entry.todo.temperature = 0;
                else
                    rotatedCell.entry.todo.temperature = fclampf(value - copysign(kWellSize / 2, value), -1.0, 1.0);

                [rotatedCell temperatureWasChanged];
            }
            break;
            
        case UIGestureRecognizerStateEnded:
            if (rotatedCell) {
                [IBCoreDataStore save];
            }
            break;
            
        default:
            ;
    }
}

//- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRequireFailureOfGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
//    if (gestureRecognizer == self.pinchGestureRecognizer && otherGestureRecognizer == self.rotationGestureRecognizer)
//        return YES;
//    
//    return NO;
//}

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer {
    if (gestureRecognizer == self.panGestureRecognizer) {
        UIPanGestureRecognizer *panGestureRecognizer = (UIPanGestureRecognizer *)gestureRecognizer;
        CGPoint offset = [panGestureRecognizer translationInView:self.tableView];
        
        if (offset.x > 0)
            return YES;
        
        return NO;
    }
    
//    if (gestureRecognizer == self.pinchGestureRecognizer) {
//        UIPinchGestureRecognizer *pinchGestureRecognizer = (UIPinchGestureRecognizer *)gestureRecognizer;
//        
//        if (fabsf(pinchGestureRecognizer.scale - 1.0) > 0.1)
//            return YES;
//        
//        return NO;
//    }
    
//    if (gestureRecognizer == self.rotationGestureRecognizer) {
//        UIRotationGestureRecognizer *rotationGestureRecognizer = (UIRotationGestureRecognizer *)gestureRecognizer;
//        
//        if (fabsf(rotationGestureRecognizer.rotation) > M_PI / 32)
//            return YES;
//        
//        return NO;
//    }
    
    return YES;
}

#pragma mark - Action Sheet Delegate

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    [self deleteActionSheetButtonClicked:buttonIndex];
}

- (void)deleteActionSheetButtonClicked:(NSInteger)buttonIndex {
    if (buttonIndex == self.deleteActionSheet.destructiveButtonIndex) {
        [self.selectedEntry.todo destroy];
    } else {
        [self.selectedEntry destroy];
    }
    
    [IBCoreDataStore save];
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
    static GlowingTextView *sizingTextView;
    
    if (!sizingTextView) {
        sizingTextView = [GlowingTextView new];
    }
    
    Entry *entry = [self entryAtIndexPath:indexPath];
    
    sizingTextView.text = entry.todo.title;
    sizingTextView.font = [EntryCell fontForEntry:entry];
    
    static const CGFloat margin = 21;
    CGFloat width = 300;
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

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        Entry *entry = [self entryAtIndexPath:indexPath];
        
        if (entry.type == EntryTypeNew) {
            [entry.todo destroy];
            [IBCoreDataStore save];
        } else {
            [self showDeleteActionSheet:[self entryAtIndexPath:indexPath]];
        }
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 35;
}

- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForHeaderInSection:(NSInteger)section {
    return 35;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UILabel *label = [UILabel new];
    label.nuiClass = @"JournalSectionHeader";
    
    static NSDateFormatter *longDateFormatter;
    
    if (!longDateFormatter) {
        longDateFormatter = [NSDateFormatter new];
        [longDateFormatter setDateFormat:@"   E MMM d"];
    }
    
    id <NSFetchedResultsSectionInfo> sectionInfo = [self.fetchedResultsController sections][section];
    NSDate *date = [Entry journalDateFromString:sectionInfo.name];
    label.text = [longDateFormatter stringFromDate:date];

    return label;
}

#pragma mark - Repeat Controller Delegate

- (void)repeatViewControllerDaysChanged:(RepeatViewController *)repeatViewController {
    [self scrollToTop];
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
    
    [self scrollCaretIntoView:textView];
}

- (void)cell:(EntryCell *)cell textViewDidEndEditing:(UITextView *)textView {
    self.navigationBarItem.rightBarButtonItem = self.addButton;
    
    if (self.activeCell.entry.todo.title.length > 0)
        [IBCoreDataStore save];
    else
        [self.activeCell.entry.todo destroy];
    
    [self updateRowHeights];
    self.activeCell = nil;
}

#pragma mark - Edit Todo Controller Delegate

- (void)todoWasEdited:(Todo *)todo {
    [self.tableView reloadData];
}

#pragma mark - Action Handlers

- (IBAction)filterSliderValueChanged:(UISlider *)filterSlider {
    static const CGFloat notchSize = 0.03;
    CGFloat coldMaxPriority = [Entry normalPriorityFromTodoPriority:TodoColdMaxPriority];
    
    if (filterSlider.value < notchSize)
        filterSlider.value = 0;
    else if (fabsf(filterSlider.value - EntryActiveMinPriority) < notchSize)
        filterSlider.value = EntryActiveMinPriority;
    else if (fabsf(filterSlider.value - EntryNormalMinPriority) < notchSize)
        filterSlider.value = EntryNormalMinPriority;
    else if (fabsf(filterSlider.value - coldMaxPriority) < notchSize)
        filterSlider.value = coldMaxPriority;
    
    if (filterSlider.value < EntryActiveMinPriority)
        self.priorityFilter = 0;
    else if (filterSlider.value < EntryNormalMinPriority)
        self.priorityFilter = EntryActiveMinPriority;
    else
        self.priorityFilter = filterSlider.value;
}

- (IBAction)addButtonTapped {
    _isAdding = YES;
    [self scrollToTop];
    [Todo create];
}

- (void)doneButtonTapped {
    self.filterSlider.enabled = YES;
    [self.activeCell resignFirstResponder];
}

#pragma mark - Fetched Results Delegate

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller {
    [self.tableView beginUpdates];
}

- (void)controller:(NSFetchedResultsController *)controller didChangeSection:(id <NSFetchedResultsSectionInfo>)sectionInfo atIndex:(NSUInteger)sectionIndex forChangeType:(NSFetchedResultsChangeType)type {
    switch(type) {
        case NSFetchedResultsChangeInsert:
            [self.tableView insertSections:[NSIndexSet indexSetWithIndex:sectionIndex]
                          withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeDelete:
            [self.tableView deleteSections:[NSIndexSet indexSetWithIndex:sectionIndex]
                          withRowAnimation:UITableViewRowAnimationFade];
            break;
    }
}


- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type newIndexPath:(NSIndexPath *)newIndexPath {
    EntryCell *entryCell;
    
    switch(type) {
        case NSFetchedResultsChangeInsert:
            [self.tableView insertRowsAtIndexPaths:@[newIndexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
            break;
            
        case NSFetchedResultsChangeDelete:
            [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
            break;
            
        case NSFetchedResultsChangeUpdate:
            entryCell = (EntryCell *)[self.tableView cellForRowAtIndexPath:indexPath];
            [entryCell refresh];
            break;
            
        case NSFetchedResultsChangeMove:
            break;
    }
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
    [self.tableView endUpdates];
    
    if (_isAdding) {
        NSIndexPath *topRowIndexPath = [NSIndexPath indexPathForRow:0 inSection:0];
        UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:topRowIndexPath];
        [cell becomeFirstResponder];
        _isAdding = NO;
    }
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

- (void)updateRowHeights {
    [self.tableView beginUpdates];
    [self.tableView endUpdates];
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

- (void)fetchData {
    if (!self.fetchedResultsController) {
        NSManagedObjectContext *context = [[IBCoreDataStore mainStore] context];
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"Entry"];
        NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"createDate" ascending:NO];
        [fetchRequest setSortDescriptors:@[sortDescriptor]];
        
        self.fetchedResultsController = [[NSFetchedResultsController alloc]
                                         initWithFetchRequest:fetchRequest
                                         managedObjectContext:context
                                         sectionNameKeyPath:@"journalDateString"
                                         cacheName:nil];
        self.fetchedResultsController.delegate = self;
    }
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"priority >= %f OR updateDate > %@", self.priorityFilter, [NSDate date]];
    [self.fetchedResultsController.fetchRequest setPredicate:predicate];
    
    NSError *error;
    [self.fetchedResultsController performFetch:&error];
}

- (void)scrollToTop {
    [self.tableView setContentOffset:CGPointZero animated:NO];
}

@end
