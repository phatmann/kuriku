//
//  Entry.h
//  Kuriku
//
//  Created by Tony Mann on 12/11/13.
//  Copyright (c) 2013 7Actions. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Journal, Todo;

typedef enum {
    EntryTypeNew,
    EntryTypeAction,
    EntryTypeComplete,
    EntryTypeReady
} EntryType;

typedef enum {
    EntryStateActive,
    EntryStateInactive
} EntryState;

@interface Entry : NSManagedObject

@property (nonatomic) int16_t type;
@property (nonatomic) int16_t state;
@property (nonatomic) float_t priority;
@property (nonatomic, strong) Todo *todo;
@property (nonatomic) NSString *journalDateString;
@property (nonatomic, strong) NSDate *timestamp;
@property (nonatomic, strong) Journal *journal;

@property (nonatomic) NSDate *journalDate;

+ (NSDate *)journalDateFromString:(NSString *)journalDateString;
+ (void)migrate;

@end
