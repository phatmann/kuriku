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

const NSTimeInterval kUrgentDaysBeforeDueDate = 14;
const NSTimeInterval kStaleDaysAfterLastEntryDate = 14;
static const NSTimeInterval kSecondsInDay = 24 * 60 * 60;

@implementation Todo

@dynamic title;
@dynamic importance;
@dynamic createDate;
@dynamic dueDate;
@dynamic startDate;
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
    [self addObserver:self forKeyPath:@"startDate" options:NSKeyValueObservingOptionInitial context:nil];
    [self addObserver:self forKeyPath:@"entries" options:NSKeyValueObservingOptionOld context:nil];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    //[super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    
    int kind = [change[NSKeyValueChangeKindKey] intValue];
    
    if ([keyPath isEqualToString:@"dueDate"] || [keyPath isEqualToString:@"startDate"] || [keyPath isEqualToString:@"importance"] || [keyPath isEqualToString:@"commitment"]) {
        [self updatePriority];
    } else if ([keyPath isEqualToString:@"entries"]) {
        NSArray *removedEntries = change[NSKeyValueChangeOldKey];
        
        if (kind == NSKeyValueChangeRemoval) {
            if (self.entries.count == 0) {
                [self destroy];
                return;
            } else {
                for (Entry *entry in removedEntries) {
                    if (entry.type == EntryTypeNew) {
                        [self destroy];
                        return;
                    }
                }
            }
            
            if (removedEntries.count == 1) {
                Entry *removedEntry = [removedEntries firstObject];
                
                if (removedEntry.type == EntryTypeComplete || removedEntry.type == EntryTypeReady) {
                    NSIndexSet *indexes = change[NSKeyValueChangeIndexesKey];
                    NSUInteger removedEntryIndex = [indexes firstIndex];
                    NSOrderedSet *entries = [NSOrderedSet orderedSetWithOrderedSet:self.entries range:NSMakeRange(removedEntryIndex, self.entries.count - removedEntryIndex) copyItems:NO];
                    
                    for (Entry *entry in entries) {
                        if (entry.type == EntryTypeComplete || entry.type == EntryTypeReady) {
                            entry.todo = nil;
                            [entry destroy];
                        }
                    }
                }
            }
        }
        
        if (self.lastEntry.state != EntryStateActive)
            self.lastEntry.state = EntryStateActive;
    }
}

+ (NSSet *)keyPathsForValuesAffectingUrgency {
    return [NSSet setWithObjects:@"dueDate", nil];
}

- (Entry *)lastEntry {
    return [self.entries lastObject];
}

- (float_t)staleness {
    if (!self.lastEntry)
        return 0;
    
    int daysAfterLastEntryDate = -[[self.lastEntry.timestamp dateAtStartOfDay] timeIntervalSinceNow] / kSecondsInDay;
    
    if (daysAfterLastEntryDate >= kStaleDaysAfterLastEntryDate) {
        return 1.0f;
    } else {
        return 1.0f - ((kStaleDaysAfterLastEntryDate - daysAfterLastEntryDate) / kStaleDaysAfterLastEntryDate);
    }
}

- (float_t)urgency {
    return urgencyFromDueDate(self.dueDate);
}

- (void)setUrgency:(float_t)urgency {
    self.dueDate = dueDateFromUrgency(urgency);
}

#pragma mark -

float_t urgencyFromDueDate(NSDate *dueDate) {
    if (!dueDate)
        return 0;
        
    int daysUntilDue = [dueDate timeIntervalSinceNow] / kSecondsInDay;
    
    if (daysUntilDue <= 0) {
        return 1.0f;
    } else if (daysUntilDue >= kUrgentDaysBeforeDueDate) {
        return 0.0f;
    } else {
        return (kUrgentDaysBeforeDueDate - daysUntilDue) / kUrgentDaysBeforeDueDate;
    }
}

NSDate *dueDateFromUrgency(float_t urgency) {
    if (urgency == 0) {
        return nil;
    } else {
        int daysUntilDue = kUrgentDaysBeforeDueDate - (urgency * kUrgentDaysBeforeDueDate);
        return [[NSDate today] dateByAddingDays:daysUntilDue];
    }
}

+ (void)updateAllPriorities {
    for (Todo *todo in [Todo all]) {
        [todo updatePriority];
    }
}

+ (void)updatePrioritiesFromDueDate {
    NSDate *dateUrgentDaysFromNow = [NSDate dateWithTimeIntervalSinceNow:kSecondsInDay * kUrgentDaysBeforeDueDate];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"dueDate != NULL AND dueDate < %@", dateUrgentDaysFromNow];
    NSArray *todos = [Todo allForPredicate:predicate];
    
    for (Todo *todo in todos) {
        if (todo.lastEntry.type != EntryTypeComplete)
            [todo updatePriority];
    }
    
    [IBCoreDataStore save];
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
    NSArray *todos = [Todo all];
    NSDate *today = [NSDate today];
    
    for (Todo *todo in todos) {
        if (todo.startDate && [todo.startDate timeIntervalSinceDate:today] <= 0) {
            todo.startDate = nil;
            [todo createEntry:EntryTypeReady];
        }
    }
    
    [IBCoreDataStore save];
}

+ (void)dailyUpdate {
    static NSString *dailyUpdateKey = @"DailyUpdate";
    
    NSDate *updateDate = [[IBCoreDataStore mainStore] metadataObjectForKey:dailyUpdateKey];
    NSDate *today = [NSDate today];
    
    if (!updateDate || ![updateDate isSameDay:today]) {
        [self updatePrioritiesFromDueDate];
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
    if (self.startDate) {
        self.priority = 0;
        return;
    }
    
    self.priority = self.importance * 0.5;
    
    // TODO: replace with temperature
    
    if (self.urgency > 0.1) {
        self.priority += self.urgency * 0.5;
    } else if (self.staleness > 0.1) {
        self.priority += self.staleness * 0.5;
    }
    
//    if (self.commitment == TodoCommitmentToday)
//        self.priority += kMaxValue + 1;
//    else if (self.commitment == TodoCommitmentMaybe)
//        self.priority -= kMaxValue + 1;
}

@end
