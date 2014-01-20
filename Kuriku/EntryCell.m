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
#import "JournalViewController.h"
#import <InnerBand/InnerBand.h>
#import <NUI/UITextView+NUI.h>

@interface EntryCell ()

@property (weak, nonatomic) IBOutlet UILabel *typeLabel;
@property (weak, nonatomic) IBOutlet UITextView *titleTextView;
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;
@property (weak, nonatomic) IBOutlet UILabel *dueDateLabel;
@property (weak, nonatomic) IBOutlet UILabel *holdDateLabel;
@end

@implementation EntryCell

- (void)setEntry:(Entry *)entry {
    _entry = entry;
    
    self.typeLabel.text = [self entryTypeString:entry.type];
    self.titleTextView.attributedText = [self titleForEntry:entry];
    self.titleTextView.nuiClass = [NSString stringWithFormat:@"Entry:%@", [self styleClassForEntry:entry]];
    self.timeLabel.text = [entry.timestamp formattedTimeStyle:NSDateFormatterShortStyle];
    self.dueDateLabel.text = [self dueDateString:entry.todo.dueDate];
    self.holdDateLabel.text = (entry.status == EntryStatusHold) ? [self holdDateString:entry.todo.holdDate] : nil;
}

- (void)setIsEditing:(BOOL)isEditing {
    if (isEditing) {
        self.titleTextView.userInteractionEnabled = YES;
        self.titleTextView.editable = YES;
        [self.titleTextView becomeFirstResponder];
    } else {
        self.titleTextView.userInteractionEnabled = NO;
        self.titleTextView.editable = NO;
        [self.titleTextView resignFirstResponder];
    }
}
    
#pragma Text View Delegate

- (void)textViewDidChange:(UITextView *)textView {
    self.entry.todo.title = textView.text;
    [self.journalViewController textViewDidChange:textView];
}

@end
