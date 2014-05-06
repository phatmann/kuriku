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
#import "NSDate+Kuriku.h"

const float_t  TodoImportanceDefaultValue = 0.5f;
const float_t  TodoUrgencyDefaultValue    = 0.0f;

const int TodoPriorityVersion = 9;
const NSTimeInterval kUrgentDaysBeforeDueDate   = 14;
const NSTimeInterval kFrostyDaysBeforeStartDate = 60;

const NSTimeInterval kMaxStaleDaysAfterLastEntryDate = 60;
const NSTimeInterval kMinStaleDaysAfterLastEntryDate = 7;

const float_t TodoWarmMinPriority = 0.9;
const float_t TodoColdMaxPriority = 1.0 - TodoWarmMinPriority;

@implementation Todo

@dynamic title;
@dynamic importance;
@dynamic createDate;
@dynamic dueDate;
@dynamic startDate;
@dynamic priority;
@dynamic notes;
@dynamic entries;
@dynamic journal;

- (void)awakeFromInsert {
    [super awakeFromInsert];
    self.createDate = [NSDate date];
    [self createEntry:EntryTypeNew];
    self.journal = [Journal first];
    [self setUp];
}

- (void)awakeFromFetch {
    [super awakeFromFetch];
    [self setUp];
}

- (void)awakeFromSnapshotEvents:(NSSnapshotEventType)flags {
   [super awakeFromSnapshotEvents:flags];
   [self setUp];
}

- (void)willTurnIntoFault {
    [super willTurnIntoFault];
    [self tearDown];
}

- (void)setUp {
    [self addObserver:self forKeyPath:@"importance" options:NSKeyValueObservingOptionInitial context:nil];
    [self addObserver:self forKeyPath:@"urgency" options:NSKeyValueObservingOptionInitial context:nil];
    [self addObserver:self forKeyPath:@"dueDate" options:NSKeyValueObservingOptionInitial context:nil];
    [self addObserver:self forKeyPath:@"startDate" options:NSKeyValueObservingOptionInitial context:nil];
    [self addObserver:self forKeyPath:@"entries" options:NSKeyValueObservingOptionOld context:nil];
}

- (void)tearDown {
    [self removeObserver:self forKeyPath:@"importance"];
    [self removeObserver:self forKeyPath:@"urgency"];
    [self removeObserver:self forKeyPath:@"dueDate"];
    [self removeObserver:self forKeyPath:@"startDate"];
    [self removeObserver:self forKeyPath:@"entries"];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    int kind = [change[NSKeyValueChangeKindKey] intValue];
    
    if ([keyPath isEqualToString:@"dueDate"] || [keyPath isEqualToString:@"startDate"] || [keyPath isEqualToString:@"importance"]) {
        [self updatePriority];
    } else if ([keyPath isEqualToString:@"entries"]) {
        if (kind == NSKeyValueChangeRemoval) {
            NSArray *removedEntries = change[NSKeyValueChangeOldKey];
            
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
        
        if (self.lastEntry.type == EntryTypeComplete)
            self.startDate = nil;
    }
}

+ (NSSet *)keyPathsForValuesAffectingUrgency {
    return [NSSet setWithObjects:@"dueDate", nil];
}

+ (NSSet *)keyPathsForValuesAffectingTemperature {
    return [NSSet setWithObjects:@"urgency", @"staleness", @"frostiness", @"importance", nil];
}

- (Entry *)lastEntry {
    return [self.entries lastObject];
}

- (float_t)staleness {
    //return arc4random_uniform(100) / 100.0;
    
    if (!self.lastEntry)
        return 0.0f;
    
    int daysAfterLastEntryDate = -[self.lastEntry.timestamp daysFromToday];
    
    if (daysAfterLastEntryDate < kMinStaleDaysAfterLastEntryDate) {
        return 0.0f;
    } else if (daysAfterLastEntryDate >= kMaxStaleDaysAfterLastEntryDate) {
        return 1.0f;
    } else {
        return 1.0f - ((kMaxStaleDaysAfterLastEntryDate - daysAfterLastEntryDate) / kMaxStaleDaysAfterLastEntryDate);
    }
}

- (float_t)frostiness {
    return frostinessFromStartDate(self.startDate);
}

- (void)setFrostiness:(float_t)frostiness {
    self.startDate = startDateFromFrostiness(frostiness);
}

- (float_t)urgency {
    return urgencyFromDueDate(self.dueDate);
}

- (void)setUrgency:(float_t)urgency {
    self.dueDate = dueDateFromUrgency(urgency);
}

- (void)setTemperature:(float_t)temperature {
    if (temperature == 0) {
        self.startDate = nil;
        self.dueDate = nil;
    } if (temperature > 0) {
        self.startDate = nil;
        self.urgency = temperature;
    } else {
        self.dueDate = nil;
        self.frostiness = -temperature;
    }
}

- (float_t)temperature {
    if (self.startDate)
        return -fratiof(self.frostiness);

    if (self.dueDate)
        return fratiof(self.urgency);
    
    return self.staleness * self.importance;
}

#pragma mark -

float_t urgencyFromDueDate(NSDate *dueDate) {
    if (!dueDate)
        return 0;
        
    return (kUrgentDaysBeforeDueDate - [dueDate daysFromToday]) / kUrgentDaysBeforeDueDate;
}

NSDate *dueDateFromUrgency(float_t urgency) {
    if (urgency == 0) {
        return nil;
    } else {
        int daysUntilDue = roundf(kUrgentDaysBeforeDueDate - (urgency * kUrgentDaysBeforeDueDate));
        return [[NSDate today] dateByAddingDays:daysUntilDue];
    }
}

float_t frostinessFromStartDate(NSDate *startDate) {
    if (!startDate)
        return 0;

    return 1.0f - (kFrostyDaysBeforeStartDate - [startDate daysFromToday]) / kFrostyDaysBeforeStartDate;
}

NSDate *startDateFromFrostiness(float_t frostiness) {
    if (frostiness == 0) {
        return nil;
    } else {
        int daysUntilThawed = roundf(frostiness * kFrostyDaysBeforeStartDate);
        return [[NSDate today] dateByAddingDays:daysUntilThawed];
    }
}

+ (void)updateAllPriorities {
    for (Todo *todo in [Todo all]) {
        [todo updatePriority];
    }
    
    for (Entry *entry in [Entry all]) {
        [entry updatePriority];
    }
}

+ (void)updatePrioritiesFromDueDate {
    NSDate *dateUrgentDaysFromNow = [NSDate dateFromTodayWithDays:kUrgentDaysBeforeDueDate];
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
    CGFloat priority = 0;
    
    if (!self.startDate)
        priority += TodoWarmMinPriority;
    
    priority += (self.importance * (TodoColdMaxPriority / 2)) + (self.temperature * (TodoColdMaxPriority / 2));
    self.priority = fratiof(priority);
}

@end
