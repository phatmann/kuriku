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
@property (weak, nonatomic) IBOutlet UIView *temperatureView;
@property (weak, nonatomic) IBOutlet UISlider *temperatureSlider;
@property (weak, nonatomic) IBOutlet UIButton *statusButton;
@property (weak, nonatomic) IBOutlet UIButton *startDateButton;
@property (weak, nonatomic) IBOutlet UIButton *dueDateButton;
@property (weak, nonatomic) IBOutlet UILabel *startDateLabel;
@property (weak, nonatomic) IBOutlet UILabel *dueDateLabel;
@property (weak, nonatomic) IBOutlet GradientBar *urgencyBar;
@property (weak, nonatomic) IBOutlet GradientBar *frostinessBar;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *temperatureViewHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *progressViewWidthConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *statusViewWidthConstraint;

@property (strong, nonatomic) UIPanGestureRecognizer *panGestureRecognizer;
@property (strong, nonatomic) UILongPressGestureRecognizer *longPressGestureRecognizer;

@end

typedef NS_ENUM(int, PanType) {
    PanTypeNone,
    PanTypeUrgency,
    PanTypeFrostiness
};

@implementation EntryCell
{
    CGFloat _panInitialValue;
    PanType _panType;
}

- (void)awakeFromNib {
    UIImage *thumbImage = [UIImage imageNamed:@"slider-thumb"];
    [self.temperatureSlider setThumbImage:thumbImage forState:UIControlStateNormal];
    [self.temperatureSlider setThumbImage:thumbImage forState:UIControlStateHighlighted];
    self.temperatureViewHeightConstraint.constant = 0;
    
    self.panGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(cellWasPanned:)];
    self.panGestureRecognizer.delegate = self;
    self.panGestureRecognizer.maximumNumberOfTouches = 1;
    [self addGestureRecognizer:self.panGestureRecognizer];
    
    self.longPressGestureRecognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(cellWasLongPressed:)];
    [self addGestureRecognizer:self.longPressGestureRecognizer];
    
    self.frostinessBar.startColor = [NUISettings getColor:@"background-color" withClass:@"TemperatureCold"];
    self.frostinessBar.endColor   = [NUISettings getColor:@"background-color" withClass:@"TemperatureCool"];
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

- (void)temperatureWasChanged {
    [self updateStatus];
    [self updateDateButtons];
    [self updateTemperatureSlider];
}

- (void)importanceWasChanged {
    [self updateTitle];
    [self updateStatus];
}

- (IBAction)statusButtonWasTapped {
    //[self.journalViewController statusWasTappedForCell:self];
}

//- (IBAction)temperatureSliderWasChanged {
//    if (self.temperatureSlider.value > -0.02 && self.temperatureSlider.value < 0.02)
//        self.temperatureSlider.value = 0;
//    
//    self.entry.todo.temperature = self.temperatureSlider.value;
//    [self updateDateButtons];
//    [self updateStatus];
//}

- (void)cellWasPanned:(UIPanGestureRecognizer *)panGestureRecognizer {
    switch (panGestureRecognizer.state) {
        case UIGestureRecognizerStateBegan:
            break;
            
        case UIGestureRecognizerStateChanged:
            {
                CGPoint offset = [panGestureRecognizer translationInView:self];
                
                if (_panType == PanTypeNone) {
                    if (fabs(offset.x) < 5) {
                        if (fabs(offset.y) > 5) {
                            self.panGestureRecognizer.enabled = NO;
                            self.panGestureRecognizer.enabled = YES;
                        }
                        return;
                    }
                    
                    CGPoint pt = [panGestureRecognizer locationOfTouch:0 inView:self];
                    _panType = (pt.x < self.bounds.size.width / 2) ? PanTypeUrgency : PanTypeFrostiness;
                    
                    if (_panType == PanTypeUrgency && self.entry.todo.dueDate) {
                        _panInitialValue = self.entry.todo.urgency;
                    } else if (_panType == PanTypeFrostiness && self.entry.todo.startDate) {
                        _panInitialValue = self.entry.todo.frostiness;
                    } else {
                        _panInitialValue = 0.0f;
                    }
                }
                
                //if (_panType == PanTypeFrostiness)
                    //offset.x = -offset.x;
            
                CGFloat range = self.bounds.size.width / 4;
                CGFloat newValue = MAX(0.0f, MIN(1.0f, ((_panInitialValue * range) + offset.x) / range));
            
                if (_panType == PanTypeFrostiness)
                    self.entry.todo.frostiness = newValue;
                else
                    self.entry.todo.urgency = newValue;
            
                [self temperatureWasChanged];
            }
            break;
        
        case UIGestureRecognizerStateEnded:
        case UIGestureRecognizerStateCancelled:
        case UIGestureRecognizerStatePossible:
        case UIGestureRecognizerStateFailed:
            _panType = PanTypeNone;
            break;
    }
}

- (void)cellWasLongPressed:(UILongPressGestureRecognizer *)longPressGestureRecognizer {
    if (longPressGestureRecognizer.state == UIGestureRecognizerStateBegan) {
        CGPoint pt = [longPressGestureRecognizer locationInView:self.titleTextView];
        
        if (CGRectContainsPoint(self.titleTextView.bounds, pt))
            [self.titleTextView becomeFirstResponder];
        else
            [self.journalViewController statusWasTappedForCell:self];
    }
}

#pragma mark -

- (void)updateTemperatureSlider {
    if (self.entry.todo.dueDate)
        self.temperatureSlider.value = self.entry.todo.urgency;
    else if (self.entry.todo.startDate)
        self.temperatureSlider.value = -self.entry.todo.frostiness;
    else
        self.temperatureSlider.value = 0;
}

- (void)updateDateButtons {
    // TODO: factor out common code
    
    if (self.entry.todo.startDate) {
        self.startDateButton.hidden = NO;
        self.startDateLabel.hidden  = NO;
        int days = [self.entry.todo.startDate daysFromToday];
        
        if (days == 0)
            [self.startDateButton setTitle:@"now" forState:UIControlStateNormal];
        else if (days == 1)
            [self.startDateButton setTitle:@"1 day" forState:UIControlStateNormal];
        else if (days <= kFrostyDaysBeforeStartDate)
            [self.startDateButton setTitle:[NSString stringWithFormat:@"%d days", days] forState:UIControlStateNormal];
        else
            [self.startDateButton setTitle:[self.entry.todo.startDate formattedDatePattern:@"M/d"] forState:UIControlStateNormal];
    } else {
        self.startDateButton.hidden = YES;
        self.startDateLabel.hidden  = YES;
    }
    
    if (self.entry.todo.dueDate) {
        self.dueDateButton.hidden = NO;
        self.dueDateLabel.hidden  = NO;
        int days = [self.entry.todo.dueDate daysFromToday];
        
        if (days == 0)
            [self.dueDateButton setTitle:@"now" forState:UIControlStateNormal];
        else if (days == 1)
            [self.dueDateButton setTitle:@"1 day" forState:UIControlStateNormal];
        else if (days <= kUrgentDaysBeforeDueDate)
            [self.dueDateButton setTitle:[NSString stringWithFormat:@"%d days", days] forState:UIControlStateNormal];
        else
            [self.dueDateButton setTitle:[self.entry.todo.dueDate formattedDatePattern:@"M/d"] forState:UIControlStateNormal];
    } else {
        self.dueDateButton.hidden = YES;
        self.dueDateLabel.hidden  = YES;
        [self.dueDateButton setTitle:nil forState:UIControlStateNormal];
    }
}

- (void)updateTime {
    self.timeLabel.text = [self.entry.timestamp formattedTimeStyle:NSDateFormatterShortStyle];
}

- (void)updateProgress {
    self.progressViewWidthConstraint.constant = self.entry.progress * self.statusViewWidthConstraint.constant;
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

- (void)updateStatusColor {
    if (self.entry.todo.temperature > 0) {
        if (self.entry.todo.dueDate) {
            self.urgencyBar.startColor = [NUISettings getColor:@"background-color" withClass:@"TemperatureWarm"];
            self.urgencyBar.endColor   = [NUISettings getColor:@"background-color" withClass:@"TemperatureHot"];
        } else {
            self.urgencyBar.startColor = [NUISettings getColor:@"background-color" withClass:@"StalenessOld"];
            self.urgencyBar.endColor   = [NUISettings getColor:@"background-color" withClass:@"StalenessVeryOld"];
        }
    
        self.urgencyBar.value = self.entry.todo.temperature;
    } else {
        self.urgencyBar.value = 0;
    }
    
    if (self.entry.todo.temperature < 0)
        self.frostinessBar.value = self.entry.todo.temperature;
    else
        self.frostinessBar.value = 0;
    
    return;
    
    if (self.entry.state == EntryStateActive && self.entry.type != EntryTypeComplete) {
        if (self.entry.todo.temperature > 0) {
            if (self.entry.todo.dueDate) {
                static UIColor *warmColor, *hotColor;
                if (!warmColor) {
                    warmColor = [NUISettings getColor:@"background-color" withClass:@"TemperatureWarm"];
                    hotColor  = [NUISettings getColor:@"background-color" withClass:@"TemperatureHot"];
                }
                
                self.statusView.backgroundColor = [EntryCell scale:self.entry.todo.temperature fromColor:warmColor toColor:hotColor];
            } else {
                static UIColor *oldColor, *veryOldColor;
                if (!oldColor) {
                    oldColor     = [NUISettings getColor:@"background-color" withClass:@"StalenessOld"];
                    veryOldColor = [NUISettings getColor:@"background-color" withClass:@"StalenessVeryOld"];
                }
                
                self.statusView.backgroundColor = [EntryCell scale:self.entry.todo.temperature fromColor:oldColor toColor:veryOldColor];
            }
        } else if (self.entry.todo.temperature < 0) {
            static UIColor *coolColor, *coldColor;
            
            if (!coolColor) {
                coolColor = [NUISettings getColor:@"background-color" withClass:@"TemperatureCool"];
                coldColor = [NUISettings getColor:@"background-color" withClass:@"TemperatureCold"];
            }
            
            self.statusView.backgroundColor = [EntryCell scale:-self.entry.todo.temperature fromColor:coolColor toColor:coldColor];
        } else {
            self.statusView.backgroundColor = [NUISettings getColor:@"background-color" withClass:@"TemperatureNone"];
        }
    } else {
        self.statusView.backgroundColor = [NUISettings getColor:@"background-color" withClass:@"TemperatureNone"];
    }
}

- (void)updateStatus {
    [self updateDate];
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

#pragma Text View Delegate

- (void)textViewDidChange:(UITextView *)textView {
    self.entry.todo.title = textView.text;
    [self.journalViewController cell:self textViewDidChange:textView];
}

- (void)textViewDidBeginEditing:(UITextView *)textView {
    //self.editing = YES;
    self.longPressGestureRecognizer.enabled = NO;
    self.titleTextView.userInteractionEnabled = YES;
    //self.timeLabel.hidden = YES;
    //self.temperatureView.hidden = NO;
    //self.temperatureViewHeightConstraint.constant = 30;
    //[self updateStatus];
    [self.journalViewController cell:self textViewDidBeginEditing:textView];
}

- (void)textViewDidEndEditing:(UITextView *)textView {
    //self.editing = NO;
    self.longPressGestureRecognizer.enabled = YES;
    self.titleTextView.userInteractionEnabled = NO;
    //self.timeLabel.hidden = NO;
    //self.temperatureView.hidden = YES;
    //self.temperatureViewHeightConstraint.constant = 0;
    //[self updateStatus];
    
    [self.journalViewController cell:self textViewDidEndEditing:textView];
    
    if (self.entry.todo.title.length > 0)
        [IBCoreDataStore save];
    else
        [self.entry.todo destroy];
}

#pragma mark - Gesture Recognizer Delegate

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    return YES;
}

@end
