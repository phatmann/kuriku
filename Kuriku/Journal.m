//
//  Journal.m
//  Kuriku
//
//  Created by Tony Mann on 12/11/13.
//  Copyright (c) 2013 7Actions. All rights reserved.
//

#import "Journal.h"
#import "Entry.h"
#import "Todo.h"
#import <InnerBand/InnerBand.h>

@implementation Journal

@dynamic name;
@dynamic entries;
@dynamic todos;

- (void)createSampleItems {
//    for (int importance = 0; importance <= TodoRangeMaxValue; ++importance) {
//        for (int urgency = 0; urgency <= TodoRangeMaxValue; ++urgency) {
//            Todo *todo      = [Todo create];
//            todo.importance = importance;
//            todo.urgency    = urgency;
//            todo.title      = [NSString stringWithFormat:@"Importance %d, Urgency %d", importance, urgency];
//        }
//    }
//    
//    Todo *todo      = [Todo create];
//    todo.title      = @"Completed";
//    todo.importance = TodoImportanceDefaultValue;
//    todo.urgency    = TodoUrgencyDefaultValue;
//    
//    [todo createEntry:EntryTypeComplete];
//    
//    [[IBCoreDataStore mainStore] save];
}

@end
