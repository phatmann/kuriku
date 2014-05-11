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
@property (nonatomic) float_t volume;
@property (nonatomic, strong) Todo *todo;
@property (nonatomic) NSString *journalDateString;
@property (nonatomic, strong) NSDate *createDate;
@property (nonatomic, strong) NSDate *updateDate;
@property (nonatomic, strong) Journal *journal;

@property (nonatomic, readonly) CGFloat progress;
@property (nonatomic) NSDate *journalDate;

+ (NSDate *)journalDateFromString:(NSString *)journalDateString;
+ (CGFloat)normalVolumeFromTodoVolume:(CGFloat)todoVolume;
+ (void)migrate;
- (void)updateVolume;

extern const float_t EntryInactiveVolume;
extern const float_t EntryActiveMinVolume;
extern const float_t EntryCompletedVolume;
extern const float_t EntryNormalMinVolume;

@end

