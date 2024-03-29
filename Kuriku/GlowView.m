//
//  GlowView.m
//  Kuriku
//
//  Created by Tony Mann on 5/1/14.
//  Copyright (c) 2014 7Actions. All rights reserved.
//

#import "GlowView.h"

@implementation GlowView

static const CGFloat  kBlurRadius   = 13.0f;
static const CGSize   kShadowOffset = {0, 0};
static const CGFloat  kCornerRadius = 3;
static const CGFloat  kInset        = 8;
static const CGSize   kOffset       = {0, 5};

- (void)setGlowColor:(UIColor *)color {
    _glowColor = color;
    [self setNeedsDisplay];
}

- (void)drawRect:(CGRect)rect {
    if (!self.glowColor)
        return;
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGRect glowRect = CGRectOffset(CGRectInset(self.bounds, kInset, kInset), kOffset.width, kOffset.height);
    UIBezierPath* path = [UIBezierPath bezierPathWithRoundedRect:glowRect cornerRadius:kCornerRadius];
 
    CGRect borderRect = CGRectInset(path.bounds, -kBlurRadius, -kBlurRadius);
    borderRect = CGRectOffset(borderRect, -kShadowOffset.width, -kShadowOffset.height);
    borderRect = CGRectInset(CGRectUnion(borderRect, path.bounds), -1, -1);
 
    UIBezierPath* negativePath = [UIBezierPath bezierPathWithRect: borderRect];
    [negativePath appendPath: path];
    negativePath.usesEvenOddFillRule = YES;
 
    CGContextSaveGState(context);
    CGFloat xOffset = kShadowOffset.width + round(borderRect.size.width);
    CGFloat yOffset = kShadowOffset.height;
    CGContextSetShadowWithColor(context, CGSizeMake(xOffset + copysign(0.1, xOffset), yOffset + copysign(0.1, yOffset)), kBlurRadius, self.glowColor.CGColor);
 
    [path addClip];
    CGAffineTransform transform = CGAffineTransformMakeTranslation(-round(borderRect.size.width), 0);
    [negativePath applyTransform: transform];
    [[UIColor grayColor] setFill];
    [negativePath fill];

    CGContextRestoreGState(context);
}

@end
