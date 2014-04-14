//
//  Entry.m
//  Kuriku
//
//  Created by Tony Mann on 12/11/13.
//  Copyright (c) 2013 7Actions. All rights reserved.
//

#import "Entry.h"
#import "Todo.h"
#import "Journal.h"
#import <InnerBand/InnerBand.h>

@interface Entry ()

@end

@implementation Entry
@dynamic priority;
@dynamic journalDateString;
@dynamic timestamp;
@dynamic todo;
@dynamic journal;
@dynamic type;
@dynamic state;
@dynamic startDate;

- (void)awakeFromInsert {
    [super awakeFromInsert];

    self.timestamp = [NSDate date];
    self.journalDate = [self.timestamp dateAtStartOfDay];
    self.journal = [Journal first];
}

- (void)setJournalDate:(NSDate *)date {
    self.journalDateString = [journalDateFormatter() stringFromDate:date];
}

- (NSDate *)journalDate {
    return [Entry journalDateFromString:self.journalDateString];
}

- (void)didChangeValueForKey:(NSString *)key {
    [super didChangeValueForKey:key];
    
    if ([key isEqualToString:@"type"]) {
        switch (self.type) {
            case EntryTypeComplete:
                self.state = EntryStateInactive;
                break;
                
            default:
                self.state = EntryStateActive;
        }
    }
    
    if (![key isEqualToString:@"priority"])
        [self updatePriorityFromTodo];
}

- (void)updatePriorityFromTodo {
    if (self.state == EntryStateInactive || self.type == EntryTypeComplete || self.startDate)
        self.priority = 0;
    else
        self.priority = self.todo.priority;
}

+ (NSDate *)journalDateFromString:(NSString *)journalDateString {
    return [journalDateFormatter() dateFromString:journalDateString];
}

+ (void)migrate {
    for (Entry *entry in [Entry all]) {
        [entry updatePriorityFromTodo];
    }
    
    [IBCoreDataStore save];
}

#pragma mark -

NSDateFormatter* journalDateFormatter() {
    static NSDateFormatter *dateFormatter;
    
    if (!dateFormatter) {
        dateFormatter = [[NSDateFormatter alloc] init];
        dateFormatter.dateFormat = @"yyyy-MM-dd";
    }
    
    return dateFormatter;
}

@end
