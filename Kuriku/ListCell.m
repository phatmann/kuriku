//
//  ListCell.m
//  
//
//  Created by Tony Mann on 1/1/14.
//
//

#import "ListCell.h"
#import "Todo.h"
#import <InnerBand/InnerBand.h>

@implementation ListCell

- (NSString *)entryTypeString:(EntryType)type
{
    switch (type) {
            case EntryTypeCreate:
                return @"NEW";
            
            case EntryTypeTakeAction:
                return @"ACTION";
            
            case EntryTypeComplete:
                return @"COMPLETE";
            
            case EntryTypeReady:
                return @"READY";
            
            case EntryTypeHold:
                return @"HOLD";
    }
    
    return nil;
}

- (NSString *)dueDateString:(NSDate *)dueDate {
    return dueDate ? [NSString stringWithFormat:@"DUE %@", [dueDate formattedDatePattern:@"M/d"]] : @"";
}

- (NSString *)holdDateString:(NSDate *)holdDate {
    return holdDate ? [NSString stringWithFormat:@"%@", [holdDate formattedDatePattern:@"M/d"]] : @"";
}

- (NSString *)styleClassForTodo:(Todo *)todo {
    return [NSString stringWithFormat:@"urgency-%d importance-%d", todo.urgency, todo.importance];
}

@end
