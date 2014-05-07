//
//  GlowingTextView.h
//  Kuriku
//
//  Created by Tony Mann on 1/6/14.
//  Copyright (c) 2014 7Actions. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GlowingTextView : UITextView
@property (strong, nonatomic) UIColor *glowColor;
@property (nonatomic) CGFloat glowBlur;
@end
