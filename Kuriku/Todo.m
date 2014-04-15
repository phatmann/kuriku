//
//  Todo.m
//  Kuriku
//
//  Created by Tony Mann on 12/11/13.
//  Copyright (c) 2013 7Actions. All rights reserved.
//

#import "Todo.h"
#import "Journal.h"
#import <InnerBand/InnerBand.h>

static const NSTimeInterval kUrgentDaysBeforeDueDate = 14;
static const NSTimeInterval kSecondsInDay = 24 * 60 * 60;

@implementation Todo

@dynamic title;
@dynamic importance;
@dynamic urgency;
@dynamic createDate;
@dynamic dueDate;
@dynamic priority;
@dynamic notes;
@dynamic commitment;
@dynamic entries;
@dynamic journal;

- (void)awakeFromInsert {
    [super awakeFromInsert];
    self.createDate = [NSDate date];
    [self createEntry:EntryTypeNew];
    self.journal = [Journal first];
    [self setup];
}

- (void)awakeFromFetch {
    [super awakeFromFetch];
    [self setup];
}

- (void)setup {
    [self addObserver:self forKeyPath:@"importance" options:NSKeyValueObservingOptionInitial context:nil];
    [self addObserver:self forKeyPath:@"urgency" options:NSKeyValueObservingOptionInitial context:nil];
    [self addObserver:self forKeyPath:@"commitment" options:NSKeyValueObservingOptionInitial context:nil];
    [self addObserver:self forKeyPath:@"dueDate" options:NSKeyValueObservingOptionInitial context:nil];
    [self addObserver:self forKeyPath:@"entries" options:NSKeyValueObservingOptionOld context:nil];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    int kind            = [change[NSKeyValueChangeKindKey] intValue];
    
    if ([keyPath isEqualToString:@"urgency"] || [keyPath isEqualToString:@"importance"] || [keyPath isEqualToString:@"commitment"]) {
        [self updatePriority];
    } else if ([keyPath isEqualToString:@"dueDate"]) {
        if (self.dueDate) {
            [self updateUrgencyFromDueDate];
        } else {
            self.urgency = 0;
        }
    } else if ([keyPath isEqualToString:@"entries"]) {
        NSArray *oldEntries = change[NSKeyValueChangeOldKey];
        
        if (kind == NSKeyValueChangeRemoval) {
            if (self.entries.count == 0) {
                [self destroy];
                return;
            } else {
                for (Entry *entry in oldEntries) {
                    if (entry.type == EntryTypeNew) {
                        [self destroy];
                        return;
                    }
                }
            }
            
            if (oldEntries.count == 1) {
                Entry *deletedEntry = [oldEntries firstObject];
                
                if (deletedEntry.state != EntryStateObsolete &&
                    (deletedEntry.type == EntryTypeComplete || deletedEntry.type == EntryTypeReady)) {
                    NSIndexSet *indexes = change[NSKeyValueChangeIndexesKey];
                    NSUInteger deletedEntryIndex = [indexes firstIndex];
                    NSOrderedSet *entries = [NSOrderedSet orderedSetWithOrderedSet:self.entries range:NSMakeRange(deletedEntryIndex, self.entries.count - deletedEntryIndex) copyItems:NO];
                    for (Entry *entry in entries) {
                        if (entry.type == EntryTypeComplete || entry.type == EntryTypeReady) {
                            entry.state = EntryStateObsolete;
                        }
                    }
                }
            }
        }
    }
}

- (void)willSave {
    [super willSave];
    [self deleteObsoleteEntries];
    [self activateLastEntry];
}

- (Entry *)lastEntry {
    return [self.entries lastObject];
}

#pragma mark -

- (void)activateLastEntry {
    if (self.lastEntry.state != EntryStateActive)
        self.lastEntry.state = EntryStateActive;
}

- (void)deleteObsoleteEntries {
    for (Entry *entry in [self.entries copy]) {
        if (entry.state == EntryStateObsolete) {
            entry.todo = nil;
            [entry destroy];
        }
    }
}

+ (void)updateAllPriorities {
    for (Todo *todo in [Todo all]) {
        [todo updatePriority];
    }
}

+ (void)updateAllUrgenciesFromDueDate {
    NSDate *dateUrgentDaysFromNow = [NSDate dateWithTimeIntervalSinceNow:kSecondsInDay * kUrgentDaysBeforeDueDate];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"dueDate != NULL AND dueDate < %@", dateUrgentDaysFromNow];
    NSArray *todos = [Todo allForPredicate:predicate];
    
    for (Todo *todo in todos) {
        if (todo.lastEntry.type != EntryTypeHold && todo.lastEntry.type != EntryTypeComplete)
            [todo updateUrgencyFromDueDate];
    }
    
    [IBCoreDataStore save];
}

+ (int)urgencyFromDueDate:(NSDate *)dueDate {
    if (!dueDate)
        return 0;
    
    int daysUntilDue = [dueDate timeIntervalSinceNow] / kSecondsInDay;
    
    if (daysUntilDue <= 0) {
        return TodoRangeMaxValue;
    } else if (daysUntilDue >= kUrgentDaysBeforeDueDate) {
        return 0;
    } else {
        return ((kUrgentDaysBeforeDueDate - daysUntilDue) *  TodoRangeMaxValue) / kUrgentDaysBeforeDueDate;
    }
}

- (Entry *)createEntry:(EntryType)type {
    if (type != EntryTypeNew) {
        self.lastEntry.state = EntryStateInactive;
    }
    
    Entry *entry = [Entry create];
    entry.type = type;
    entry.todo = self;
    
    return entry;
}

- (Entry *)findOrCreateEntryForStartDate:(EntryType)type {
    return [self createEntry:type];
}

+ (void)updateAllPrioritiesIfNeeded {
    static NSString *priorityVersionKey = @"PriorityVersion";
    
    int priorityVersion = [[[IBCoreDataStore mainStore] metadataObjectForKey:priorityVersionKey] intValue];
    
    if (priorityVersion < TodoPriorityVersion) {
        [self updateAllPriorities];
        
        [[IBCoreDataStore mainStore] setMetadataObject:@(TodoPriorityVersion) forKey:priorityVersionKey];
        [[IBCoreDataStore mainStore] save];
    }
}

+ (void)updateTodosReadyToStart {
    // TODO: use lastEntry key path when modeled
    //NSPredicate *predicate = [NSPredicate predicateWithFormat:@"lastEntry.startDate >= %@", [NSDate today]];
    //NSArray *todos = [Todo allForPredicate:predicate];
    
    NSArray *todos = [Todo all];
    NSDate *today = [NSDate today];
    
    for (Todo *todo in todos) {
        if (todo.lastEntry.startDate && [todo.lastEntry.startDate timeIntervalSinceDate:today] <= 0)
            [todo createEntry:EntryTypeReady];
    }
    
    [IBCoreDataStore save];
}

+ (void)dailyUpdate {
    static NSString *dailyUpdateKey = @"DailyUpdate";
    
    NSDate *updateDate = [[IBCoreDataStore mainStore] metadataObjectForKey:dailyUpdateKey];
    NSDate *today = [NSDate today];
    
    if (!updateDate || ![updateDate isSameDay:today]) {
        [self updateAllUrgenciesFromDueDate];
        [self updateTodosReadyToStart];
        
        [[IBCoreDataStore mainStore] setMetadataObject:today forKey:dailyUpdateKey];
        [[IBCoreDataStore mainStore] save];
    }
}

+ (void)migrate {
    [IBCoreDataStore save];
}

#pragma mark - Private

- (void)updatePriority {
    CGFloat maxValue = TodoRangeMaxValue * 2;
    self.priority = (self.urgency + self.importance) / maxValue;
    
    if (self.commitment == TodoCommitmentToday)
        self.priority += maxValue + 1;
    else if (self.commitment == TodoCommitmentMaybe)
        self.priority -= maxValue + 1;
}

- (void)updateUrgencyFromDueDate {
    self.urgency = [Todo urgencyFromDueDate:self.dueDate];
}

@end
