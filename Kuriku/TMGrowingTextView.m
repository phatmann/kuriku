//
//  TMGrowingTextView.m
//  Kuriku
//
//  Created by Tony Mann on 1/6/14.
//  Copyright (c) 2014 7Actions. All rights reserved.
//

#import "TMGrowingTextView.h"

@implementation TMGrowingTextView

- (id)init {
    self = [super init];
    [self setup];
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    [self setup];
    return self;
}

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    [self setup];
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame textContainer:(NSTextContainer *)textContainer {
    self = [super initWithFrame:frame textContainer:textContainer];
    [self setup];
    return self;
}

- (void)setup {
    self.textContainerInset = UIEdgeInsetsMake(0, -4, 0, -4);
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    if (!CGSizeEqualToSize(self.bounds.size, [self intrinsicContentSize])) {
        [self invalidateIntrinsicContentSize];
    }
}

- (CGSize)intrinsicContentSize
{
    CGSize intrinsicContentSize =  [self sizeThatFits:self.bounds.size];
    
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0f) {
        intrinsicContentSize.width  += self.textContainerInset.left + self.textContainerInset.right;
        intrinsicContentSize.height += self.textContainerInset.top + self.textContainerInset.bottom;
    }
    
    return intrinsicContentSize;
}

@end