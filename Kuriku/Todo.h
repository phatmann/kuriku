//
//  Todo.h
//  Kuriku
//
//  Created by Tony Mann on 12/11/13.
//  Copyright (c) 2013 7Actions. All rights reserved.
//

#import "Entry.h"

typedef enum {
    TodoStatusNormal,
    TodoStatusCompleted,
    TodoStatusCanceled
} TodoStatus;

static const int TodoImportanceDefaultValue = 5;
static const int TodoUrgencyDefaultValue    = 0;

@interface Todo : Entry

@property (nonatomic) int16_t importance;
@property (nonatomic) int16_t urgency;
@property (nonatomic) float_t priority;
@property (nonatomic) NSDate *dueDate;
@property (nonatomic) NSDate *startDate;
@property (nonatomic) BOOL star;
@property (nonatomic) int16_t status;
@property (nonatomic, strong) NSSet *actions;

@end

@interface Todo (CoreDataGeneratedAccessors)

- (void)addActionsObject:(NSManagedObject *)value;
- (void)removeActionsObject:(NSManagedObject *)value;
- (void)addActions:(NSSet *)values;
- (void)removeActions:(NSSet *)values;

@end


