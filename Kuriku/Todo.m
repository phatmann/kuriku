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
@dynamic entries;

- (void)awakeFromInsert {
    [super awakeFromInsert];
    self.createDate = [NSDate date];
}

- (void)didChangeValueForKey:(NSString *)key {
    [super didChangeValueForKey:key];
    
    if ([key isEqualToString:@"urgency"] || [key isEqualToString:@"importance"]) {
        CGFloat maxValue = TodoImportanceMaxValue + TodoUrgencyMaxValue;
        self.priority = (self.urgency + self.importance) / maxValue;
    }
}

- (void)didChangeValueForKey:(NSString *)inKey withSetMutation:(NSKeyValueSetMutationKind)inMutationKind usingObjects:(NSSet *)inObjects {
    if ([inKey isEqualToString:@"entries"]) {
        _actionEntriesByDate = nil;
    }
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

- (NSDate *)lastActionDate {
    Entry *firstEntry = [self.actionEntriesByDate firstObject];
    return firstEntry.timestamp;
}

@end
