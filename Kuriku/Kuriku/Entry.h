//
//  Entry.h
//  Kuriku
//
//  Created by Tony Mann on 12/11/13.
//  Copyright (c) 2013 7Actions. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Journal;

@interface Entry : NSManagedObject

@property (nonatomic, retain) NSString * title;
@property (nonatomic) int16_t importance;
@property (nonatomic) int16_t urgency;
@property (nonatomic) NSTimeInterval dueDate;
@property (nonatomic) NSTimeInterval startDate;
@property (nonatomic) BOOL star;
@property (nonatomic, retain) Journal *journal;

@end
