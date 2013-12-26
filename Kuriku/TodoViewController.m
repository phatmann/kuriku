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
    FilterAll,
    FilterUrgent,
    FilterImportant,
    FilterMustDo,
    FilterScheduled,
    FilterComplete
} Filter;

@interface TodoViewController ()
@property (weak, nonatomic) IBOutlet UISegmentedControl *filterButtons;
@end

@implementation TodoViewController

- (IBAction)filterButtonsChanged {
    [self reloadData];
}

#pragma mark -

- (void)createFetchedResultsController {
    // TODO: move logic to Todo class
    
    NSString *filter = nil;
    NSString *sortKey;
    BOOL includeCompleted = NO;
    BOOL includeScheduled = NO;
    
    switch (self.filterButtons.selectedSegmentIndex) {
        case FilterAll:
            sortKey = @"priority";
            break;
        case FilterUrgent:
            sortKey = @"urgency";
            filter  = @"urgency > 0";
            break;
        case FilterImportant:
            sortKey = @"importance";
            break;
        case FilterMustDo:
            sortKey = @"priority";
            filter  = @"commitment > 0";
            break;
        case FilterScheduled:
            sortKey = @"startDate";
            filter  = @"startDate != NULL";
            includeScheduled = YES;
            break;
        case FilterComplete:
            sortKey = @"completionDate";
            filter  = @"completionDate != NULL";
            includeCompleted = YES;
            break;
    }
    
    NSPredicate *predicate = filter ? [NSPredicate predicateWithFormat:filter] : nil;
    
    if (!includeCompleted) {
        NSPredicate *hideCompleted = [NSPredicate predicateWithFormat:@"completionDate = NULL"];
        
        if (predicate)
            predicate = [NSCompoundPredicate andPredicateWithSubpredicates:@[predicate, hideCompleted]];
        else
            predicate = hideCompleted;
    }
    
    if (!includeScheduled) {
        NSPredicate *hideScheduled = [NSPredicate predicateWithFormat:@"startDate = NULL OR startDate < %@", [NSDate today]];
        
        if (predicate)
            predicate = [NSCompoundPredicate andPredicateWithSubpredicates:@[predicate, hideScheduled]];
        else
            predicate = hideScheduled;
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
