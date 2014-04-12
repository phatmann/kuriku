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
@property (weak, nonatomic) IBOutlet UILabel *startDateLabel;
@end

@implementation EntryCell

- (NSString *)entryTypeString:(EntryType)type
{
    switch (type) {
        case EntryTypeNew:
            return @"NEW";
            
        case EntryTypeAction:
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

- (NSString *)startDateString:(NSDate *)startDate {
    return startDate ? [NSString stringWithFormat:@"%@", [startDate formattedDatePattern:@"M/d"]] : @"";
}

- (NSString *)styleClassForEntry:(Entry *)entry {
    NSString *state, *status = @"Normal", *commitment;
    
    switch (entry.state) {
        case EntryStateActive:
            state = @"Active";
            
            if (entry.type == EntryTypeComplete) {
                status = @"Completed";
            } else if ([entry.startDate timeIntervalSinceNow] < 0) {
                status = @"Hold";
            }
            
            break;
            
        case EntryStateInactive:
            state = @"Inactive";
            break;
    }
    
    switch (entry.todo.commitment) {
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
    
    return [NSString stringWithFormat:@"Urgency%d:Importance%d:Commitment%@:Status%@:State%@", entry.todo.urgency, entry.todo.importance, commitment, status, state];
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
    self.timeLabel.text = [self.entry.timestamp formattedTimeStyle:NSDateFormatterShortStyle];
    self.dueDateLabel.text = [self dueDateString:self.entry.todo.dueDate];
    self.startDateLabel.text = self.entry.startDate ? [self startDateString:self.entry.startDate] : nil;
    
    [self updateTitleLabel];
}

#pragma mark -

- (void)updateTitleLabel {
    self.titleTextView.nuiClass = [NSString stringWithFormat:@"Entry:%@", [self styleClassForEntry:self.entry]];

    NSString *title = self.entry.todo.title ? self.entry.todo.title : @"";
    
    NSString *decoration = [NUISettings get:@"text-decoration" withClass:self.titleTextView.nuiClass];
    NSUnderlineStyle strikethroughStyle = [decoration isEqualToString:@"line-through"] ?
        NSUnderlineStyleSingle : NSUnderlineStyleNone;
    
    NSDictionary *attributes = @{NSStrikethroughStyleAttributeName: @(strikethroughStyle)};
    
    self.titleTextView.attributedText = [[NSAttributedString alloc] initWithString:title
                                                                        attributes:attributes];
    self.titleTextView.typingAttributes = attributes;
    [self.titleTextView applyNUI];
}
    
#pragma Text View Delegate

- (void)textViewDidChange:(UITextView *)textView {
    self.entry.todo.title = textView.text;
    [self.journalViewController textViewDidChange:textView];
}

@end
