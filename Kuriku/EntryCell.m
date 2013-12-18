//
//  EntryCell.m
//  Kuriku
//
//  Created by Tony Mann on 12/14/13.
//  Copyright (c) 2013 7Actions. All rights reserved.
//

#import "EntryCell.h"
#import "Entry.h"
#import "Todo.h"
#import <InnerBand/InnerBand.h>

@interface EntryCell ()
@property (weak, nonatomic) IBOutlet UILabel *typeLabel;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;
@end

@implementation EntryCell

- (void)setEntry:(Entry *)entry
{
    _entry = entry;
    self.titleLabel.text = entry.todo.title;
    self.timeLabel.text = [entry.timestamp formattedTimeStyle:NSDateFormatterShortStyle];
    
    switch (entry.type) {
        case EntryTypeCreateTodo:
            self.typeLabel.text = @"NEW";
            break;
            
        case EntryTypeTakeAction:
            self.typeLabel.text = @"ACTION";
            break;
            
        case EntryTypeCompleteTodo:
            self.typeLabel.text = @"COMPLETE";
            break;
            
        case EntryTypeContinueTodo:
            self.typeLabel.text = @"CONTINUE";
            break;
    }
}

@end
