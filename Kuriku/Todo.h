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
@property (nonatomic) float_t volume;
@property (nonatomic) BOOL volumeLocked;
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

+ (void)updateVolumeForAllTodosIfNeeded;
+ (void)updateAllTodosReadyToStart;
+ (void)dailyUpdate;
+ (void)migrate;

float_t urgencyFromDueDate(NSDate *dueDate);
NSDate *dueDateFromUrgency(float_t urgency);
float_t frostinessFromStartDate(NSDate *startDate);
NSDate *startDateFromFrostiness(float_t frostiness);

extern const float_t  TodoVolumeDefaultValue;
extern const float_t  TodoUrgencyDefaultValue;

extern const int TodoVolumeVersion;

extern const NSTimeInterval TodoMinStaleDaysAfterLastEntryDate;
extern const NSTimeInterval TodoMaxStaleDaysAfterLastEntryDate;

extern const float_t TodoColdMaxVolume;
extern const float_t TodoVolumeLockMax;

@end


