//
//  Todo.h
//  Kuriku
//
//  Created by Tony Mann on 12/11/13.
//  Copyright (c) 2013 7Actions. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

typedef enum {
    TodoStatusNormal,
    TodoStatusCompleted,
    TodoStatusCanceled
} TodoStatus;

static const int TodoRangeMaxValue = 4;

static const int  TodoCommitmentDefaultValue = 4;
static const int  TodoImportanceDefaultValue = 2;
static const int  TodoUrgencyDefaultValue    = 0;
static const BOOL TodoCommittedDefaultValue  = YES;

static const int TodoPriorityVersion = 4;

@interface Todo : NSManagedObject

@property (nonatomic, strong) NSString *title;
@property (nonatomic) int16_t importance;
@property (nonatomic) int16_t urgency;
@property (nonatomic) float_t priority;
@property (nonatomic) NSDate *createDate;
@property (nonatomic) NSDate *dueDate;
@property (nonatomic) NSDate *startDate;
@property (nonatomic) NSDate *completionDate;
@property (nonatomic) BOOL star;
@property (nonatomic, strong) NSString *notes;
@property (nonatomic, strong) NSSet *entries;

@property (nonatomic) BOOL completed;
@property (nonatomic) BOOL committed;
@property (nonatomic, readonly) NSDate *lastActionDate;

- (void)createActionEntry;

+ (void)updateAllPriorities;

@end

@interface Todo (CoreDataGeneratedAccessors)

- (void)addEntriesObject:(NSManagedObject *)value;
- (void)removeEntriesObject:(NSManagedObject *)value;
- (void)addEntries:(NSSet *)values;
- (void)removeEntries:(NSSet *)values;

@end


