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

@property (nonatomic, retain) NSString *title;
@property (nonatomic) int16_t importance;
@property (nonatomic) int16_t urgency;
@property (nonatomic) NSDate *dueDate;
@property (nonatomic) NSDate *startDate;
@property (nonatomic) NSDate *createDate;
@property (nonatomic) BOOL star;
@property (nonatomic, retain) Journal *journal;

@end
