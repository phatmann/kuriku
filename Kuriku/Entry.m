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

@implementation Entry

@dynamic title;
@dynamic importance;
@dynamic urgency;
@dynamic dueDate;
@dynamic journalDate;
@dynamic startDate;
@dynamic timestamp;
@dynamic star;
@dynamic journal;

- (void)awakeFromInsert {
    [super awakeFromInsert];
    
    static NSDateFormatter *dateFormatter;
    
    if (!dateFormatter) {
        dateFormatter = [[NSDateFormatter alloc] init];
        dateFormatter.dateStyle = NSDateFormatterShortStyle;
        dateFormatter.timeStyle = NSDateFormatterNoStyle;
    }
    
    self.timestamp = [NSDate date];
    NSDate *dateWithNoTime = [self.timestamp dateAsMidnight];
    self.journalDate = [dateFormatter stringFromDate:dateWithNoTime];
    self.journal = [Journal first];
}
    
@end
