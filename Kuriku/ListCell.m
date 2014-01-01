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
//                if (entry.status != EntryStatusClosed) {
//                    NSString *dateString = [entry.todo.holdDate formattedDatePattern:@"M/d"];
//                    return [NSString stringWithFormat:@"HOLD UNTIL %@", dateString];
//                } else {
                    return @"HOLD";
                //}
    }
    
    return nil;
}

- (NSString *)dueDateString:(NSDate *)dueDate {
    return dueDate ? [NSString stringWithFormat:@"DUE %@", [dueDate formattedDatePattern:@"M/d"]] : @"";
}

@end
