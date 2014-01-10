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

@interface Todo ()

@end

static const NSTimeInterval kUrgentDaysBeforeDueDate = 14;
static const NSTimeInterval kSecondsInDay = 24 * 60 * 60;

@implementation Todo

@dynamic title;
@dynamic importance;
@dynamic urgency;
@dynamic createDate;
@dynamic dueDate;
@dynamic holdDate, primitiveHoldDate;
@dynamic primitiveLastEntryType;
@dynamic lastEntryDate;
@dynamic repeatDays;
@dynamic priority;
@dynamic star;
@dynamic status;
@dynamic notes;
@dynamic commitment;
@dynamic entries;
@dynamic journal;

- (void)awakeFromInsert {
    [super awakeFromInsert];
    self.createDate = [NSDate date];
    [self createEntry:EntryTypeCreate];
    self.journal = [Journal first];
}

- (void)didChangeValueForKey:(NSString *)key {
    [super didChangeValueForKey:key];
    
    if ([key isEqualToString:@"urgency"] || [key isEqualToString:@"importance"] || [key isEqualToString:@"commitment"]) {
        [self updatePriority];
    } else if ([key isEqualToString:@"status"]) {
        switch (self.status) {
            case TodoStatusNormal:
                [self createEntry:EntryTypeReady];
                break;
            case TodoStatusCompleted:
                [self createEntry:EntryTypeComplete];
                
                if (self.repeatDays == 0) {
                    self.status = TodoStatusNormal;
                } else {
                    if (self.repeatDays > 0) {
                        self.holdDate = [[[NSDate date] dateByAddingDays:self.repeatDays] dateAtStartOfDay];
                    }
                }

                break;
            case TodoStatusHold:
                [self createEntry:EntryTypeHold];
                break;
        }
        
        if (self.status != TodoStatusHold && self.holdDate) {
            self.primitiveHoldDate = nil;
        }
    } else if ([key isEqualToString:@"dueDate"]) {
        if (self.dueDate) {
            [self updateUrgencyFromDueDate];
        } else {
            self.urgency = 0;
        }
    } else if ([key isEqualToString:@"holdDate"]) {
        self.status = self.holdDate ? TodoStatusHold : TodoStatusNormal;
    }
}

- (void)didChangeValueForKey:(NSString *)inKey withSetMutation:(NSKeyValueSetMutationKind)inMutationKind usingObjects:(NSSet *)inObjects {
    [super didChangeValueForKey:inKey withSetMutation:inMutationKind usingObjects:inObjects];
    
    if (self.isDeleted)
        return;
    
    if ([inKey isEqualToString:@"entries"]) {
        if (self.entries.count == 0) {
            [self createEntry:EntryTypeReady];
        }
    }
}

- (NSArray *)entriesByDate {
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"timestamp" ascending:YES];
    return [self.entries sortedArrayUsingDescriptors:@[sortDescriptor]];
}

- (Entry *)lastEntry {
    return [[self entriesByDate] lastObject];
}

#pragma mark -

+ (void)updateAllPriorities {
    for (Todo *todo in [Todo all]) {
        [todo updatePriority];
    }
}

+ (void)updateAllUrgenciesFromDueDate {
    NSDate *dateUrgentDaysFromNow = [NSDate dateWithTimeIntervalSinceNow:kSecondsInDay * kUrgentDaysBeforeDueDate];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"dueDate != NULL AND dueDate < %@ AND status = %d", dateUrgentDaysFromNow, TodoStatusNormal];
    NSArray *todos = [Todo allForPredicate:predicate];
    
    for (Todo *todo in todos) {
        [todo updateUrgencyFromDueDate];
    }
    
    [IBCoreDataStore save];
}

+ (void)updateAllStatusesFromHoldDate {
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"holdDate != NULL AND holdDate <= %@", [NSDate today]];
    NSArray *todos = [Todo allForPredicate:predicate];
    
    for (Todo *todo in todos) {
        todo.holdDate = nil;
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

- (EntryType)lastEntryType {
    return [[self primitiveLastEntryType] intValue];
}

- (void)setLastEntryType:(EntryType)lastEntryType {
    self.primitiveLastEntryType = @(lastEntryType);
}

- (Entry *)createEntry:(EntryType)type {
    if (type != EntryTypeCreate) {
        Entry *lastEntry = [self.entriesByDate lastObject];
        lastEntry.status = EntryStatusClosed;
    }
    
    Entry *entry = [Entry create];
    entry.type = type;
    entry.todo = self;
    [self addEntriesObject:entry];
    
    self.lastEntryType = type;
    self.lastEntryDate = entry.timestamp;
    
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
        [self updateAllStatusesFromHoldDate];
        
        [[IBCoreDataStore mainStore] setMetadataObject:today forKey:dailyUpdateKey];
        [[IBCoreDataStore mainStore] save];
    }
}

+ (void)migrate {
    for (Todo *todo in [Todo all]) {
        
    }
    
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
