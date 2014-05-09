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

const float_t EntryInactivePriority  = 0;
const float_t EntryActiveMinPriority = 0.1;
const float_t EntryCompletedPriority = 0.2;
const float_t EntryNormalMinPriority = 0.3;
static const float_t EntryNormalPriorityRange = 1.0 - EntryNormalMinPriority;

@implementation Entry
@dynamic priority;
@dynamic journalDateString;
@dynamic createDate;
@dynamic updateDate;
@dynamic todo;
@dynamic journal;
@dynamic type;
@dynamic state;

- (void)awakeFromFetch {
    [super awakeFromFetch];
    [self setUp];
}

- (void)awakeFromInsert {
    [super awakeFromInsert];

    self.createDate = [NSDate date];
    self.updateDate = self.createDate;
    self.journalDate = [self.createDate dateAtStartOfDay];
    self.journal = [Journal first];
    
    [self setUp];
}

- (void)awakeFromSnapshotEvents:(NSSnapshotEventType)flags {
    [super awakeFromSnapshotEvents:flags];
    [self setUp];
}

- (void)willTurnIntoFault {
    [super willTurnIntoFault];
    [self tearDown];
}

- (void)setUp {
    [self addObserver:self forKeyPath:@"todo.priority" options:NSKeyValueObservingOptionInitial context:nil];
    [self addObserver:self forKeyPath:@"state" options:NSKeyValueObservingOptionInitial context:nil];
    [self addObserver:self forKeyPath:@"type" options:NSKeyValueObservingOptionInitial context:nil];
}

- (void)tearDown {
    [self removeObserver:self forKeyPath:@"todo.priority"];
    [self removeObserver:self forKeyPath:@"state"];
    [self removeObserver:self forKeyPath:@"type"];
}

- (void)setJournalDate:(NSDate *)date {
    self.journalDateString = [journalDateFormatter() stringFromDate:date];
}

- (NSDate *)journalDate {
    return [Entry journalDateFromString:self.journalDateString];
}

+ (CGFloat)normalPriorityFromTodoPriority:(CGFloat)todoPriority {
    return fratiof((EntryNormalMinPriority + (EntryNormalPriorityRange * todoPriority)));
}

- (CGFloat)progress {
    // TODO: cache entry progress
    
    if (self.type == EntryTypeComplete)
        return 1.0;
        
    __block NSUInteger startActionIndex = 0;
    __block NSUInteger completedActionIndex = NSNotFound;
    __block NSUInteger thisActionIndex  = NSNotFound;
    
    [self.todo.entries enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        Entry *entry = (Entry *)obj;
        
        if (completedActionIndex != NSNotFound) {
            startActionIndex = idx;
            completedActionIndex = NSNotFound;
        }
        
        if (entry == self) {
            thisActionIndex = idx;
        }
        
        if (entry.type == EntryTypeComplete) {
            completedActionIndex = idx;
            
            if (thisActionIndex != NSNotFound)
                *stop = YES;
        }
    }];
    
    if (completedActionIndex == NSNotFound)
        completedActionIndex = thisActionIndex + 1;
    
    return (float)(thisActionIndex - startActionIndex) / (completedActionIndex - startActionIndex);
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    [self updatePriority];
    self.updateDate = [NSDate date];
}

- (void)updatePriority {
    if (self.state == EntryStateInactive) {
        self.priority = EntryInactivePriority;
    } else if (self.type == EntryTypeComplete) {
        self.priority = EntryCompletedPriority;
    } else {
        self.priority = [Entry normalPriorityFromTodoPriority:self.todo.priority];
    }
}

+ (NSDate *)journalDateFromString:(NSString *)journalDateString {
    return [journalDateFormatter() dateFromString:journalDateString];
}

+ (void)migrate {
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
