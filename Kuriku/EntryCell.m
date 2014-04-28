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
#import "GradientBar.h"
#import <InnerBand/InnerBand.h>
#import <NUI/UITextView+NUI.h>
#import "NSDate+Kuriku.h"

@interface EntryCell ()

@property (weak, nonatomic) IBOutlet UITextView *titleTextView;
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;
@property (weak, nonatomic) IBOutlet UILabel *dateLabel;
@property (weak, nonatomic) IBOutlet UIView *statusView;
@property (weak, nonatomic) IBOutlet UIView *progressView;
@property (weak, nonatomic) IBOutlet UIImageView *repeatIcon;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *progressViewWidthConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *statusViewWidthConstraint;

@end

@implementation EntryCell

- (NSString *)styleClassForEntry:(Entry *)entry {
    NSString *state, *status = @"Normal";
    
    switch (entry.state) {
        case EntryStateActive:
            state = @"Active";
            break;
            
        case EntryStateInactive:
            state = @"Inactive";
            break;
    }
    
    if (entry.type == EntryTypeComplete) {
        status = @"Completed";
    }
    
    return [NSString stringWithFormat:@"Status%@:State%@", status, state];
}

- (void)awakeFromNib {
    self.backgroundView = [UIView new];
}

- (void)setEntry:(Entry *)entry {
    _entry = entry;
    [self refresh];
}

- (void)setProgressBarValue:(CGFloat)progressBarValue {
    _progressBarValue = progressBarValue;
    self.progressViewWidthConstraint.constant = self.statusViewWidthConstraint.constant * fminf(1.0, progressBarValue);
    self.repeatIcon.hidden = (progressBarValue < 1.2);
}

- (BOOL)becomeFirstResponder {
    return [self.titleTextView becomeFirstResponder];
}

- (BOOL)resignFirstResponder {
    return [self.titleTextView resignFirstResponder];
}

- (void)refresh {
    [self updateTime];
    [self updateTitle];
    [self updateStatus];
}

- (void)importanceWasChanged {
    [self updateTitle];
    [self updateStatus];
}

- (void)statusWasChanged {
    [self updateStatus];
}

- (void)setDragType:(EntryDragType)dragType {
    _dragType = dragType;
    self.backgroundView.layer.borderWidth = 2.0;
    self.backgroundView.layer.borderColor = _dragType == EntryDragTypeNone ? [UIColor clearColor].CGColor : [UIColor blackColor].CGColor;
    [self updateBackground];
}

+ (CGFloat)fontSizeForImportance:(CGFloat)importance {
    CGFloat lowImportanceFontSize  = [NUISettings getFloat:@"font-size" withClass:@"ImportanceLow"];
    CGFloat highImportanceFontSize = [NUISettings getFloat:@"font-size" withClass:@"ImportanceHigh"];
    
    return lowImportanceFontSize + ((highImportanceFontSize - lowImportanceFontSize ) * importance);
}

#pragma mark -

- (void)updateTime {
    self.timeLabel.text = [self.entry.timestamp formattedTimeStyle:NSDateFormatterShortStyle];
}

- (void)updateProgress {
    self.progressViewWidthConstraint.constant = self.entry.progress * self.statusViewWidthConstraint.constant;
    _progressBarValue = self.entry.progress;
}

- (void)updateDate {
    self.dateLabel.text = nil;
    
    if (self.entry.state == EntryStateActive) {
        if ([self.entry.todo.startDate daysFromToday] > kFrostyDaysBeforeStartDate) {
            self.dateLabel.nuiClass = @"StartDate";
            self.dateLabel.text = [self.entry.todo.startDate formattedDatePattern:@"M/d"];
        } else if ([self.entry.todo.dueDate daysFromToday] > kUrgentDaysBeforeDueDate) {
            self.dateLabel.nuiClass = @"DueDate";
            self.dateLabel.text = [self.entry.todo.dueDate formattedDatePattern:@"M/d"];
        }
        
        [self.dateLabel applyNUI];
    }
}

- (void)updateStatus {
    [self updateDate];
    [self updateProgress];
    [self updateBackground];
}

- (void)updateTitle {
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
    
    self.titleTextView.font = [self.titleTextView.font fontWithSize:[EntryCell fontSizeForImportance:self.entry.todo.importance]];
}

-(void) updateBackground {
   if (self.entry.state == EntryStateActive) {
        if (self.entry.todo.frostiness > 0 && self.dragType != EntryDragTypeUrgency) {
            static UIColor *coolColor, *coldColor;
        
            if (!coolColor) {
                coolColor = [NUISettings getColor:@"background-color" withClass:@"TemperatureCool"];
                coldColor = [NUISettings getColor:@"background-color" withClass:@"TemperatureCold"];
            }
            
            self.backgroundView.backgroundColor = [EntryCell scale:self.entry.todo.frostiness fromColor:coolColor toColor:coldColor];

        } else if (self.entry.todo.urgency > 0 && self.dragType != EntryDragTypeFrostiness && self.entry.type != EntryTypeComplete) {
//           if (self.entry.todo.dueDate) {
               static UIColor *warmColor, *hotColor;
               if (!warmColor) {
                   warmColor = [NUISettings getColor:@"background-color" withClass:@"TemperatureWarm"];
                   hotColor  = [NUISettings getColor:@"background-color" withClass:@"TemperatureHot"];
               }

               self.backgroundView.backgroundColor = [EntryCell scale:self.entry.todo.urgency fromColor:warmColor toColor:hotColor];
//           } else {
//               static UIColor *oldColor, *veryOldColor;
//               if (!oldColor) {
//                   oldColor     = [NUISettings getColor:@"background-color" withClass:@"StalenessOld"];
//                   veryOldColor = [NUISettings getColor:@"background-color" withClass:@"StalenessVeryOld"];
//               }
//
//               self.statusView.backgroundColor = [EntryCell scale:self.entry.todo.temperature fromColor:oldColor toColor:veryOldColor];
//           }
        } else {
           self.backgroundView.backgroundColor = [NUISettings getColor:@"background-color" withClass:@"TemperatureNone"];
       }
   } else {
       self.statusView.backgroundColor = [NUISettings getColor:@"background-color" withClass:@"TemperatureNone"];
   }
}

#pragma Text View Delegate

- (void)textViewDidChange:(UITextView *)textView {
    self.entry.todo.title = textView.text;
    [self.journalViewController cell:self textViewDidChange:textView];
}

- (void)textViewDidBeginEditing:(UITextView *)textView {
    self.titleTextView.userInteractionEnabled = YES;
    [self.journalViewController cell:self textViewDidBeginEditing:textView];
}

- (void)textViewDidEndEditing:(UITextView *)textView {
    self.titleTextView.userInteractionEnabled = NO;
    
    [self.journalViewController cell:self textViewDidEndEditing:textView];
    
    if (self.entry.todo.title.length > 0)
        [IBCoreDataStore save];
    else
        [self.entry.todo destroy];
}

#pragma mark -

+ (UIColor *)scale:(float_t)scale fromColor:(UIColor*)fromColor toColor:(UIColor *)toColor {
    CGFloat fromHue, toHue, fromSaturation, toSaturation, fromBrightness, toBrightness;
    [fromColor getHue:&fromHue saturation:&fromSaturation brightness:&fromBrightness alpha:nil];
    [toColor getHue:&toHue saturation:&toSaturation brightness:&toBrightness alpha:nil];
    
    fromHue = fmod(fromHue, 1.0);
    toHue   = fmod(toHue, 1.0);
    
    CGFloat hue         = fromHue        + ((toHue - fromHue) * scale);
    CGFloat saturation  = fromSaturation + ((toSaturation - fromSaturation) * scale);
    CGFloat brightness  = fromBrightness + ((toBrightness - fromBrightness) * scale);
    
    return [UIColor colorWithHue:hue saturation:saturation brightness:brightness alpha:1.0];
}


@end
