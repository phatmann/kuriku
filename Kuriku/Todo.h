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

static const float_t  TodoImportanceDefaultValue = 0.5f;
static const float_t  TodoUrgencyDefaultValue    = 0.0f;

static const int TodoPriorityVersion = 6;

@interface Todo : NSManagedObject

@property (nonatomic, strong) NSString *title;
@property (nonatomic) float_t importance;
@property (nonatomic) float_t priority;
@property (nonatomic, strong) NSDate *createDate;
@property (nonatomic, strong) NSDate *dueDate;
@property (nonatomic, strong) NSDate *startDate;
@property (nonatomic, strong) NSString *notes;
@property (nonatomic, strong) NSOrderedSet *entries;
@property (nonatomic, strong) Journal *journal;

@property (nonatomic, weak, readonly) Entry *lastEntry;
@property (nonatomic) float_t urgency;
@property (nonatomic) float_t frostiness;
@property (nonatomic, readonly) float_t staleness;
@property (nonatomic, readonly) float_t temperature;

- (Entry *)createEntry:(EntryType)type;

+ (void)updateAllPrioritiesIfNeeded;
+ (void)updateTodosReadyToStart;
+ (void)dailyUpdate;
+ (void)migrate;

float_t urgencyFromDueDate(NSDate *dueDate);
NSDate *dueDateFromUrgency(float_t urgency);
float_t frostinessFromStartDate(NSDate *startDate);
NSDate *startDateFromFrostiness(float_t frostiness);

extern const NSTimeInterval kUrgentDaysBeforeDueDate;
extern const NSTimeInterval kMinStaleDaysAfterLastEntryDate;
extern const NSTimeInterval kMaxStaleDaysAfterLastEntryDate;
extern const NSTimeInterval kFrostyDaysBeforeStartDate;

@end


