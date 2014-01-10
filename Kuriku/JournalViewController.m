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

typedef enum {
    FilterAll,
    FilterActive,
    FilterInactive
} Filter;

@interface JournalViewController ()

@property (nonatomic) Filter filter;
@property (nonatomic) BOOL isAdding;
@property (nonatomic) EntryCell *activeCell;
@property (weak, nonatomic) IBOutlet UINavigationItem *navigationBarItem;
@property (strong, nonatomic) UIBarButtonItem *addButton;
@property (strong, nonatomic) UIBarButtonItem *doneButton;

@end

#pragma mark -

@implementation JournalViewController
    
- (void)createFetchedResultsController {
    NSString *filter;
    
    switch (self.filter) {
        case FilterAll:
            filter = nil;
            break;
        case FilterActive:
            filter = @"status = 0";
            break;
        case FilterInactive:
            filter = @"status != 0";
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

#pragma mark - Table View Delegate

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    EntryCell *cell = [tableView dequeueReusableCellWithIdentifier:@"EntryCell" forIndexPath:indexPath];
    cell.entry = [self entryAtIndexPath:indexPath];
    cell.journalViewController = self;
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    Entry *entry = [self entryAtIndexPath:indexPath];
    [self showTodoActionSheet:entry.todo];
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
        [entry.todo removeEntriesObject:entry];
        [entry destroy];
        [IBCoreDataStore save];
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
    [super controllerDidChangeContent:controller];
    
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

- (Entry *)entryAtIndexPath:(NSIndexPath *)indexPath {
    return (Entry *)[self.fetchedResultsController objectAtIndexPath:indexPath];
}

- (Todo *)todoAtIndexPath:(NSIndexPath *)indexPath {
    return [[self entryAtIndexPath:indexPath] todo];
}

@end
