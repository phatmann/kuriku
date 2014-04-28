//
//  EntryCell.h
//  Kuriku
//
//  Created by Tony Mann on 12/14/13.
//  Copyright (c) 2013 7Actions. All rights reserved.
//

#import "Entry.h"

@class JournalViewController;

typedef NS_ENUM(int, EntryDragType) {
    EntryDragTypeNone,
    EntryDragTypePending,
    EntryDragTypeUrgency,
    EntryDragTypeFrostiness
};

@interface EntryCell : UITableViewCell <UIGestureRecognizerDelegate>

@property (strong, nonatomic) Entry *entry;
@property (weak, nonatomic) JournalViewController *journalViewController;
@property (nonatomic) EntryDragType dragType;
@property (nonatomic) CGFloat progressBarValue;

- (void)refresh;
- (void)importanceWasChanged;
- (void)statusWasChanged;
+ (CGFloat)fontSizeForImportance:(CGFloat)importance;

@end
