//
//  EntryCell.h
//  Kuriku
//
//  Created by Tony Mann on 12/14/13.
//  Copyright (c) 2013 7Actions. All rights reserved.
//

#import "Entry.h"

@class JournalViewController;

@interface EntryCell : UITableViewCell

@property (strong, nonatomic) Entry *entry;
@property (nonatomic) BOOL isEditing;
@property (weak, nonatomic) JournalViewController *journalViewController;

- (void)refresh;

@end
