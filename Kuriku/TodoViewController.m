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

@interface TodoViewController ()

@end

@implementation TodoViewController

#pragma mark -

- (void)createFetchedResultsController {
    NSManagedObjectContext *context = [[IBCoreDataStore mainStore] context];
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"Todo"];
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"priority" ascending:NO];
    [fetchRequest setSortDescriptors:@[sortDescriptor]];
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
    [self showEditTodoView:[self todoAtIndexPath:indexPath]];
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
