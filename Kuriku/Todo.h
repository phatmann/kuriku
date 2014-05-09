//
//  Todo.h
//  Kuriku
//
//  Created by Tony Mann on 12/11/13.
//  Copyright (c) 2013 7Actions. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "Entry.h"

@class Journal;

@interface Todo : NSManagedObject

@property (nonatomic, strong) NSString *title;
@property (nonatomic) float_t importance;
@property (nonatomic) float_t priority;
@property (nonatomic, strong) NSDate *createDate;
@property (nonatomic, strong) NSDate *updateDate;
@property (nonatomic, strong) NSDate *dueDate;
@property (nonatomic, strong) NSDate *startDate;
@property (nonatomic, strong) NSString *notes;
@property (nonatomic, strong) NSOrderedSet *entries;
@property (nonatomic, strong) Journal *journal;

@property (nonatomic, weak, readonly) Entry *lastEntry;
@property (nonatomic) float_t urgency;
@property (nonatomic) float_t frostiness;
@property (nonatomic, readonly) float_t staleness;
@property (nonatomic) float_t temperature;

- (Entry *)createEntry:(EntryType)type;

+ (void)updateAllPrioritiesIfNeeded;
+ (void)updateTodosReadyToStart;
+ (void)dailyUpdate;
+ (void)migrate;

float_t urgencyFromDueDate(NSDate *dueDate);
NSDate *dueDateFromUrgency(float_t urgency);
float_t frostinessFromStartDate(NSDate *startDate);
NSDate *startDateFromFrostiness(float_t frostiness);

extern const float_t  TodoImportanceDefaultValue;
extern const float_t  TodoUrgencyDefaultValue;

extern const int TodoPriorityVersion;

extern const NSTimeInterval TodoMinStaleDaysAfterLastEntryDate;
extern const NSTimeInterval TodoMaxStaleDaysAfterLastEntryDate;

extern const float_t TodoColdMaxPriority;
extern const float_t TodoImportanceCommitted;

@end


