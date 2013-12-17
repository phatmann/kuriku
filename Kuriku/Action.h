//
//  Action.h
//  Kuriku
//
//  Created by Tony Mann on 12/17/13.
//  Copyright (c) 2013 7Actions. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "Entry.h"

@class Todo;

@interface Action : Entry

@property (nonatomic, retain) Todo *todo;

@end
