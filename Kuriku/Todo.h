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

typedef enum {
    TodoCommitmentMaybe = 0,
    TodoCommitmentMust = 2,
    TodoCommitmentToday = 4
} TodoCommitment;

static const int TodoRangeMaxValue = 4;

static const int  TodoCommitmentDefaultValue = 2;
static const int  TodoImportanceDefaultValue = 2;
static const int  TodoUrgencyDefaultValue    = 0;

static const int TodoPriorityVersion = 5;

@interface Todo : NSManagedObject

@property (nonatomic, strong) NSString *title;
@property (nonatomic) int16_t importance;
@property (nonatomic) int16_t urgency;
@property (nonatomic) float_t priority;
@property (nonatomic, strong) NSDate *createDate;
@property (nonatomic, strong) NSDate *dueDate;
@property (nonatomic, strong) NSString *notes;
@property (nonatomic) int16_t commitment;
@property (nonatomic, strong) NSSet *entries;
@property (nonatomic, strong) Journal *journal;

@property (nonatomic, strong, readonly) NSArray *entriesByDate;

- (Entry *)createEntry:(EntryType)type;
- (Entry *)lastEntry;

+ (int)urgencyFromDueDate:(NSDate *)dueDate;
+ (void)updateAllPrioritiesIfNeeded;
+ (void)dailyUpdate;
+ (void)migrate;

@end

@interface Todo (CoreDataGeneratedAccessors)

- (void)addEntriesObject:(NSManagedObject *)value;
- (void)removeEntriesObject:(NSManagedObject *)value;
- (void)addEntries:(NSSet *)values;
- (void)removeEntries:(NSSet *)values;

@end


