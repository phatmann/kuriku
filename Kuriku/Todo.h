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

static const int TodoImportanceDefaultValue = 5;
static const int TodoUrgencyDefaultValue    = 0;

@interface Todo : NSManagedObject

@property (nonatomic, strong) NSString *title;
@property (nonatomic) int16_t importance;
@property (nonatomic) int16_t urgency;
@property (nonatomic) float_t priority;
@property (nonatomic) NSDate *createDate;
@property (nonatomic) NSDate *dueDate;
@property (nonatomic) NSDate *startDate;
@property (nonatomic) BOOL star;
@property (nonatomic) int16_t status;
@property (nonatomic, strong) NSSet *entries;

@property (nonatomic, readonly) NSDate *lastActionDate;

@end

@interface Todo (CoreDataGeneratedAccessors)

- (void)addEntriesObject:(NSManagedObject *)value;
- (void)removeEntriesObject:(NSManagedObject *)value;
- (void)addEntries:(NSSet *)values;
- (void)removeEntries:(NSSet *)values;

@end


