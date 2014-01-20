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
    NSString *status, *commitment;
    
    switch (todo.status) {
        case TodoStatusNormal:
            status = @"Normal";
            break;
            
        case TodoStatusCompleted:
            status = @"Completed";
            break;
            
        case TodoStatusHold:
            status = @"Hold";
            break;
    }
    
    switch (todo.commitment) {
        case TodoCommitmentMaybe:
            commitment = @"Maybe";
            break;
            
        case TodoCommitmentMust:
            commitment = @"Must";
            break;
            
        case TodoCommitmentToday:
            commitment = @"Today";
            break;
    }
    
    return [NSString stringWithFormat:@"TodoUrgency%d:TodoImportance%d:TodoCommitment%@:TodoStatus%@", todo.urgency, todo.importance, commitment, status];
}

- (NSString *)styleClassForEntry:(Entry *)entry {
    NSString *status;
    
    switch (entry.status) {
        case EntryStatusOpen:
            status = @"Open";
            break;
            
        case EntryStatusClosed:
            status = @"Closed";
            break;
            
        case EntryStatusHold:
            status =  @"Hold";
            break;
    }
    
    return [NSString stringWithFormat:@"%@:EntryStatus%@", [self styleClassForTodo:entry.todo], status];
}

- (NSMutableAttributedString *)titleForTodo:(Todo *)todo {
    if (!todo || !todo.title)
        return nil;
    
    NSDictionary *attributes = @{};
    
    if (todo.status == TodoStatusCompleted) {
        attributes = @{NSStrikethroughStyleAttributeName:@(NSUnderlineStyleSingle | NSUnderlinePatternSolid)};
    }
    
    return [[NSMutableAttributedString alloc] initWithString:todo.title attributes:attributes];

}

- (NSMutableAttributedString *)titleForEntry:(Entry *)entry {
    NSMutableAttributedString *title = [self titleForTodo:entry.todo];
    
    if (entry.todo.status != TodoStatusCompleted && entry.status == EntryStatusClosed) {
        [title addAttribute:NSStrikethroughStyleAttributeName value:@(NSUnderlineStyleSingle | NSUnderlinePatternSolid) range:NSMakeRange(0, title.length)];
    }
    
    return title;
}

@end
