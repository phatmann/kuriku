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
@property (nonatomic) int16_t status;
@end

static const NSTimeInterval kUrgentDaysBeforeDueDate = 14;
static const NSTimeInterval kSecondsInDay = 24 * 60 * 60;

@implementation Todo

@dynamic title;
@dynamic importance;
@dynamic urgency;
@dynamic createDate;
@dynamic dueDate;
@dynamic startDate;
@dynamic completionDate;
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
    
    [self createEntry:EntryTypeCreateTodo];
}

- (void)didChangeValueForKey:(NSString *)key {
    [super didChangeValueForKey:key];
    
    if ([key isEqualToString:@"urgency"] || [key isEqualToString:@"importance"] || [key isEqualToString:@"commitment"]) {
        [self updatePriority];
    } else if ([key isEqualToString:@"status"]) {
        [self createEntry:(self.status == TodoStatusCompleted) ? EntryTypeCompleteTodo : EntryTypeContinueTodo];
    } else if ([key isEqualToString:@"dueDate"]) {
        if (self.dueDate) {
            [self updateUrgencyFromDueDate];
        } else {
            self.urgency = 0;
        }
    }
}

- (BOOL)completed {
    return self.status != TodoStatusNormal;
}

- (void)setCompleted:(BOOL)completed {
    if (completed) {
        if (self.repeatDays == 0) {
            [self createEntry:EntryTypeCompleteTodo];
        } else {
            self.status = TodoStatusCompleted;
            self.completionDate = [NSDate date];
            
            if (self.repeatDays > 0) {
                self.startDate = [[[NSDate date] dateByAddingDays:self.repeatDays] dateAtStartOfDay];
            }
        }
    } else {
        self.status = TodoStatusNormal;
        self.completionDate = nil;
    }
}

- (NSArray *)entriesByDate {
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"timestamp" ascending:YES];
    return [self.entries sortedArrayUsingDescriptors:@[sortDescriptor]];
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

// TODO: remove this method when all data is migrated
- (NSDate *)lastEntryDate {
    NSDate *lastEntryDate = [self primitiveLastEntryDate];
    
    if (!lastEntryDate) {
        if (self.completionDate)
            lastEntryDate = self.completionDate;
        else
            lastEntryDate = self.createDate;
        
        self.lastEntryDate = lastEntryDate;
    }
    
    return lastEntryDate;
}

- (void)createEntry:(EntryType)type {
    if (type != EntryTypeCreateTodo) {
        Entry *lastEntry = [self.entriesByDate lastObject];
        lastEntry.status = EntryStatusInactive;
    }
    
    Entry *entry = [Entry create];
    entry.todo = self;
    entry.type = type;
    
    if  (type == EntryTypeCompleteTodo) {
        entry.status = EntryStatusInactive;
    }
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

    if (!updateDate || abs([updateDate timeIntervalSinceNow]) > kSecondsInDay) {
        [self updateAllUrgenciesFromDueDate];
        
        [[IBCoreDataStore mainStore] setMetadataObject:[NSDate date] forKey:dailyUpdateKey];
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
