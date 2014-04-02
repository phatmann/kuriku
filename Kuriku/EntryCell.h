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

- (NSString *)entryTypeString:(EntryType)type;
- (NSString *)dueDateString:(NSDate *)dueDate;
- (NSString *)holdDateString:(NSDate *)holdDate;
- (NSString *)styleClassForTodo:(Todo *)todo;
- (NSString *)styleClassForEntry:(Entry *)entry;
- (NSMutableAttributedString *)titleForTodo:(Todo *)todo;
- (NSMutableAttributedString *)titleForEntry:(Entry *)entry;
- (void)refresh;

@end
