//
//  GradientView.m
//  Kuriku
//
//  Created by Tony Mann on 4/24/14.
//  Copyright (c) 2014 7Actions. All rights reserved.
//

#import "GradientView.h"
#import "Entry.h"
#import "Todo.h"
#import <NUI/NUISettings.h>

@implementation GradientView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
    }
    return self;
}

- (void)setEntry:(Entry *)entry {
    if (_entry) {
        [_entry.todo removeObserver:self forKeyPath:NSStringFromSelector(@selector(temperature))];
    }
    
    _entry = entry;
    [entry.todo addObserver:self forKeyPath:NSStringFromSelector(@selector(temperature)) options:NSKeyValueObservingOptionInitial context:NULL];
}

- (void)dealloc {
    self.entry = nil;
}

- (void)drawLinearGradient:(CGContextRef)context startColor:(UIColor *)startColor endColor:(UIColor *)endColor {
    CGContextSaveGState(context);
    
    CGRect clipRect = self.bounds;
    clipRect.size.width *= self.entry.todo.urgency;
    CGContextAddRect(context, clipRect);
    CGContextClip(context);
    
    NSArray *colors = @[(__bridge id)startColor.CGColor, (__bridge id)endColor.CGColor];
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGFloat locations[] = { 0.0, 1.0 };
    
    CGGradientRef gradient = CGGradientCreateWithColors(colorSpace, (__bridge CFArrayRef) colors, locations);
    
    CGRect rect = self.bounds;
    CGPoint startPoint = CGPointMake(CGRectGetMinX(rect), CGRectGetMidY(rect));
    CGPoint endPoint = CGPointMake(CGRectGetMaxX(rect), CGRectGetMidY(rect));
    
    CGContextDrawLinearGradient(context, gradient, startPoint, endPoint, 0);
    
    CGContextRestoreGState(context);
    CGGradientRelease(gradient);
    CGColorSpaceRelease(colorSpace);
}

- (void)drawRect:(CGRect)rect {
    if (!self.entry.todo.dueDate)
        return;
        
    static UIColor *startColor, *endColor;
    
    if (!startColor) {
        startColor = [NUISettings getColor:@"background-color" withClass:@"TemperatureWarm"];
        endColor  = [NUISettings getColor:@"background-color" withClass:@"TemperatureHot"];
    }
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    [self drawLinearGradient:context startColor:startColor endColor:endColor];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    [self setNeedsDisplay];
}

@end
