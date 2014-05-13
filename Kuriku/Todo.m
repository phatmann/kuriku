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


const NSTimeInterval TodoUrgentDaysBeforeDueDate   = 14;
const NSTimeInterval TodoFrostyDaysBeforeStartDate = 60;

const NSTimeInterval TodoMaxStaleDaysAfterLastUpdate = 60;
const NSTimeInterval TodoMinStaleDaysAfterLastUpdate = 14;

const float_t TodoMinTemperature       = 0;
const float_t TodoFrozenMaxTemperature = 25;
const float_t TodoColdMaxTemperature   = 50;
const float_t TodoNormalMaxTemperature = 75;
const float_t TodoMaxTemperature       = 100;

const float_t TodoTemperatureDefaultValue = TodoColdMaxTemperature + 1;

static NSString *TodoTemperatureUpdatedOnKey = @"TodoTemperatureUpdatedOn";

@implementation Todo

@dynamic title;
@dynamic temperature;
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
    self.temperature = TodoTemperatureDefaultValue;
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
    [self addObserver:self forKeyPath:@"temperature" options:NSKeyValueObservingOptionInitial context:nil];
    [self addObserver:self forKeyPath:@"urgency" options:NSKeyValueObservingOptionInitial context:nil];
    [self addObserver:self forKeyPath:@"dueDate" options:NSKeyValueObservingOptionInitial context:nil];
    [self addObserver:self forKeyPath:@"startDate" options:NSKeyValueObservingOptionInitial context:nil];
    [self addObserver:self forKeyPath:@"entries" options:NSKeyValueObservingOptionOld context:nil];
}

- (void)tearDown {
    [self removeObserver:self forKeyPath:@"temperature"];
    [self removeObserver:self forKeyPath:@"urgency"];
    [self removeObserver:self forKeyPath:@"dueDate"];
    [self removeObserver:self forKeyPath:@"startDate"];
    [self removeObserver:self forKeyPath:@"entries"];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    self.updateDate = [NSDate date];
    int kind = [change[NSKeyValueChangeKindKey] intValue];
    
    if ([keyPath isEqualToString:@"entries"]) {
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

- (int)daysSinceLastUpdate {
    return -[self.updateDate daysFromToday];
}

#pragma mark -

+ (BOOL)isTemperatureLockedForTemperature:(float_t)temperature {
    return temperature <= TodoFrozenMaxTemperature;
}

+ (void)tickTemperatureForAllTodos:(NSDate *)updatedOn {
    // TODO: filter non-stale todos out
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"temperature > %f && temperature < 100", TodoFrozenMaxTemperature];
    
    NSArray *todos = [Todo allForPredicate:predicate];
    int daysSinceUpdate = -[updatedOn daysFromToday];
    
    for (Todo *todo in todos) {
        if (todo.lastEntry.type != EntryTypeComplete) {
            float_t tick = 0;
            float_t max = TodoMaxTemperature;
            
            if (todo.temperature <= TodoColdMaxTemperature) {
                tick = (TodoColdMaxTemperature - TodoFrozenMaxTemperature) / TodoFrostyDaysBeforeStartDate;
                max = TodoColdMaxTemperature;
            } else if (todo.temperature <= TodoNormalMaxTemperature) {
                if ([todo daysSinceLastUpdate] >= TodoMinStaleDaysAfterLastUpdate) {
                    tick = (TodoNormalMaxTemperature - TodoColdMaxTemperature) / TodoMaxStaleDaysAfterLastUpdate;
                    max = TodoNormalMaxTemperature;
                }
            } else {
                tick = (TodoMaxTemperature - TodoNormalMaxTemperature) / TodoUrgentDaysBeforeDueDate;
            }
        
            float_t delta = daysSinceUpdate * tick;
            todo.temperature = fclampf(todo.temperature + delta, TodoMinTemperature, max);
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
    return [[IBCoreDataStore mainStore] metadataObjectForKey:TodoTemperatureUpdatedOnKey];
}

+ (void)setDailyUpdatedOn:(NSDate *)date {
    [[IBCoreDataStore mainStore] setMetadataObject:date forKey:TodoTemperatureUpdatedOnKey];
    [[IBCoreDataStore mainStore] save];
}

+ (void)dailyUpdate {
    NSDate *updatedOn = [self dailyUpdatedOn];
    NSDate *today     = [NSDate today];
    
    if (updatedOn || ![updatedOn isSameDay:today]) {
        [self tickTemperatureForAllTodos:updatedOn];
        [self updateAllTodosReadyToStart];
        [self setDailyUpdatedOn:today];
    }
}

+ (void)migrate {
    [IBCoreDataStore save];
}

@end
