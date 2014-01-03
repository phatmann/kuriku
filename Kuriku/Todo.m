//
//  Todo.m
//  Kuriku
//
//  Created by Tony Mann on 12/11/13.
//  Copyright (c) 2013 7Actions. All rights reserved.
//

#import "Todo.h"
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
@dynamic lastEntryType, primitiveLastEntryType;
@dynamic lastEntryDate, primitiveLastEntryDate;
@dynamic repeatDays;
@dynamic priority;
@dynamic star;
@dynamic status;
@dynamic notes;
@dynamic commitment;
@dynamic entries;

- (void)awakeFromInsert {
    [super awakeFromInsert];
    self.createDate = [NSDate date];
}

- (void)willSave {
    if ([self isDeleted])
        return;
    
    if (self.entries.count == 0) {
        [self createEntry:self.isInserted ? EntryTypeCreate : EntryTypeReady];
    }
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

////////////////////////
// TODO: remove these methods once tests are in place
- (NSDate *)lastEntryDate {
    NSDate *lastEntryDate = [self primitiveLastEntryDate];
    
    if (!lastEntryDate) {
        lastEntryDate = self.lastEntry.timestamp;
        self.lastEntryDate = lastEntryDate;
    }
    
    return lastEntryDate;
}

- (EntryType)lastEntryType {
    NSNumber *lastEntryTypeNumber = [self primitiveLastEntryType];
    int lastEntryType;
    
    if (lastEntryTypeNumber) {
        lastEntryType = [lastEntryTypeNumber intValue];
    } else {
        lastEntryType = self.lastEntry.type;
        self.lastEntryType = lastEntryType;
    }
    
    return lastEntryType;
}

- (void)setLastEntryType:(EntryType)lastEntryType {
    self.primitiveLastEntryType = @(lastEntryType);
}
////////////////////////

- (void)createEntry:(EntryType)type {
    if (type != EntryTypeCreate) {
        Entry *lastEntry = [self.entriesByDate lastObject];
        lastEntry.status = EntryStatusClosed;
    }
    
    Entry *entry = [Entry create];
    entry.type = type;
    entry.todo = self;
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
