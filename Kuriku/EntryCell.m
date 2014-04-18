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
#import "NSDate+Kuriku.h"

@interface EntryCell ()

@property (weak, nonatomic) IBOutlet UILabel *typeLabel;
@property (weak, nonatomic) IBOutlet UITextView *titleTextView;
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;
@property (weak, nonatomic) IBOutlet UILabel *dateLabel;
@property (weak, nonatomic) IBOutlet UIView *statusView;
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

- (NSString *)styleClassForEntry:(Entry *)entry {
    NSString *state, *status = @"Normal";
    
    switch (entry.state) {
        case EntryStateActive:
            state = @"Active";
            
            if (entry.type == EntryTypeComplete) {
                status = @"Completed";
            }
            
            break;
            
        case EntryStateInactive:
            state = @"Inactive";
            break;
    }
    
    return [NSString stringWithFormat:@"Status%@:State%@", status, state];
}

- (void)setEntry:(Entry *)entry {
    _entry = entry;
    [self refresh];
}

- (BOOL)becomeFirstResponder {
    return [self.titleTextView becomeFirstResponder];
}

- (BOOL)resignFirstResponder {
    return [self.titleTextView resignFirstResponder];
}

- (void)refresh {
    self.typeLabel.text = [self entryTypeString:self.entry.type];
    self.timeLabel.text = [self.entry.timestamp formattedTimeStyle:NSDateFormatterShortStyle];
    self.dateLabel.text = nil;
    
    if (self.entry.state == EntryStateActive) {
        if (self.entry.todo.startDate) {
            if ([self.entry.todo.startDate daysFromToday] <= kFrostyDaysBeforeStartDate) {
                self.dateLabel.text = nil;
            } else {
                self.dateLabel.nuiClass = @"StartDate";
                self.dateLabel.text = [self.entry.todo.startDate formattedDatePattern:@"M/d"];
            }
        } else if (self.entry.todo.dueDate) {
            if ([self.entry.todo.dueDate daysFromToday] <= kUrgentDaysBeforeDueDate) {
                self.dateLabel.text = nil;
            } else {
                self.dateLabel.nuiClass = @"DueDate";
                self.dateLabel.text = [self.entry.todo.dueDate formattedDatePattern:@"M/d"];
            }
        }
        
        [self.dateLabel applyNUI];
    }
    
    [self updateTitleLabel];
}

- (IBAction)statusWasTapped {
    [self.journalViewController statusWasTappedForCell:self];
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
    
    if (self.entry.state == EntryStateActive && self.entry.type != EntryTypeComplete) {
        if (self.entry.todo.temperature > 0) {
            static UIColor *warmColor, *hotColor;
            
            if (!warmColor) {
                warmColor = [NUISettings getColor:@"background-color" withClass:@"TemperatureWarm"];
                hotColor  = [NUISettings getColor:@"background-color" withClass:@"TemperatureHot"];
            }
            
            self.statusView.backgroundColor = [EntryCell huedColorForScale:self.entry.todo.temperature fromColor:warmColor toColor:hotColor];
        } else if (self.entry.todo.temperature < 0) {
            static UIColor *coolColor, *coldColor;
            
            if (!coolColor) {
                coolColor = [NUISettings getColor:@"background-color" withClass:@"TemperatureCool"];
                coldColor = [NUISettings getColor:@"background-color" withClass:@"TemperatureCold"];
            }
            
            self.statusView.backgroundColor = [EntryCell huedColorForScale:-self.entry.todo.temperature fromColor:coolColor toColor:coldColor];
        } else {
            self.statusView.backgroundColor = [NUISettings getColor:@"background-color" withClass:@"TemperatureNone"];
        }
    }
    
    self.titleTextView.font = [self.titleTextView.font fontWithSize:[EntryCell fontSizeForImportance:self.entry.todo.importance]];
}

+ (CGFloat)fontSizeForImportance:(CGFloat)importance {
    CGFloat lowImportanceFontSize  = [NUISettings getFloat:@"font-size" withClass:@"ImportanceLow"];
    CGFloat highImportanceFontSize = [NUISettings getFloat:@"font-size" withClass:@"ImportanceHigh"];
    
    return lowImportanceFontSize + ((highImportanceFontSize - lowImportanceFontSize ) * importance);
}

+ (UIColor *)huedColorForScale:(float_t)scale fromColor:(UIColor*)fromColor toColor:(UIColor *)toColor {
    CGFloat fromHue, toHue;
    [fromColor getHue:&fromHue saturation:nil brightness:nil alpha:nil];
    [toColor getHue:&toHue saturation:nil brightness:nil alpha:nil];
    
    fromHue = fmod(fromHue, 1.0);
    toHue   = fmod(toHue, 1.0);
    
    CGFloat hue = fromHue + ((toHue - fromHue) * scale);
    return [UIColor colorWithHue:hue saturation:1.0 brightness:1.0 alpha:1.0];
}

#pragma Text View Delegate

- (void)textViewDidChange:(UITextView *)textView {
    self.entry.todo.title = textView.text;
    [self.journalViewController textViewDidChange:textView];
}

- (void)textViewDidBeginEditing:(UITextView *)textView {
    [self setEditing:YES animated:YES];
    [self.journalViewController textViewDidBeginEditing:textView];
}

- (void)textViewDidEndEditing:(UITextView *)textView {
    [self setEditing:NO animated:YES];
    [self.journalViewController textViewDidEndEditing:textView];
}

@end
