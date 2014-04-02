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


- (void)setEntry:(Entry *)entry {
    _entry = entry;
    [self refresh];
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

- (void)refresh
{
    self.typeLabel.text = [self entryTypeString:self.entry.type];
    self.titleTextView.attributedText = [self titleForEntry:self.entry];
    self.titleTextView.nuiClass = [NSString stringWithFormat:@"Entry:%@", [self styleClassForEntry:self.entry]];
    [self.titleTextView applyNUI];
    self.timeLabel.text = [self.entry.timestamp formattedTimeStyle:NSDateFormatterShortStyle];
    self.dueDateLabel.text = [self dueDateString:self.entry.todo.dueDate];
    self.holdDateLabel.text = (self.entry.status == EntryStatusHold) ? [self holdDateString:self.entry.todo.holdDate] : nil;
}
    
#pragma Text View Delegate

- (void)textViewDidChange:(UITextView *)textView {
    self.entry.todo.title = textView.text;
    [self.journalViewController textViewDidChange:textView];
}

@end
