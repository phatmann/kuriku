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

- (NSDate *)dateAtStartOfDay {
    NSCalendar *_calendar = [NSCalendar currentCalendar];
	NSDateComponents *_datecomp = [_calendar components:(NSYearCalendarUnit| NSMonthCalendarUnit | NSDayCalendarUnit | NSWeekCalendarUnit |  NSHourCalendarUnit | NSMinuteCalendarUnit | NSSecondCalendarUnit | NSWeekdayCalendarUnit | NSWeekdayOrdinalCalendarUnit) fromDate:self];
	_datecomp.hour = 0;
	_datecomp.minute = 0;
	_datecomp.second = 0;
	return [_calendar dateFromComponents:_datecomp];
}

- (int)daysFromToday {
    return (int)roundf([self timeIntervalSinceDate:[NSDate today]] / kSecondsInDay);
}

+ (NSDate *)today {
    return [[NSDate date] dateAtStartOfDay];
}

+ (NSDate *)dateFromTodayWithDays:(int)days {
    return [[NSDate dateWithTimeInterval:kSecondsInDay * days sinceDate:[NSDate today]] dateAtStartOfDay];
}

+ (NSDate *)dateFromString:(NSString *)dateString withFormat:(NSDateFormatterStyle)dateStyle {
    NSDateFormatter *format = [[NSDateFormatter alloc] init];
    
	[format setDateStyle:dateStyle];
	[format setTimeStyle:NSDateFormatterNoStyle];
	
	return [format dateFromString:dateString];
}

+ (NSDate *)dateFromString:(NSString *)dateString withPattern:(NSString *)datePattern {
    NSDateFormatter *format = [[NSDateFormatter alloc] init];
    [format setDateFormat:datePattern];
	return [format dateFromString:dateString];
}

@end