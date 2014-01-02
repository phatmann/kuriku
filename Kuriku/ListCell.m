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
    NSString *statusClass, *commitmentClass;
    
    switch (todo.status) {
        case TodoStatusNormal:
            statusClass = @"normal";
            break;
            
        case TodoStatusCompleted:
            statusClass = @"completed";
            break;
            
        case TodoStatusHold:
            statusClass = @"hold";
            break;
    }
    
    switch (todo.commitment) {
        case TodoCommitmentMaybe:
            commitmentClass = @"maybe";
            break;
            
        case TodoCommitmentMust:
            commitmentClass = @"must";
            break;
            
        case TodoCommitmentToday:
            commitmentClass =  @"today";
            break;
    }
    
    return [NSString stringWithFormat:@"todo-urgency-%d todo-importance-%d todo-status-%@ todo-commitment-%@", todo.urgency, todo.importance, statusClass, commitmentClass];
}

- (NSString *)styleClassForEntry:(Entry *)entry {
    NSString *statusClass;
    
    switch (entry.status) {
        case EntryStatusOpen:
            statusClass = @"open";
            break;
            
        case EntryStatusClosed:
            statusClass = @"closed";
            break;
            
        case EntryStatusHold:
            statusClass =  @"hold";
            break;
    }
    
    return [NSString stringWithFormat:@"%@ entry-status-%@", [self styleClassForTodo:entry.todo], statusClass];
}

- (NSMutableAttributedString *)titleForTodo:(Todo *)todo {
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
