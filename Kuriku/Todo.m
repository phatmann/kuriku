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
@dynamic repeatDays;
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
    [self updatePriority];
}

- (void)didChangeValueForKey:(NSString *)key {
    [super didChangeValueForKey:key];
    
    if ([key isEqualToString:@"urgency"] || [key isEqualToString:@"importance"] || [key isEqualToString:@"commitment"]) {
        [self updatePriority];
    } else if ([key isEqualToString:@"dueDate"]) {
        if (self.dueDate) {
            [self updateUrgencyFromDueDate];
        } else {
            self.urgency = 0;
        }
    }
}

- (void)willChangeValueForKey:(NSString *)inKey withSetMutation:(NSKeyValueSetMutationKind)inMutationKind usingObjects:(NSSet *)inObjects {
    [super willChangeValueForKey:inKey withSetMutation:inMutationKind usingObjects:inObjects];
    
    if (inMutationKind == NSKeyValueMinusSetMutation && inObjects.count == 1) {
        Entry *deletedEntry = [inObjects anyObject];
        
        if (deletedEntry.state != EntryStateObsolete &&
            (deletedEntry.type == EntryTypeComplete || deletedEntry.type == EntryTypeReady)) {
            NSUInteger deletedEntryIndex = [self.entriesByDate indexOfObject:deletedEntry];
            NSArray *entries = [self.entriesByDate subarrayWithRange:NSMakeRange(deletedEntryIndex + 1, self.entriesByDate.count - deletedEntryIndex - 1)];
            
            for (Entry *entry in entries) {
                if (entry.type == EntryTypeComplete || entry.type == EntryTypeReady) {
                    entry.state = EntryStateObsolete;
                }
            }
        }
    }
}

- (void)didChangeValueForKey:(NSString *)inKey withSetMutation:(NSKeyValueSetMutationKind)inMutationKind usingObjects:(NSSet *)inObjects {
    [super didChangeValueForKey:inKey withSetMutation:inMutationKind usingObjects:inObjects];
    
    if (self.isDeleted)
        return;
    
    if ([inKey isEqualToString:@"entries"]) {
        if (inMutationKind == NSKeyValueMinusSetMutation) {
            if (self.entries.count == 0) {
                [self destroy];
            } else {
                for (Entry *entry in inObjects) {
                    if (entry.type == EntryTypeNew) {
                        [self destroy];
                        break;
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

- (NSArray *)entriesByDate {
    // TODO: cache sorted entries
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"timestamp" ascending:YES];
    return [self.entries sortedArrayUsingDescriptors:@[sortDescriptor]];
}

- (Entry *)lastEntry {
    return [[self entriesByDate] lastObject];
}

#pragma mark -

- (void)activateLastEntry {
    if (self.lastEntry.state != EntryStateActive)
        self.lastEntry.state = EntryStateActive;
}


- (void)deleteObsoleteEntries {
    for (Entry *entry in [self.entries copy]) {
        if (entry.state == EntryStateObsolete) {
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
        Entry *lastEntry = [self.entriesByDate lastObject];
        lastEntry.state = EntryStateInactive;
    }
    
    Entry *entry = [Entry create];
    entry.type = type;
    entry.todo = self;
    [self addEntriesObject:entry];
    
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

+ (void)dailyUpdate {
    static NSString *dailyUpdateKey = @"DailyUpdate";
    
    NSDate *updateDate = [[IBCoreDataStore mainStore] metadataObjectForKey:dailyUpdateKey];
    NSDate *today = [NSDate today];
    
    if (!updateDate || ![updateDate isSameDay:today]) {
        [self updateAllUrgenciesFromDueDate];
        
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
