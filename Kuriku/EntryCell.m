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
#import <Pixate/Pixate.h>

@interface EntryCell ()

@property (weak, nonatomic) IBOutlet UILabel *typeLabel;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;
@property (weak, nonatomic) IBOutlet UILabel *dueDateLabel;
@property (weak, nonatomic) IBOutlet UILabel *holdDateLabel;
@end

@implementation EntryCell


- (void)setEntry:(Entry *)entry
{
    _entry = entry;
  
    self.typeLabel.text = [self entryTypeString:entry.type];
    self.titleLabel.attributedText = [self titleForEntry:entry];
    self.titleLabel.styleClass = [NSString stringWithFormat:@"entry %@", [self styleClassForEntry:entry]];
    self.timeLabel.text = [entry.timestamp formattedTimeStyle:NSDateFormatterShortStyle];
    self.dueDateLabel.text = [self dueDateString:entry.todo.dueDate];
    self.holdDateLabel.text = (entry.status == EntryStatusHold) ? [self holdDateString:entry.todo.holdDate] : nil;
}

@end
