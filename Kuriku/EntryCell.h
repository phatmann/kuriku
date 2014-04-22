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
@property (weak, nonatomic) JournalViewController *journalViewController;

- (void)refresh;
- (void)temperatureWasChanged;
- (void)importanceWasChanged;
+ (CGFloat)fontSizeForImportance:(CGFloat)importance;

@end
