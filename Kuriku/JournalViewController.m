//
//  JournalViewController.m
//  Kuriku
//
//  Created by Tony Mann on 12/11/13.
//  Copyright (c) 2013 7Actions. All rights reserved.
//

#import "JournalViewController.h"
#import "Entry.h"
#import "EntryCell.h"

@interface JournalViewController ()
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) NSFetchedResultsController *fetchedResultsController;
@end

@implementation JournalViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    //[self.tableView registerClass:[EntryCell class] forCellReuseIdentifier:@"EntryCell"];
    [self performFetch];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
    
- (void)performFetch {
    NSManagedObjectContext *context = [[IBCoreDataStore mainStore] context];
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"Entry"];
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"timestamp" ascending:NO];
    [fetchRequest setSortDescriptors:@[sortDescriptor]];
    self.fetchedResultsController = [[NSFetchedResultsController alloc]
                                     initWithFetchRequest:fetchRequest
                                     managedObjectContext:context
                                     sectionNameKeyPath:@"journalDate"
                                     cacheName:nil];
    self.fetchedResultsController.delegate = self;
    NSError *error;
    [self.fetchedResultsController performFetch:&error];
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
    EntryCell *cell = [tableView dequeueReusableCellWithIdentifier:@"EntryCell" forIndexPath:indexPath];
    Entry *entry = (Entry *)[self.fetchedResultsController objectAtIndexPath:indexPath];
    cell.titleLabel.text = entry.title;
    return cell;
}
    
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if ([[self.fetchedResultsController sections] count] > 0) {
        static NSDateFormatter *shortDateFormatter;
        static NSDateFormatter *longDateFormatter;
        
        if (!shortDateFormatter) {
            shortDateFormatter = [NSDateFormatter new];
            shortDateFormatter.dateStyle = NSDateFormatterShortStyle;
        }
        
        if (!longDateFormatter) {
            longDateFormatter = [NSDateFormatter new];
            [longDateFormatter setDateFormat:@"E, MMM d"];
        }
        
        id <NSFetchedResultsSectionInfo> sectionInfo = [self.fetchedResultsController sections][section];
        NSString *dateString = [sectionInfo name];
        NSDate *date = [shortDateFormatter dateFromString:dateString];
        return [longDateFormatter stringFromDate:date];
    }
    
    return nil;
}
    
- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView {
    return [self.fetchedResultsController sectionIndexTitles];
}
    
- (NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index {
    return [self.fetchedResultsController sectionForSectionIndexTitle:title atIndex:index];
}

#pragma mark - Fetched Results Controller Delegate

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
    [self.tableView reloadData];
}

- (NSString *)controller:(NSFetchedResultsController *)controller sectionIndexTitleForSectionName:(NSString *)sectionName {
    static NSDateFormatter *shortDateFormatter;
    static NSDateFormatter *tinyDateFormatter;
    
    if (!shortDateFormatter) {
        shortDateFormatter = [NSDateFormatter new];
        shortDateFormatter.dateStyle = NSDateFormatterShortStyle;
    }
    
    if (!tinyDateFormatter) {
        tinyDateFormatter = [NSDateFormatter new];
        [tinyDateFormatter setDateFormat:@"MM/d"];
    }
    
    NSDate *date = [shortDateFormatter dateFromString:sectionName];
    return [tinyDateFormatter stringFromDate:date];
}


@end
