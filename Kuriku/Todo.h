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
@property (nonatomic, readonly) float_t staleness;

- (Entry *)createEntry:(EntryType)type;

+ (BOOL)isVolumeLockedForVolume:(float_t)volume;
+ (void)updateAllTodosReadyToStart;
+ (void)dailyUpdate;
+ (void)migrate;

extern const float_t  TodoVolumeDefaultValue;
extern const NSTimeInterval TodoMinStaleDaysAfterLastUpdate;
extern const NSTimeInterval TodoMaxStaleDaysAfterLastUpdate;

extern const float_t TodoFrozenMinVolume;
extern const float_t TodoFrozenMaxVolume;
extern const float_t TodoColdMinVolume;
extern const float_t TodoColdMaxVolume;
extern const float_t TodoNormalMinVolume;
extern const float_t TodoNormalMaxVolume;
extern const float_t TodoHotMinVolume;
extern const float_t TodoHotMaxVolume;

@end


