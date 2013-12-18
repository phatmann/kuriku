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
    
    NSDictionary *attributes;
    
    switch (entry.type) {
        case EntryTypeCreateTodo:
            attributes = @{};
            self.typeLabel.text = @"NEW";
            break;
            
        case EntryTypeTakeAction:
            attributes = @{NSFontAttributeName:[UIFont italicSystemFontOfSize:self.titleLabel.font.pointSize]};
            self.typeLabel.text = @"ACTION";
            break;
            
        case EntryTypeCompleteTodo:
            attributes = @{NSStrikethroughStyleAttributeName:@(NSUnderlineStyleSingle)};
            self.typeLabel.text = @"COMPLETE";
            break;
            
        case EntryTypeContinueTodo:
            attributes = @{};
            self.typeLabel.text = @"CONTINUE";
            break;
    }
    
    self.titleLabel.attributedText = [[NSAttributedString alloc] initWithString:entry.todo.title attributes:attributes];
    self.timeLabel.text = [entry.timestamp formattedTimeStyle:NSDateFormatterShortStyle];
}

@end
