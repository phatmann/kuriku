//
//  GlowingTextView.m
//  Kuriku
//
//  Created by Tony Mann on 1/6/14.
//  Copyright (c) 2014 7Actions. All rights reserved.
//

#import "GlowingTextView.h"

static const CGSize   kShadowOffset = {0, 0};
static const CGFloat  kCornerRadius = 3;

@implementation GlowingTextView

- (id)init {
    self = [super init];
    
    if (self)
        [self setup];
        
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self)
        [self setup];
    return self;
}

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self)
        [self setup];
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame textContainer:(NSTextContainer *)textContainer {
    self = [super initWithFrame:frame textContainer:textContainer];
    if (self)
        [self setup];
    return self;
}

- (void)setup {
    self.textContainerInset = UIEdgeInsetsMake(4, 4, -4, -4);
}

- (void)setGlowColor:(UIColor *)color {
    _glowColor = color;
    [self setNeedsDisplay];
}

- (void)setGlowBlur:(CGFloat)glowBlur {
    _glowBlur = glowBlur;
    [self setNeedsDisplay];
}

- (void)drawRect:(CGRect)rect {
    [super drawRect:rect];
    
    if (!self.glowColor)
        return;
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGRect glowRect = self.bounds;
    UIBezierPath* path = [UIBezierPath bezierPathWithRoundedRect:glowRect cornerRadius:kCornerRadius];
    
    CGRect borderRect = CGRectInset(path.bounds, -self.glowBlur, -self.glowBlur);
    borderRect = CGRectOffset(borderRect, -kShadowOffset.width, -kShadowOffset.height);
    borderRect = CGRectInset(CGRectUnion(borderRect, path.bounds), -1, -1);
    
    UIBezierPath* negativePath = [UIBezierPath bezierPathWithRect: borderRect];
    [negativePath appendPath: path];
    negativePath.usesEvenOddFillRule = YES;
    
    CGContextSaveGState(context);
    CGFloat xOffset = kShadowOffset.width + round(borderRect.size.width);
    CGFloat yOffset = kShadowOffset.height;
    CGContextSetShadowWithColor(context, CGSizeMake(xOffset + copysign(0.1, xOffset), yOffset + copysign(0.1, yOffset)), self.glowBlur, self.glowColor.CGColor);
    
    [path addClip];
    CGAffineTransform transform = CGAffineTransformMakeTranslation(-round(borderRect.size.width), 0);
    [negativePath applyTransform: transform];
    [[UIColor grayColor] setFill];
    [negativePath fill];
    
    CGContextRestoreGState(context);
}

- (CGSize)sizeThatFits:(CGSize)size {
    CGSize contentSize = [super sizeThatFits:size];
    
    contentSize.width  += self.textContainerInset.left - self.textContainerInset.right;
    contentSize.height += self.textContainerInset.top - self.textContainerInset.bottom;
    
    return contentSize;
}

@end
