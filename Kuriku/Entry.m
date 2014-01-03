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

@dynamic journalDateString;
@dynamic timestamp;
@dynamic todo;
@dynamic journal;
@dynamic type;
@dynamic status;

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
    
    if ([key isEqualToString:@"todo"]) {
        self.todo.lastEntryDate = self.timestamp;
        self.todo.lastEntryType = self.type;
    } else if ([key isEqualToString:@"type"]) {
        switch (self.type) {
            case EntryTypeComplete:
                self.status = EntryStatusClosed;
                break;
                
            case EntryTypeHold:
                self.status = EntryStatusHold;
                break;
                
            default:
                self.status = EntryStatusOpen;
        }
    }
}

+ (NSDate *)journalDateFromString:(NSString *)journalDateString {
    return [journalDateFormatter() dateFromString:journalDateString];
}

#pragma mark -

NSDateFormatter* journalDateFormatter() {
    static NSDateFormatter *dateFormatter;
    
    if (!dateFormatter) {
        dateFormatter = [[NSDateFormatter alloc] init];
        dateFormatter.dateFormat = @"yyyy-mm-dd";
    }
    
    return dateFormatter;
}

@end
