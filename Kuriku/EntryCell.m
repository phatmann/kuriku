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
#import "Styles.h"
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
  
    switch (entry.type) {
        case EntryTypeCreate:
            self.typeLabel.text = @"NEW";
            break;
            
        case EntryTypeTakeAction:
            self.typeLabel.text = @"ACTION";
            break;
            
        case EntryTypeComplete:
            self.typeLabel.text = @"COMPLETE";
            break;
            
        case EntryTypeReady:
            self.typeLabel.text = @"READY";
            break;
            
        case EntryTypeHold:
        {
            NSString *dateString = [entry.todo.holdDate formattedDatePattern:@"M/d"];
            self.typeLabel.text = [NSString stringWithFormat:@"HOLD UNTIL %@", dateString];
            break;
        }
    }
    
    self.titleLabel.attributedText = entryTitleString(entry);
    self.timeLabel.text = [entry.timestamp formattedTimeStyle:NSDateFormatterShortStyle];
}

@end
