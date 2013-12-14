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
@dynamic startDate;
@dynamic createDate;
@dynamic star;
@dynamic journal;

- (void)awakeFromInsert {
    [super awakeFromInsert];
    
    self.createDate = [[NSDate date] dateAsMidnight];
    self.journal = [Journal first];
}
    
@end
