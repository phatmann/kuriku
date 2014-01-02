//
//  TodoViewController.m
//  Kuriku
//
//  Created by Tony Mann on 12/11/13.
//  Copyright (c) 2013 7Actions. All rights reserved.
//

#import "TodoViewController.h"
#import "Todo.h"
#import "TodoCell.h"
#import "EditTodoViewController.h"
#import "Styles.h"

typedef enum {
    FilterActive,
    FilterToday,
    FilterScheduled,
    FilterComplete
} Filter;

typedef enum {
    SortPriority,
    SortUrgent,
    SortImportant,
    SortActivity
} Sort;

@interface TodoViewController ()
@property (weak, nonatomic) IBOutlet UISegmentedControl *filterChooser;
@property (weak, nonatomic) IBOutlet UISegmentedControl *sortChooser;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *sortBoxHeightConstraint;
@end

@implementation TodoViewController

- (IBAction)chooserChanged {
    BOOL canSort = (self.filterChooser.selectedSegmentIndex != FilterScheduled &&
                    self.filterChooser.selectedSegmentIndex != FilterComplete);
    
    if (canSort) {
        self.sortBoxHeightConstraint.constant = self.sortChooser.frame.size.height + 1;
    } else {
        self.sortBoxHeightConstraint.constant = 0;
    }
    
    [self reloadData];
}

#pragma mark -

- (void)createFetchedResultsController {
    // TODO: move filter and sort logic to Todo class, don't use magic numbers
    
    NSString *filter = nil;
    NSString *sortKey = nil;
    int status = 0;
    
    switch (self.filterChooser.selectedSegmentIndex) {
        case FilterActive:
            break;
        case FilterToday:
            filter  = @"commitment = 4";
            break;
        case FilterScheduled:
            sortKey = @"holdDate";
            status = 2;
            break;
        case FilterComplete:
            sortKey = @"lastEntryDate";
            status = 1;
            break;
    }
    
    if (!sortKey) {
        switch (self.sortChooser.selectedSegmentIndex) {
            case SortPriority:
                sortKey = @"priority";
                break;
            case SortImportant:
                sortKey = @"importance";
                break;
            case SortUrgent:
                sortKey = @"urgency";
                break;
            case SortActivity:
                sortKey = @"lastEntryDate";
                break;
        }
    }
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"status = %d", status];
    
    if (filter) {
        NSPredicate *filterPredicate = [NSPredicate predicateWithFormat:filter];
        predicate = [NSCompoundPredicate andPredicateWithSubpredicates:@[predicate, filterPredicate]];
    }
    
    NSManagedObjectContext *context = [[IBCoreDataStore mainStore] context];
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"Todo"];
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:sortKey ascending:NO];
    [fetchRequest setSortDescriptors:@[sortDescriptor]];
    [fetchRequest setPredicate:predicate];
    self.fetchedResultsController = [[NSFetchedResultsController alloc]
                                     initWithFetchRequest:fetchRequest
                                     managedObjectContext:context
                                     sectionNameKeyPath:nil
                                     cacheName:nil];
}

#pragma mark - Table View Delegate

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    TodoCell *cell = [tableView dequeueReusableCellWithIdentifier:@"TodoCell" forIndexPath:indexPath];
    cell.todo = [self todoAtIndexPath:indexPath];
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    [self showTodoActionSheet:[self todoAtIndexPath:indexPath]];
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        [[self todoAtIndexPath:indexPath] destroy];
        [[IBCoreDataStore mainStore] save];
    }
}

- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath {
    if (!tableView.isEditing) {
        [self showEditTodoView:[self todoAtIndexPath:indexPath]];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    Todo *todo = [self todoAtIndexPath:indexPath];
    return todoFontSize(todo) + 25;
}

#pragma mark -

- (Todo *)todoAtIndexPath:(NSIndexPath *)indexPath {
    return (Todo *)[self.fetchedResultsController objectAtIndexPath:indexPath];
}

@end
