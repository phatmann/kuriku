//
//  Entry.m
//  Kuriku
//
//  Created by Tony Mann on 12/11/13.
//  Copyright (c) 2013 7Actions. All rights reserved.
//

#import "Entry.h"
#import "Journal.h"
#import <InnerBand/InnerBand.h>

@interface Entry ()

@end

@implementation Entry

@dynamic title;
@dynamic journalDateString;
@dynamic timestamp;
@dynamic journal;

- (void)awakeFromInsert {
    [super awakeFromInsert];

    self.timestamp = [NSDate date];
    self.journalDate = [self.timestamp dateAsMidnight];
    self.journal = [Journal first];
}

- (void)setJournalDate:(NSDate *)date {
    self.journalDateString = [journalDateFormatter() stringFromDate:date];
}

- (NSDate *)journalDate {
    return [Entry journalDateFromString:self.journalDateString];
}

+ (NSDate *)journalDateFromString:(NSString *)journalDateString {
    return [journalDateFormatter() dateFromString:journalDateString];
}

#pragma mark -

NSDateFormatter* journalDateFormatter() {
    static NSDateFormatter *dateFormatter;
    
    if (!dateFormatter) {
        dateFormatter = [[NSDateFormatter alloc] init];
        dateFormatter.dateStyle = NSDateFormatterShortStyle;
        dateFormatter.timeStyle = NSDateFormatterNoStyle;
    }
    
    return dateFormatter;
}

@end
