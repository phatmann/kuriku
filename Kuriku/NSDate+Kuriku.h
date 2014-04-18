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
+ (NSDate *)dateFromTodayWithDays:(int)days;
@end
