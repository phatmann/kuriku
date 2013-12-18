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

@interface EntryCell ()
@property (weak, nonatomic) IBOutlet UILabel *typeLabel;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@end

@implementation EntryCell

- (void)setEntry:(Entry *)entry
{
    _entry = entry;
    self.titleLabel.text = entry.todo.title;
    
    switch (entry.type) {
        case EntryTypeCreateTodo:
            self.typeLabel.text = @"NEW";
            break;
            
        case EntryTypeTakeAction:
            self.typeLabel.text = @"ACT";
            break;
            
        case EntryTypeCompleteTodo:
            self.typeLabel.text = @"DONE";
            break;
            
        case EntryTypeContinueTodo:
            self.typeLabel.text = @"CONT";
            break;
    }
}

@end
