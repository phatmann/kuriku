//
//  Todo.m
//  Kuriku
//
//  Created by Tony Mann on 12/11/13.
//  Copyright (c) 2013 7Actions. All rights reserved.
//

#import "Todo.h"
#import "Entry.h"
#import <InnerBand/InnerBand.h>

@interface Todo ()
@property (nonatomic) int16_t commitment;
@end

@implementation Todo
{
    NSArray *_actionEntriesByDate;
}

@dynamic title;
@dynamic importance;
@dynamic urgency;
@dynamic createDate;
@dynamic dueDate;
@dynamic startDate;
@dynamic priority;
@dynamic star;
@dynamic status;
@dynamic notes;
@dynamic entries;
@dynamic commitment;

- (void)awakeFromInsert {
    [super awakeFromInsert];
    self.createDate = [NSDate date];
    
    Entry *entry = [Entry create];
    entry.todo = self;
    entry.type = EntryTypeCreateTodo;
}

- (void)didChangeValueForKey:(NSString *)key {
    [super didChangeValueForKey:key];
    
    if ([key isEqualToString:@"urgency"] || [key isEqualToString:@"importance"] || [key isEqualToString:@"commitment"]) {
        [self updatePriority];
    } else if ([key isEqualToString:@"status"]) {
        [self updatePriority];
        Entry *entry = [Entry create];
        entry.todo = self;
        entry.type = (self.status == TodoStatusCompleted) ? EntryTypeCompleteTodo : EntryTypeContinueTodo;
    }
}

- (void)didChangeValueForKey:(NSString *)inKey withSetMutation:(NSKeyValueSetMutationKind)inMutationKind usingObjects:(NSSet *)inObjects {
    if ([inKey isEqualToString:@"entries"]) {
        _actionEntriesByDate = nil;
    }
}

- (BOOL)committed {
    return self.commitment > 0;
}

- (void)setCommitted:(BOOL)committed {
    self.commitment = committed ? TodoRangeMaxValue : 0;
}

- (BOOL)completed {
    return self.status != TodoStatusNormal;
}

- (void)setCompleted:(BOOL)completed {
    self.status = completed ? TodoStatusCompleted : TodoStatusNormal;
}

#pragma mark -

+ (void)updateAllPriorities {
    for (Todo *todo in [Todo all]) {
        [todo updatePriority];
    }
}

- (NSDate *)lastActionDate {
    Entry *firstEntry = [self.actionEntriesByDate firstObject];
    return firstEntry.timestamp;
}

#pragma mark -

- (void)createActionEntry {
    Entry *entry = [Entry create];
    entry.todo = self;
    entry.type = EntryTypeTakeAction;
}

#pragma mark -

- (void)updatePriority {
    CGFloat maxValue = TodoRangeMaxValue * 2;
    self.priority = (self.urgency + self.importance) / maxValue;
    
    if (self.committed)
        self.priority += maxValue + 1;
    
    if (self.status != TodoStatusNormal)
        self.priority -= 100;
}

- (NSArray *)actionEntriesByDate {
    if (!_actionEntriesByDate) {
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"type=%d", EntryTypeTakeAction];
        NSSet *actionEntries = [self.entries filteredSetUsingPredicate:predicate];
        NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"timestamp" ascending:NO];
        _actionEntriesByDate = [actionEntries sortedArrayUsingDescriptors:@[sortDescriptor]];
    }
    
    return _actionEntriesByDate;
}

@end
