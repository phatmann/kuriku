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
            } else if (entry.todo.startDate) {
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
    
    return [NSString stringWithFormat:@"Commitment%@:Status%@:State%@", commitment, status, state];
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

- (BOOL)resignFirstResponder {
    return [self.titleTextView resignFirstResponder];
}

- (void)refresh
{
    self.typeLabel.text = [self entryTypeString:self.entry.type];
    self.timeLabel.text = [self.entry.timestamp formattedTimeStyle:NSDateFormatterShortStyle];
    
    self.dueDateLabel.text = [self dueDateString:self.entry.todo.dueDate];
    self.startDateLabel.text = self.entry.todo.startDate ? [self startDateString:self.entry.todo.startDate] : nil;
    
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
    
    if (self.entry.todo.urgency == 0) {
        self.titleTextView.textColor = [NUISettings getColor:@"font-color" withClass:@"UrgencyNone"];
    } else {
        UIColor *warmColor = [NUISettings getColor:@"font-color" withClass:@"UrgencyWarm"];
        UIColor *hotColor  = [NUISettings getColor:@"font-color" withClass:@"UrgencyHot"];
        
        CGFloat warmHue, hotHue, warmSaturation, hotSaturation, warmBrightness, hotBrightness;
        [warmColor getHue:&warmHue saturation:&warmSaturation brightness:&warmBrightness alpha:nil];
        [hotColor  getHue:&hotHue saturation:&hotSaturation brightness:&hotBrightness alpha:nil];
        CGFloat hue = warmHue - ((warmHue + hotHue) * self.entry.todo.urgency);
        UIColor *color = [UIColor colorWithHue:hue saturation:1.0 brightness:1.0 alpha:1.0];
        self.titleTextView.textColor = color;
    }
    
    CGFloat lowImportanceFontSize  = [NUISettings getFloat:@"font-size" withClass:@"ImportanceLow"];
    CGFloat highImportanceFontSize = [NUISettings getFloat:@"font-size" withClass:@"ImportanceHigh"];
    
    CGFloat fontSize = lowImportanceFontSize + ((highImportanceFontSize - lowImportanceFontSize ) * self.entry.todo.importance);
    self.titleTextView.font = [self.titleTextView.font fontWithSize:fontSize];
}
    
#pragma Text View Delegate

- (void)textViewDidChange:(UITextView *)textView {
    self.entry.todo.title = textView.text;
    [self.journalViewController textViewDidChange:textView];
}

- (void)textViewDidEndEditing:(UITextView *)textView {
    self.entry.todo.title = textView.text;
    [self.journalViewController textViewDidEndEditing:textView];
}

@end
