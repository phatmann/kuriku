//
//  NSDate+Kuriku.h
//  Kuriku
//
//  Created by Tony Mann on 4/17/14.
//  Copyright (c) 2014 7Actions. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDate (Kuriku)
- (int)daysFromToday;
+ (NSDate *)today;
- (NSDate *)dateAtStartOfDay;
+ (NSDate *)dateFromTodayWithDays:(int)days;
+ (NSDate *)dateFromString:(NSString *)dateString withFormat:(NSDateFormatterStyle)dateStyle;
+ (NSDate *)dateFromString:(NSString *)dateString withPattern:(NSString *)datePattern;

@end
