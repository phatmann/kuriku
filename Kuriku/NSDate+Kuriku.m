//
//  NSDate+Kuriku.m
//  Kuriku
//
//  Created by Tony Mann on 4/17/14.
//  Copyright (c) 2014 7Actions. All rights reserved.
//

#import "NSDate+Kuriku.h"
#import <InnerBand/InnerBand.h>

static const NSTimeInterval kSecondsInDay = 24 * 60 * 60;

@implementation NSDate (Kuriku)

- (int)daysFromToday {
    return (int)roundf([self timeIntervalSinceDate:[NSDate today]] / kSecondsInDay);
}

+ (NSDate *)dateFromTodayWithDays:(int)days {
    return [[NSDate dateWithTimeIntervalSinceNow:kSecondsInDay * days] dateAtStartOfDay];
}

@end