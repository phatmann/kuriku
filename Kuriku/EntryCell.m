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
@property (weak, nonatomic) IBOutlet UILabel *dueDateLabel;

@end

@implementation EntryCell


- (void)setEntry:(Entry *)entry
{
    _entry = entry;
  
    self.typeLabel.text = [self entryTypeString:entry.type];
    self.titleLabel.attributedText = entryTitleString(entry);
    self.timeLabel.text = [entry.timestamp formattedTimeStyle:NSDateFormatterShortStyle];

    self.dueDateLabel.text = [self dueDateString:entry.todo.dueDate];
}

@end
