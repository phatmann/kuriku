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
        static const int maxValue = 10;
        self.priority = (self.urgency + self.importance) / (maxValue * 2.0f);
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
