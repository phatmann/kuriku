//
//  GradientBar.h
//  Kuriku
//
//  Created by Tony Mann on 4/24/14.
//  Copyright (c) 2014 7Actions. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GradientBar : UIView
@property (strong, nonatomic) UIColor *startColor;
@property (strong, nonatomic) UIColor *endColor;
@property (nonatomic) CGFloat value;
@end
