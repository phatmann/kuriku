//
//  EntryCell.h
//  Kuriku
//
//  Created by Tony Mann on 12/14/13.
//  Copyright (c) 2013 7Actions. All rights reserved.
//

#import "ListCell.h"

@class Entry;

@interface EntryCell : ListCell

@property (strong, nonatomic) Entry *entry;

@end
