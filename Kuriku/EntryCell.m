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
#import "GlowView.h"
#import <InnerBand/InnerBand.h>
#import <NUI/UITextView+NUI.h>
#import "NSDate+Kuriku.h"

@interface EntryCell ()
{
    UIColor *_warmColor, *_hotColor, *_coolColor, *_coldColor, *_oldColor, *_veryOldColor;
    GlowView *_glowView;
}

@property (weak, nonatomic) IBOutlet UILabel *timeLabel;
@property (weak, nonatomic) IBOutlet UIView *statusView;
@property (weak, nonatomic) IBOutlet UIView *progressView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *progressViewWidthConstraint;
@property (weak, nonatomic) IBOutlet UILabel *dateLabel;
@property (strong, nonatomic) UIColor *textGlowColor;
@property (strong, nonatomic) UIColor *cellGlowColor;

@end

@implementation EntryCell

- (void)prepareForReuse {
    [super prepareForReuse];
    
    self.repeatIcon.hidden = YES;
    self.progressViewWidthConstraint.constant = 0;
    self.cellGlowColor = nil;
    self.textGlowColor = nil;
}

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
    _glowView = [GlowView new];
    self.backgroundView = _glowView;
    self.backgroundView.backgroundColor = [UIColor whiteColor];
    self.titleTextView.textContainerInset = UIEdgeInsetsZero;
    
    _warmColor    = [NUISettings getColor:@"background-color" withClass:@"TemperatureWarm"];
    _hotColor     = [NUISettings getColor:@"background-color" withClass:@"TemperatureHot"];
    _coolColor    = [NUISettings getColor:@"background-color" withClass:@"TemperatureCool"];
    _coldColor    = [NUISettings getColor:@"background-color" withClass:@"TemperatureCold"];
    _oldColor     = [NUISettings getColor:@"background-color" withClass:@"StalenessOld"];
    _veryOldColor = [NUISettings getColor:@"background-color" withClass:@"StalenessVeryOld"];
    
    self.progressViewWidthConstraint.constant = 0;
}

- (void)setEntry:(Entry *)entry {
    _entry = entry;
    [self refresh];
}

- (void)setProgressBarValue:(CGFloat)progressBarValue {
    _progressBarValue = progressBarValue;
    self.progressViewWidthConstraint.constant = self.statusView.frame.size.width * fminf(1.0, progressBarValue);
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
    [self updateTemperature];
    [self updateBackground];
    [self updateProgress];
}

- (void)importanceWasChanged {
    [self updateTitle];
    [self updateTemperature];
}

- (void)temperatureWasChanged {
    [self updateTemperature];
}

- (UIColor *)cellGlowColor {
    return _glowView.glowColor;
}

- (void)setCellGlowColor:(UIColor *)cellGlowColor {
    _glowView.glowColor = cellGlowColor;
}

+ (CGFloat)fontSizeForImportance:(CGFloat)importance {
    CGFloat lowImportanceFontSize  = [NUISettings getFloat:@"font-size" withClass:@"ImportanceLow"];
    CGFloat highImportanceFontSize = [NUISettings getFloat:@"font-size" withClass:@"ImportanceHigh"];
    
    return lowImportanceFontSize + ((highImportanceFontSize - lowImportanceFontSize ) * importance);
}

#pragma mark -

- (void)updateTime {
    self.timeLabel.text = [self.entry.timestamp formattedTimeStyle:NSDateFormatterShortStyle];
    
    if (self.entry.type == EntryTypeComplete) {
        self.timeLabel.nuiClass = @"TimeCompleted";
    } else if (self.entry.state == EntryStateInactive) {
        self.timeLabel.nuiClass = @"TimeInactive";
    } else {
        self.timeLabel.nuiClass = @"Time";
    }
    
    [self.timeLabel applyNUI];
}

- (void)updateProgress {
    self.progressBarValue = self.entry.progress;
}

- (void)updateDate {
    self.dateLabel.text = nil;
    
    if (self.entry.state == EntryStateActive) {
        NSDate *date = nil;
        BOOL alwaysShowDate = NO;
        BOOL useStartDate;
        NSString *prefix = @"";
        
        if (self.entry.todo.startDate) {
            date = self.entry.todo.startDate;
            useStartDate = YES;
            self.dateLabel.nuiClass = @"StartDate";
        } else if (self.entry.todo.dueDate) {
            date = self.entry.todo.dueDate;
            useStartDate = NO;
            self.dateLabel.nuiClass = @"DueDate";
        }
        
        if (date) {
            int days = [date daysFromToday];
            
            BOOL isDistantDate;
            
            if (useStartDate) {
                isDistantDate = self.entry.todo.frostiness > 1.0;
            } else {
                isDistantDate = self.entry.todo.urgency < 0.0;
            }
            
            NSString *dateText;
            
            if (isDistantDate) {
                dateText = [date formattedDatePattern:@"M/d"];
            } else if (alwaysShowDate) {
                if (days == 0) {
                    dateText = @"now";
                } else if (days == 1) {
                    dateText = @"1 day";
                } else {
                    dateText = [NSString stringWithFormat:@"%d days", days];
                }
            }
            
            if (dateText) {
                self.dateLabel.text = [prefix stringByAppendingString:dateText];
                [self.dateLabel applyNUI];
            }
        }
    }
}

- (void)updateTemperature {
    [self updateDate];
    self.cellGlowColor = nil;
    
    if (self.entry.state == EntryStateActive) {
        if (self.entry.todo.frostiness > 0) {
            self.cellGlowColor = [EntryCell scale:fratiof(self.entry.todo.frostiness) fromColor:_coolColor toColor:_coldColor];
        } else if (self.entry.todo.urgency > 0 && self.entry.type != EntryTypeComplete) {
            self.cellGlowColor = [EntryCell scale:fratiof(self.entry.todo.urgency) fromColor:_warmColor toColor:_hotColor];
        }
    }
}

- (void)updateTitle {
    self.titleTextView.nuiClass = [NSString stringWithFormat:@"Entry:%@", [self styleClassForEntry:self.entry]];

    NSString *title = self.entry.todo.title ? self.entry.todo.title : @"";
    
    NSString *decoration = [NUISettings get:@"text-decoration" withClass:self.titleTextView.nuiClass];
    NSUnderlineStyle strikethroughStyle = [decoration isEqualToString:@"line-through"] ?
        NSUnderlineStyleSingle : NSUnderlineStyleNone;
    
    NSMutableDictionary *attributes = [@{NSStrikethroughStyleAttributeName: @(strikethroughStyle)} mutableCopy];
    
    if (self.textGlowColor) {
        NSShadow *shadow = [NSShadow new];
        shadow.shadowOffset = CGSizeMake(0, 0);
        shadow.shadowBlurRadius = 0;
        shadow.shadowBlurRadius = 5;
        shadow.shadowColor = self.textGlowColor;
        attributes[NSShadowAttributeName] = shadow;
    }
    
    self.titleTextView.attributedText = [[NSAttributedString alloc] initWithString:title
                                                                        attributes:attributes];
    self.titleTextView.typingAttributes = attributes;
    [self.titleTextView applyNUI];
    
    self.titleTextView.font = [self.titleTextView.font fontWithSize:[EntryCell fontSizeForImportance:self.entry.todo.importance]];
}

-(void) updateBackground {
    if (self.entry.state == EntryStateActive) {
        if (self.entry.todo.staleness > 0 && self.entry.type != EntryTypeComplete) {
            self.backgroundView.backgroundColor = [EntryCell scale:self.entry.todo.staleness fromColor:_oldColor toColor:_veryOldColor];
        } else {
            self.backgroundView.backgroundColor = [NUISettings getColor:@"background-color" withClass:@"TemperatureNone"];
        }
    } else {
        self.backgroundView.backgroundColor = [NUISettings getColor:@"background-color" withClass:@"EntryInactive"];
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
    scale = fratiof(scale);
    
    CGFloat fromHue, toHue, fromSaturation, toSaturation, fromBrightness, toBrightness;
    [fromColor getHue:&fromHue saturation:&fromSaturation brightness:&fromBrightness alpha:nil];
    [toColor getHue:&toHue saturation:&toSaturation brightness:&toBrightness alpha:nil];
    
    fromHue = fmodf(fromHue, 1.0);
    toHue   = fmodf(toHue, 1.0);
    
    CGFloat hue         = fromHue        + ((toHue - fromHue) * scale);
    CGFloat saturation  = fromSaturation + ((toSaturation - fromSaturation) * scale);
    CGFloat brightness  = fromBrightness + ((toBrightness - fromBrightness) * scale);
    
    return [UIColor colorWithHue:hue saturation:saturation brightness:brightness alpha:1.0];
}


@end
