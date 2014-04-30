//
//  GradientBar.m
//  Kuriku
//
//  Created by Tony Mann on 4/24/14.
//  Copyright (c) 2014 7Actions. All rights reserved.
//

#import "GradientBar.h"
#import "Entry.h"
#import "Todo.h"
#import <NUI/NUISettings.h>

@implementation GradientBar

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
    }
    return self;
}

- (void)setValue:(CGFloat)value {
    _value = value;
    [self setNeedsDisplay];
}

- (void)drawLinearGradient:(CGContextRef)context startColor:(UIColor *)startColor endColor:(UIColor *)endColor type:(GradientBarType)type {
    CGContextSaveGState(context);
    
    NSArray *colors = @[(__bridge id)startColor.CGColor, (__bridge id)endColor.CGColor];
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGFloat locations[] = { 0.0, 1.0 };
    
    CGGradientRef gradient = CGGradientCreateWithColors(colorSpace, (__bridge CFArrayRef) colors, locations);
    
    CGRect clipRect = self.bounds;
    CGRect rect = self.bounds;
    CGPoint startPoint;
    CGPoint endPoint;
    
    if (type == GradientBarTypeHorizontal) {
        startPoint = CGPointMake(CGRectGetMinX(rect), CGRectGetMidY(rect));
        endPoint   = CGPointMake(CGRectGetMaxX(rect), CGRectGetMidY(rect));
        clipRect.size.width *= fabs(self.value);
            
        if (self.value < 0)
            clipRect.origin.x = self.bounds.size.width - clipRect.size.width;
    } else {
        startPoint = CGPointMake(CGRectGetMidX(rect), CGRectGetMaxY(rect));
        endPoint   = CGPointMake(CGRectGetMidX(rect), CGRectGetMinY(rect));
        
        clipRect.size.height *= fabs(self.value);
        
        if (self.value > 0)
            clipRect.origin.y = self.bounds.size.height - clipRect.size.height;
    }
    
    CGContextAddRect(context, clipRect);
    CGContextClip(context);
    CGContextDrawLinearGradient(context, gradient, startPoint, endPoint, 0);
    
    CGContextRestoreGState(context);
    CGGradientRelease(gradient);
    CGColorSpaceRelease(colorSpace);
}

- (void)drawRect:(CGRect)rect {
    if (self.value == 0)
        return;
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    [self drawLinearGradient:context startColor:self.startColor endColor:self.endColor type:self.type];
}

@end
