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
@property (strong, nonatomic) UIActionSheet *deleteActionSheet;
@property (weak, nonatomic) IBOutlet UISlider *filterSlider;
@property (weak, nonatomic) IBOutlet UIPanGestureRecognizer *panGestureRecognizer;
@property (weak, nonatomic) IBOutlet UILongPressGestureRecognizer *longPressGestureRecognizer;
@property (weak, nonatomic) IBOutlet UIRotationGestureRecognizer *rotationGestureRecognizer;
@property (weak, nonatomic) IBOutlet UIPinchGestureRecognizer *pinchGestureRecognizer;

@end

@implementation JournalViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];

    self.tableView.estimatedRowHeight = 44;
    
    float_t savedPriorityFilter = [[NSUserDefaults standardUserDefaults] floatForKey:@"priorityFilter"];
    
    if (savedPriorityFilter > 0)
        self.priorityFilter = savedPriorityFilter;
    else
        [self reloadData];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"Repeat todo"]) {
        UINavigationController *navigationController = segue.destinationViewController;
        RepeatViewController *repeatViewController = [navigationController.viewControllers firstObject];
        repeatViewController.delegate = self;
    } else {
        UINavigationController *navigationController = segue.destinationViewController;
        DatePickerViewController *datePickerViewController = [navigationController.viewControllers firstObject];
        datePickerViewController.delegate = self;

        if ([segue.identifier isEqualToString:@"Choose start date"]) {
            datePickerViewController.tag = @"startDate";
            datePickerViewController.date = self.activeCell.entry.todo.startDate;
        } else if ([segue.identifier isEqualToString:@"Choose due date"]) {
            datePickerViewController.tag = @"dueDate";
            datePickerViewController.date = self.activeCell.entry.todo.dueDate;
        }
    }
 }

- (IBAction)longPressGestureRecognizerWasChanged:(UILongPressGestureRecognizer *)recognizer {
    static const CGFloat kWellSize = 0.5f;
    static const CGFloat kMinMove = 5.0;
    static CGPoint startPoint;
    static CGFloat initialUrgency;
    static CGFloat initialFrostiness;
    static EntryCell *draggedCell;
    static BOOL chooseDate;
    NSIndexPath *indexPath;
    Entry *entry;
    
    CGPoint pt = [recognizer locationInView:self.tableView];
    
    switch (recognizer.state) {
        case UIGestureRecognizerStateBegan:
            indexPath = [self.tableView indexPathForRowAtPoint:pt];
            draggedCell = nil;
            
            if (indexPath) {
                entry = [self entryAtIndexPath:indexPath];
                if (entry.state == EntryStateActive) {
                    draggedCell = (EntryCell *)[self.tableView cellForRowAtIndexPath:indexPath];
                    draggedCell.dragType = EntryDragTypePending;
                    startPoint = pt;
                    chooseDate = NO;
                }
            }
            
            break;
            
        case UIGestureRecognizerStateChanged:
            if (draggedCell) {
                CGFloat offsetX = pt.x - startPoint.x;
                CGFloat offsetY = pt.y - startPoint.y;
                
                chooseDate = NO;
                
                if (draggedCell.dragType == EntryDragTypeUrgency) {
                    CGFloat range = draggedCell.titleTextView.frame.size.height * 2;
                    range -= kWellSize * range;
                    CGFloat urgency = initialUrgency - (offsetY / range);
                    
                    if (urgency < -kWellSize) {
                        chooseDate = YES;
                        draggedCell.datePrompt = @"Choose due date...";
                    } else {
                        draggedCell.entry.todo.urgency = fratiof(urgency);
                        [draggedCell temperatureWasChanged];
                    }
                } else if (draggedCell.dragType == EntryDragTypeFrostiness) {
                    CGFloat range = draggedCell.titleTextView.frame.size.width;
                    range -= kWellSize * range;
                    CGFloat frostiness = initialFrostiness + (offsetX / range);
                    
                    if (frostiness < -kWellSize) {
                        chooseDate = YES;
                        draggedCell.datePrompt = @"Choose start date...";
                    } else {
                        draggedCell.entry.todo.frostiness = fratiof(frostiness);
                        [draggedCell temperatureWasChanged];
                    }
                } else if (fabs(offsetY) > kMinMove) {
                    draggedCell.dragType = EntryDragTypeUrgency;
                    initialUrgency = draggedCell.entry.todo.urgency;
                    
                    if (initialUrgency < 0.0) {
                        if (offsetY > 0)
                            initialUrgency = 0.0;
                        else
                            initialUrgency = -kWellSize;
                    }
                    
                    startPoint = pt;
                } else if (fabs(offsetX) > kMinMove) {
                    draggedCell.dragType = EntryDragTypeFrostiness;
                    initialFrostiness = draggedCell.entry.todo.frostiness;
                    
                    if (initialFrostiness > 1.0) {
                        if (offsetX < 0)
                            initialFrostiness = 1.0;
                        else
                            initialFrostiness = 1.0 + kWellSize;
                    }
                    
                    startPoint = pt;
                }
            }
            break;
            
        case UIGestureRecognizerStateEnded:
            [IBCoreDataStore save];
            
            if (chooseDate) {
                self.activeCell = draggedCell;
                [self performSegueWithIdentifier: draggedCell.dragType == EntryDragTypeFrostiness ? @"Choose start date" : @"Choose due date"
                                          sender: nil];
            }
            
            /* ... */
            
        default:
            draggedCell.dragType = EntryDragTypeNone;
            draggedCell = nil;
    }
}

- (IBAction)panGestureRecognizerWasChanged:(UIPanGestureRecognizer *)recognizer {
    static EntryCell *pannedCell;
    static CGFloat initialProgressBarValue;
    NSIndexPath *indexPath;
    CGPoint pt;
    Entry *entry;
    
    CGPoint offset = [recognizer translationInView:self.tableView];
    
    switch (recognizer.state) {
        case UIGestureRecognizerStateBegan:
            pt = [recognizer locationInView:self.tableView];
            indexPath = [self.tableView indexPathForRowAtPoint:pt];
            pannedCell = nil;
            
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
                
                if (velocity.x > 1500.0 && offset.x > range * 0.3) {
                    pannedCell.progressBarValue = 1.0;
                    [pannedCell.entry.todo createEntry:EntryTypeComplete];
                    [self reloadData];
                    recognizer.enabled = NO;
                    recognizer.enabled = YES;
                } else {
                    pannedCell.progressBarValue = fmaxf(0.0, initialProgressBarValue + (offset.x / range));
                }
            }
            break;
            
        case UIGestureRecognizerStateEnded:
            if (pannedCell) {
                CGFloat delta = pannedCell.progressBarValue - initialProgressBarValue;
                CGFloat remaining = 1.0 - initialProgressBarValue;
                
                if (delta >= remaining / 2) {
                    // TODO: have entry and this use same repeat value (1.2)
                    if (pannedCell.progressBarValue > 1.2) {
                        self.selectedEntry = pannedCell.entry;
                        [self showRepeatView:pannedCell.entry.todo];
                    } else {
                        [pannedCell.entry.todo createEntry:pannedCell.progressBarValue >= 1.0 ? EntryTypeComplete : EntryTypeAction];
                        [self reloadData];
                    }
                    
                    [self.tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionTop animated:YES];
                } else {
                    pannedCell.progressBarValue = initialProgressBarValue;
                    
                    [UIView animateWithDuration:0.2 animations:^{
                        [pannedCell layoutIfNeeded];
                    }];
                }
                
                [IBCoreDataStore save];
            }
            
        default:
            break;
    }
}

- (IBAction)pinchGestureRecognizerWasChanged:(UIPinchGestureRecognizer *)recognizer {
    if (recognizer.state == UIGestureRecognizerStateBegan) {
        CGPoint pinchLocation = [recognizer locationInView:self.tableView];
        self.pinchIndexPath = [self.tableView indexPathForRowAtPoint:pinchLocation];
        Entry* entry =  [self entryAtIndexPath:self.pinchIndexPath];
        self.pinchInitialImportance = entry.todo.importance;
        [self updateImportanceForPinchScale:recognizer.scale];
    }
    else {
        if (recognizer.state == UIGestureRecognizerStateChanged) {
            [self updateImportanceForPinchScale:recognizer.scale];
        }
        else if ((recognizer.state == UIGestureRecognizerStateCancelled) || (recognizer.state == UIGestureRecognizerStateEnded)) {
            self.pinchIndexPath = nil;
        }
    }
}

- (IBAction)rotationGestureRecognizerWasChanged:(UIRotationGestureRecognizer *)recognizer {
    static const CGFloat kWellSize = 0.3f;
    
    static EntryCell *rotatedCell;
    static CGFloat initialTemperature;
    
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
                    initialTemperature = entry.todo.temperature;
                }
            }
            
            break;
            
        case UIGestureRecognizerStateChanged:
            if (rotatedCell) {
                CGFloat range = M_PI_4 / 2;
                CGFloat angle = recognizer.rotation;
                
                if (angle >= M_PI - range) {
                    angle = angle - M_PI;
                } else if (angle >= range) {
                    angle = range;
                }
                
                CGFloat temperature = fclampf(initialTemperature + (angle / range), -1.0 - kWellSize, 1.0 + kWellSize);
                
                if (fabsf(temperature) < kWellSize)
                    rotatedCell.entry.todo.temperature = 0;
                else
                    rotatedCell.entry.todo.temperature = temperature - copysignf(kWellSize, temperature);
                
                [rotatedCell temperatureWasChanged];
            }
            break;
            
        case UIGestureRecognizerStateEnded:
            if (rotatedCell) {
                [IBCoreDataStore save];
            }
            
        default:
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
    [self deleteActionSheetButtonClicked:buttonIndex];
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

#pragma mark - Gesture Recognizer

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRequireFailureOfGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    if (gestureRecognizer == self.pinchGestureRecognizer && otherGestureRecognizer == self.rotationGestureRecognizer)
        return YES;
    
    return NO;
}

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer {
    if (gestureRecognizer == self.panGestureRecognizer) {
        UIPanGestureRecognizer *panGestureRecognizer = (UIPanGestureRecognizer *)gestureRecognizer;
        CGPoint offset = [panGestureRecognizer translationInView:self.tableView];
        
        if (offset.x > 0)
            return YES;
        
        return NO;
    }
    return YES;
}

#pragma mark Date Picker View Delegate

- (void)datePickerViewControllerDismissed:(DatePickerViewController *)dateViewController {
    [self.activeCell.entry.todo setValue:[dateViewController.date dateAtStartOfDay] forKey:dateViewController.tag];
    [self.activeCell temperatureWasChanged];
    [IBCoreDataStore save];
}

@end
