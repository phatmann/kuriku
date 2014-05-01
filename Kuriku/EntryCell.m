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
    UIColor *_warmColor, *_hotColor, *_coolColor, *_coldColor;
    GlowView *_glowView;
}

@property (weak, nonatomic) IBOutlet UILabel *timeLabel;
@property (weak, nonatomic) IBOutlet UIView *statusView;
@property (weak, nonatomic) IBOutlet UIView *progressView;
@property (weak, nonatomic) IBOutlet UIImageView *repeatIcon;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *progressViewWidthConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *statusViewWidthConstraint;
@property (weak, nonatomic) IBOutlet UILabel *dateLabel;
@property (weak, nonatomic) IBOutlet GradientBar *urgencyBar;
@property (weak, nonatomic) IBOutlet GradientBar *frostinessBar;

@end

@implementation EntryCell

- (void)prepareForReuse {
    self.repeatIcon.hidden = YES;
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
    
    _warmColor = [NUISettings getColor:@"background-color" withClass:@"TemperatureWarm"];
    _hotColor  = [NUISettings getColor:@"background-color" withClass:@"TemperatureHot"];
    _coolColor = [NUISettings getColor:@"background-color" withClass:@"TemperatureCool"];
    _coldColor = [NUISettings getColor:@"background-color" withClass:@"TemperatureCold"];

    self.urgencyBar.type = GradientBarTypeVertical;
    self.urgencyBar.startColor = _warmColor;
    self.urgencyBar.endColor   = _hotColor;
    
    self.frostinessBar.type = GradientBarTypeHorizontal;
    self.frostinessBar.startColor = _coolColor;
    self.frostinessBar.endColor   = _coldColor;
}

- (void)setEntry:(Entry *)entry {
    _entry = entry;
    [self refresh];
}

- (void)setProgressBarValue:(CGFloat)progressBarValue {
    _progressBarValue = progressBarValue;
    self.progressViewWidthConstraint.constant = self.statusView.frame.size.width * fminf(1.0, progressBarValue);
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
    [self updateBackground];
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
    
    self.backgroundView.layer.shadowColor = _dragType == EntryDragTypeNone ? [UIColor clearColor].CGColor : [UIColor grayColor].CGColor;
    self.backgroundView.layer.shadowRadius = 3.0;
    self.backgroundView.layer.shadowOffset = CGSizeMake(-3, 3);
    self.backgroundView.layer.shadowOpacity = 0.8;
    CGRect shadowFrame = self.backgroundView.layer.bounds;
    CGPathRef shadowPath = [UIBezierPath bezierPathWithRect:shadowFrame].CGPath;
    self.backgroundView.layer.shadowPath = shadowPath;
    
    [self updateTemperatureBars];
    [self updateDate];
    [self updateTitle];
    [self updateGlow];
}

- (void)setDatePrompt:(NSString *)datePrompt {
    _datePrompt = datePrompt;
    
    self.dateLabel.text = datePrompt;
    self.dateLabel.nuiClass = @"DatePrompt";
    [self.dateLabel applyNUI];
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
    self.progressViewWidthConstraint.constant = self.entry.progress * self.statusView.frame.size.width;
    _progressBarValue = self.entry.progress;
}

- (void)updateDate {
    self.dateLabel.text = nil;
    
    if (self.entry.state == EntryStateActive) {
        NSDate *date = nil;
        BOOL alwaysShowDate = NO;
        BOOL useStartDate;
        NSString *prefix = @"";
        
        if (self.dragType == EntryDragTypeFrostiness) {
            date = self.entry.todo.startDate;
            prefix = @"START ";
            useStartDate = YES;
            alwaysShowDate = YES;
            self.dateLabel.nuiClass = @"StartDateDragging";
        } else if (self.dragType == EntryDragTypeUrgency) {
            date = self.entry.todo.dueDate;
            prefix = @"DUE ";
            useStartDate = NO;
            alwaysShowDate = YES;
            self.dateLabel.nuiClass = @"DueDateDragging";
        } else if (self.entry.todo.startDate) {
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
                    //dateText = @"now";
                } else if (days == 1) {
                    //dateText = @"1 day";
                } else {
                    //dateText = [NSString stringWithFormat:@"%d days", days];
                }
            }
            
            if (dateText) {
                self.dateLabel.text = [prefix stringByAppendingString:dateText];
                [self.dateLabel applyNUI];
            }
        }
    }
}

- (void)updateStatus {
    [self updateDate];
    [self updateProgress];
    [self updateTitle];
    [self updateTemperatureBars];
    [self updateGlow];
}

- (void)updateTitle {
    self.titleTextView.nuiClass = [NSString stringWithFormat:@"Entry:%@", [self styleClassForEntry:self.entry]];

    NSString *title = self.entry.todo.title ? self.entry.todo.title : @"";
    
    NSString *decoration = [NUISettings get:@"text-decoration" withClass:self.titleTextView.nuiClass];
    NSUnderlineStyle strikethroughStyle = [decoration isEqualToString:@"line-through"] ?
        NSUnderlineStyleSingle : NSUnderlineStyleNone;
    
    CGFloat temp = [self displayTemperature];
    
    NSShadow *shadow = [NSShadow new];
    shadow.shadowBlurRadius = 0;
    shadow.shadowOffset = CGSizeMake(0, 0);
    
    if (temp > 0) {
        shadow.shadowBlurRadius = 5;
        shadow.shadowColor = [EntryCell scale:temp fromColor:_warmColor toColor:_hotColor];
    } else if (temp < 0) {
        //shadow.shadowBlurRadius = 5;
        shadow.shadowColor = [EntryCell scale:-temp fromColor:_coolColor toColor:_coldColor];
    }
    
    NSDictionary *attributes = @{NSStrikethroughStyleAttributeName: @(strikethroughStyle), NSShadowAttributeName:shadow};
    
    
    self.titleTextView.attributedText = [[NSAttributedString alloc] initWithString:title
                                                                        attributes:attributes];
    self.titleTextView.typingAttributes = attributes;
    [self.titleTextView applyNUI];
    
    self.titleTextView.font = [self.titleTextView.font fontWithSize:[EntryCell fontSizeForImportance:self.entry.todo.importance]];
}

- (void)updateGlow {
    CGFloat temp = [self displayTemperature];
    
    if (temp < 0) {
        _glowView.hidden = NO;
        _glowView.color = [EntryCell scale:-temp fromColor:_coolColor toColor:_coldColor];
    } else {
        _glowView.hidden = YES;
    }
}

- (void)updateTemperatureBars {
    self.urgencyBar.hidden = YES;
    self.frostinessBar.hidden = YES;
    CGFloat temp = [self displayTemperature];
    
    if (temp > 0) {
        //self.urgencyBar.hidden = NO;
        self.urgencyBar.value = temp;
    } else if (temp < 0) {
        //self.frostinessBar.hidden = NO;
        self.frostinessBar.value = -temp;
    }
}

-(void) updateBackground {
    if (self.entry.state == EntryStateActive) {
        CGFloat temp = [self displayTemperature];
        
        if (temp > 0) {
            //self.backgroundView.backgroundColor = [EntryCell scale:temp fromColor:_warmColor toColor:_hotColor];
        } else if (temp < 0) {
            //self.backgroundView.backgroundColor = [EntryCell scale:-temp fromColor:_coolColor toColor:_coldColor];
        } else if (self.entry.todo.staleness > 0 && self.entry.type != EntryTypeComplete) {
            static UIColor *oldColor, *veryOldColor;
            
            if (!oldColor) {
                oldColor     = [NUISettings getColor:@"background-color" withClass:@"StalenessOld"];
                veryOldColor = [NUISettings getColor:@"background-color" withClass:@"StalenessVeryOld"];
            }
            
            self.backgroundView.backgroundColor = [EntryCell scale:self.entry.todo.temperature fromColor:oldColor toColor:veryOldColor];
        } else if (self.entry.type == EntryTypeComplete) {
            self.backgroundView.backgroundColor = [NUISettings getColor:@"background-color" withClass:@"EntryComplete"];
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

- (CGFloat)displayTemperature {
    if (self.entry.state == EntryStateActive) {
        if (self.entry.todo.frostiness > 0 && self.dragType != EntryDragTypeUrgency) {
            return -fratiof(self.entry.todo.frostiness);
        } else if (self.entry.todo.urgency > 0 && self.dragType != EntryDragTypeFrostiness && self.entry.type != EntryTypeComplete) {
            return fratiof(self.entry.todo.urgency);
        }
    }
    
    return 0;
}

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
