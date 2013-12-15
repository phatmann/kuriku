//
//  Entry.h
//  Kuriku
//
//  Created by Tony Mann on 12/11/13.
//  Copyright (c) 2013 7Actions. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Journal;

@interface Entry : NSManagedObject

@property (nonatomic, strong) NSString *title;
@property (nonatomic) int16_t importance;
@property (nonatomic) int16_t urgency;
@property (nonatomic) float_t priority;
@property (nonatomic) NSDate *dueDate;
@property (nonatomic) NSDate *startDate;
@property (nonatomic) NSString *journalDateString;
@property (nonatomic, strong) NSDate *timestamp;
@property (nonatomic) BOOL star;
@property (nonatomic, strong) Journal *journal;

@property (nonatomic) NSDate *journalDate;

+ (NSDate *)journalDateFromString:(NSString *)journalDateString;

@end
