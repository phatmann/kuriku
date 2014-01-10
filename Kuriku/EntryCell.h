//
//  EntryCell.h
//  Kuriku
//
//  Created by Tony Mann on 12/14/13.
//  Copyright (c) 2013 7Actions. All rights reserved.
//

#import "ListCell.h"

@class Entry, JournalViewController;

@interface EntryCell : ListCell

@property (strong, nonatomic) Entry *entry;
@property (nonatomic) BOOL isEditing;
@property (weak, nonatomic) UITableView *tableView;

@end
