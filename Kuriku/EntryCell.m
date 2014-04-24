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
@property (weak, nonatomic) IBOutlet UIButton *statusButton;
@property (weak, nonatomic) IBOutlet UIButton *startDateButton;
@property (weak, nonatomic) IBOutlet UIButton *dueDateButton;
@property (weak, nonatomic) IBOutlet UILabel *startDateLabel;
@property (weak, nonatomic) IBOutlet UILabel *dueDateLabel;
@property (weak, nonatomic) IBOutlet UIView *urgencyBar;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *temperatureViewHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *progressViewWidthConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *statusViewWidthConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *urgencyBarWidthConstraint;

@property (strong, nonatomic) UIPanGestureRecognizer *panGestureRecognizer;
@property (strong, nonatomic) UILongPressGestureRecognizer *longPressGestureRecognizer;

@end

@implementation EntryCell
{
    CGFloat _temperatureBeforePan;
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
    
    ////////////
    // EXPERIMENT
    
    CAGradientLayer *layer = [CAGradientLayer layer];
    UIColor *warmColor, *hotColor;
    warmColor = [NUISettings getColor:@"background-color" withClass:@"TemperatureWarm"];
    hotColor  = [NUISettings getColor:@"background-color" withClass:@"TemperatureHot"];
    layer.colors = @[(id)[warmColor CGColor],(id)[hotColor CGColor]];
    layer.startPoint = CGPointMake(0.0f, 0.5f);
    layer.endPoint = CGPointMake(1.0f, 0.5f);
    [self.urgencyBar.layer addSublayer:layer];
    
    ////////////
}

- (void)layoutSubviews {
    [super layoutSubviews];
    CAGradientLayer *layer = [self.urgencyBar.layer.sublayers firstObject];
    CGRect frame = self.urgencyBar.bounds;
    frame.size.width = 34;
    layer.frame = frame;
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
            //self.temperatureView.hidden = NO;
            
            if (self.entry.todo.dueDate || self.entry.todo.startDate) {
                _temperatureBeforePan = self.entry.todo.temperature;
            } else {
                _temperatureBeforePan = 0.0f;
            }
            break;
            
        case UIGestureRecognizerStateChanged:
            {
                CGFloat offset = [panGestureRecognizer translationInView:self].x;
                
                static const CGFloat range = 34.0f;
                CGFloat newTemperature = MAX(-1.0f, MIN(1.0f, ((_temperatureBeforePan * range) + offset) / range));
                
                if (newTemperature > -0.1 && newTemperature < 0.1)
                    newTemperature = 0.0f;
                
                self.entry.todo.temperature = newTemperature;
                [self temperatureWasChanged];
            }
            break;
        
        case UIGestureRecognizerStateEnded:
        case UIGestureRecognizerStateCancelled:
            //self.temperatureView.hidden = YES;
            break;
            
        default:
            ;
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
    self.urgencyBarWidthConstraint.constant = 34.0f * fabs(self.entry.todo.temperature);
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
