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

const float_t  TodoVolumeDefaultValue     = 0.5f;
const float_t  TodoUrgencyDefaultValue    = 0.0f;

const int TodoVolumeVersion = 15;
const NSTimeInterval TodoUrgentDaysBeforeDueDate   = 14;
const NSTimeInterval TodoFrostyDaysBeforeStartDate = 60;

const NSTimeInterval TodoMaxStaleDaysAfterLastUpdate = 60;
const NSTimeInterval TodoMinStaleDaysAfterLastUpdate = 14;

const float_t TodoColdMaxVolume = 0.5;
static const float_t TodoVolumeLockMax = 0.25;

static NSString *TodoVolumeUpdatedOnKey = @"TodoVolumeUpdatedOn";

@implementation Todo

@dynamic title;
@dynamic volume;
@dynamic volumeLocked;
@dynamic createDate;
@dynamic updateDate;
@dynamic dueDate;
@dynamic startDate;
@dynamic notes;
@dynamic entries;
@dynamic journal;

- (void)awakeFromInsert {
    [super awakeFromInsert];
    self.createDate = [NSDate date];
    self.updateDate = self.createDate;
    self.volume = TodoVolumeDefaultValue;
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
    [self addObserver:self forKeyPath:@"volume" options:NSKeyValueObservingOptionInitial context:nil];
    [self addObserver:self forKeyPath:@"urgency" options:NSKeyValueObservingOptionInitial context:nil];
    [self addObserver:self forKeyPath:@"dueDate" options:NSKeyValueObservingOptionInitial context:nil];
    [self addObserver:self forKeyPath:@"startDate" options:NSKeyValueObservingOptionInitial context:nil];
    [self addObserver:self forKeyPath:@"entries" options:NSKeyValueObservingOptionOld context:nil];
}

- (void)tearDown {
    [self removeObserver:self forKeyPath:@"volume"];
    [self removeObserver:self forKeyPath:@"urgency"];
    [self removeObserver:self forKeyPath:@"dueDate"];
    [self removeObserver:self forKeyPath:@"startDate"];
    [self removeObserver:self forKeyPath:@"entries"];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    self.updateDate = [NSDate date];
    int kind = [change[NSKeyValueChangeKindKey] intValue];
    
    if ([keyPath isEqualToString:@"volume"]) {
        self.volumeLocked = [Todo isVolumeLockedForVolume:self.volume];
    } else if (!self.volumeLocked && ([keyPath isEqualToString:@"dueDate"] || [keyPath isEqualToString:@"startDate"])) {
        [self updateVolume];
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
    return [NSSet setWithObjects:@"urgency", @"staleness", @"frostiness", nil];
}

- (Entry *)lastEntry {
    return [self.entries lastObject];
}

- (float_t)staleness {
    //return arc4random_uniform(100) / 100.0;
    
    int daysSinceLastUpdate = [self daysSinceLastUpdate];
    
    if (daysSinceLastUpdate < TodoMinStaleDaysAfterLastUpdate) {
        return 0.0f;
    } else if (daysSinceLastUpdate >= TodoMaxStaleDaysAfterLastUpdate) {
        return 1.0f;
    } else {
        return 1.0f - ((TodoMaxStaleDaysAfterLastUpdate - daysSinceLastUpdate) / TodoMaxStaleDaysAfterLastUpdate);
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
    
    return 0;
}

- (int)daysSinceLastUpdate {
    return -[self.updateDate daysFromToday];
}

#pragma mark -

+ (BOOL)isVolumeLockedForVolume:(float_t)volume {
    return volume < TodoVolumeLockMax;
}

float_t urgencyFromDueDate(NSDate *dueDate) {
    if (!dueDate)
        return 0;
        
    return (TodoUrgentDaysBeforeDueDate - [dueDate daysFromToday]) / TodoUrgentDaysBeforeDueDate;
}

NSDate *dueDateFromUrgency(float_t urgency) {
    if (urgency == 0) {
        return nil;
    } else {
        int daysUntilDue = roundf(TodoUrgentDaysBeforeDueDate - (urgency * TodoUrgentDaysBeforeDueDate));
        return [[NSDate today] dateByAddingDays:daysUntilDue];
    }
}

float_t frostinessFromStartDate(NSDate *startDate) {
    if (!startDate)
        return 0;

    return 1.0f - (TodoFrostyDaysBeforeStartDate - [startDate daysFromToday]) / TodoFrostyDaysBeforeStartDate;
}

NSDate *startDateFromFrostiness(float_t frostiness) {
    if (frostiness == 0) {
        return nil;
    } else {
        int daysUntilThawed = roundf(frostiness * TodoFrostyDaysBeforeStartDate);
        return [[NSDate today] dateByAddingDays:daysUntilThawed];
    }
}

+ (void)updateVolumeForAllTodos {
    for (Todo *todo in [Todo all]) {
        [todo updateVolume];
    }
    
    for (Entry *entry in [Entry all]) {
        [entry updateVolume];
    }
}

+ (void)tickVolumeForAllTodos:(NSDate *)updatedOn {
    static const CGFloat tick = (1.0 - TodoColdMaxVolume) / TodoUrgentDaysBeforeDueDate;
    
    
    // TODO: filter frozen and non-stale todos out
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"volume < 1.0"];
    
    //NSDate *dateUrgentDaysFromNow = [NSDate dateFromTodayWithDays:TodoUrgentDaysBeforeDueDate];
    //NSPredicate *predicate = [NSPredicate predicateWithFormat:@"dueDate != NULL AND dueDate < %@ AND volume < 1.0", dateUrgentDaysFromNow];
    
    NSArray *todos = [Todo allForPredicate:predicate];
    CGFloat daysSinceUpdate = [updatedOn daysFromToday];
    CGFloat delta = -daysSinceUpdate * tick;
    
    for (Todo *todo in todos) {
        if (todo.lastEntry.type != EntryTypeComplete) {
            if (todo.urgency > 0.0f || todo.frostiness > 0.0f ||
                [todo daysSinceLastUpdate] >= TodoMinStaleDaysAfterLastUpdate) {
                todo.volume = fratiof(todo.volume + delta);
            }
        }
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

+ (void)updateVolumeForAllTodosIfNeeded {
    static NSString *priorityVersionKey = @"TodoVolumeVersion";
    
    int priorityVersion = [[[IBCoreDataStore mainStore] metadataObjectForKey:priorityVersionKey] intValue];
    
    if (priorityVersion < TodoVolumeVersion) {
        [self updateVolumeForAllTodos];
        
        [[IBCoreDataStore mainStore] setMetadataObject:@(TodoVolumeVersion) forKey:priorityVersionKey];
        [[IBCoreDataStore mainStore] save];
    }
}

+ (void)updateAllTodosReadyToStart {
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

+ (NSDate *)dailyUpdatedOn {
    return [[IBCoreDataStore mainStore] metadataObjectForKey:TodoVolumeUpdatedOnKey];
}

+ (void)setDailyUpdatedOn:(NSDate *)date {
    [[IBCoreDataStore mainStore] setMetadataObject:date forKey:TodoVolumeUpdatedOnKey];
    [[IBCoreDataStore mainStore] save];
}

+ (void)dailyUpdate {
    NSDate *updatedOn = [self dailyUpdatedOn];
    NSDate *today     = [NSDate today];
    
    if (updatedOn || ![updatedOn isSameDay:today]) {
        [self tickVolumeForAllTodos:updatedOn];
        [self updateAllTodosReadyToStart];
        [self setDailyUpdatedOn:today];
    }
}

+ (void)migrate {
    [IBCoreDataStore save];
}

#pragma mark - Private

- (void)updateVolume {
    CGFloat temperature = self.temperature;
    CGFloat volume;
    
    if (temperature < 0) {
        volume = TodoVolumeLockMax + ((TodoColdMaxVolume - TodoVolumeLockMax) * (1.0 + temperature));
    } else if (temperature > 0) {
        volume = TodoColdMaxVolume + ((1.0 - TodoColdMaxVolume) * temperature);
    } else {
        volume = TodoColdMaxVolume + ((1.0 - TodoColdMaxVolume) * self.staleness);
    }
    
    self.volume = fratiof(volume);
}

@end
