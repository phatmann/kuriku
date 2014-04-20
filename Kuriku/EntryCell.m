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

@property (weak, nonatomic) IBOutlet UITextView *titleTextView;
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;
@property (weak, nonatomic) IBOutlet UILabel *dateLabelInStatusView;
@property (weak, nonatomic) IBOutlet UILabel *dateLabelInProgressView;
@property (weak, nonatomic) IBOutlet UIView *statusView;
@property (weak, nonatomic) IBOutlet UIView *progressView;
@property (weak, nonatomic) IBOutlet UIView *temperatureView;
@property (weak, nonatomic) IBOutlet UISlider *temperatureSlider;
@property (weak, nonatomic) IBOutlet UIButton *startDateButton;
@property (weak, nonatomic) IBOutlet UIButton *dueDateButton;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *temperatureViewHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *progressViewWidthConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *statusViewWidthConstraint;
@end

@implementation EntryCell

- (void)awakeFromNib {
    UIImage *thumbImage = [UIImage imageNamed:@"slider-thumb"];
    [self.temperatureSlider setThumbImage:thumbImage forState:UIControlStateNormal];
    [self.temperatureSlider setThumbImage:thumbImage forState:UIControlStateHighlighted];
    self.temperatureViewHeightConstraint.constant = 0;
}

- (void)prepareForReuse {
    self.temperatureViewHeightConstraint.constant = 0;
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
    [self updateTime];
    [self updateTitle];
    [self updateStatus];
    [self updateDateButtons];
    [self updateTemperatureSlider];
}

- (IBAction)statusWasTapped {
    [self.journalViewController statusWasTappedForCell:self];
}

- (IBAction)temperatureSliderWasChanged {
    if (self.temperatureSlider.value > -0.05 && self.temperatureSlider.value < 0.05)
        self.temperatureSlider.value = 0;
    
    self.entry.todo.temperature = self.temperatureSlider.value;
    [self updateDateButtons];
    [self updateStatus];
}

#pragma mark -

- (void)updateTemperatureSlider {
    self.temperatureSlider.value = self.entry.todo.temperature;
}

- (void)updateDateButtons {
    if (self.entry.todo.startDate) {
        [self.startDateButton setTitle:[NSString stringWithFormat:@"START %@", [self.entry.todo.startDate formattedDatePattern:@"M/d"]] forState:UIControlStateNormal];
    } else {
        [self.startDateButton setTitle:nil forState:UIControlStateNormal];
    }
    
    if (self.entry.todo.dueDate) {
        [self.dueDateButton setTitle:[NSString stringWithFormat:@"DUE %@", [self.entry.todo.dueDate formattedDatePattern:@"M/d"]] forState:UIControlStateNormal];
    } else {
        [self.dueDateButton setTitle:nil forState:UIControlStateNormal];
    }
}

- (void)updateTime {
    self.timeLabel.text = [self.entry.timestamp formattedTimeStyle:NSDateFormatterShortStyle];
}

- (void)updateProgress {
    self.progressViewWidthConstraint.constant = self.entry.progress * self.statusViewWidthConstraint.constant;
}

- (void)updateStatusDate {
    self.dateLabelInStatusView.text = nil;
    
    if (self.entry.state == EntryStateActive) {
        if ([self.entry.todo.startDate daysFromToday] > kFrostyDaysBeforeStartDate) {
            self.dateLabelInStatusView.nuiClass = @"StartDate";
            self.dateLabelInStatusView.text = [self.entry.todo.startDate formattedDatePattern:@"M/d"];
        } else if ([self.entry.todo.dueDate daysFromToday] > kUrgentDaysBeforeDueDate) {
            self.dateLabelInStatusView.nuiClass = @"DueDate";
            self.dateLabelInStatusView.text = [self.entry.todo.dueDate formattedDatePattern:@"M/d"];
        }
        
        [self.dateLabelInStatusView applyNUI];
    }
    
    self.dateLabelInProgressView.text = self.dateLabelInStatusView.text;
}

- (void)updateStatusColor {
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
    } else {
        self.statusView.backgroundColor = [NUISettings getColor:@"background-color" withClass:@"TemperatureNone"];
    }
}

- (void)updateStatus {
    [self updateStatusDate];
    [self updateProgress];
    [self updateStatusColor];
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
    self.editing = YES;
    self.timeLabel.hidden = YES;
    self.temperatureView.hidden = NO;
    self.temperatureViewHeightConstraint.constant = 30;
    [self.journalViewController textViewDidBeginEditing:textView];
}

- (void)textViewDidEndEditing:(UITextView *)textView {
    self.editing = NO;
    self.timeLabel.hidden = NO;
    self.temperatureView.hidden = YES;
    self.temperatureViewHeightConstraint.constant = 0;
    [self.journalViewController textViewDidEndEditing:textView];
}

@end
