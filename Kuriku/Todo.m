//
//  Todo.m
//  Kuriku
//
//  Created by Tony Mann on 12/11/13.
//  Copyright (c) 2013 7Actions. All rights reserved.
//

#import "Todo.h"
#import <InnerBand/InnerBand.h>

@interface Todo ()

@end

@implementation Todo

@dynamic importance;
@dynamic urgency;
@dynamic dueDate;
@dynamic startDate;
@dynamic priority;
@dynamic star;
@dynamic status;
@dynamic actions;

- (void)awakeFromInsert {
    [super awakeFromInsert];
}

- (void)didChangeValueForKey:(NSString *)key {
    [super didChangeValueForKey:key];
    
    if ([key isEqualToString:@"urgency"] || [key isEqualToString:@"importance"]) {
        static const int maxValue = 10;
        self.priority = (self.urgency + self.importance) / (maxValue * 2.0f);
    }
}

@end
