//
//  GradientBar.h
//  Kuriku
//
//  Created by Tony Mann on 4/24/14.
//  Copyright (c) 2014 7Actions. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(int, GradientBarType) {
    GradientBarTypeHorizontal,
    GradientBarTypeVertical
};

@interface GradientBar : UIView
@property (strong, nonatomic) UIColor *startColor;
@property (strong, nonatomic) UIColor *endColor;
@property (nonatomic) GradientBarType type;
@property (nonatomic) CGFloat value;
@end
