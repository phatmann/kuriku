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
@property (nonatomic) float_t temperature;
@property (nonatomic, strong) NSDate *createDate;
@property (nonatomic, strong) NSDate *updateDate;
@property (nonatomic, strong) NSDate *dueDate;
@property (nonatomic, strong) NSDate *startDate;
@property (nonatomic, strong) NSString *notes;
@property (nonatomic, strong) NSOrderedSet *entries;
@property (nonatomic, strong) Journal *journal;

@property (nonatomic, weak, readonly) Entry *lastEntry;
@property (nonatomic, readonly) float_t staleness;

- (Entry *)createEntry:(EntryType)type;

+ (void)updateAllTodosReadyToStart;
+ (void)dailyUpdate;
+ (void)migrate;

extern const float_t  TodoTemperatureDefaultValue;
extern const NSTimeInterval TodoMinStaleDaysAfterLastUpdate;
extern const NSTimeInterval TodoMaxStaleDaysAfterLastUpdate;

extern const float_t TodoMinTemperature;
extern const float_t TodoFrozenMaxTemperature;
extern const float_t TodoColdMaxTemperature;
extern const float_t TodoNormalMaxTemperature;
extern const float_t TodoMaxTemperature;

@end


