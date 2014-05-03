//
//  EntryCell.h
//  Kuriku
//
//  Created by Tony Mann on 12/14/13.
//  Copyright (c) 2013 7Actions. All rights reserved.
//

#import "Entry.h"

@class JournalViewController;

@interface EntryCell : UITableViewCell <UIGestureRecognizerDelegate>

@property (weak, nonatomic) IBOutlet UITextView *titleTextView;
@property (weak, nonatomic) IBOutlet UIImageView *repeatIcon;
@property (strong, nonatomic) Entry *entry;
@property (weak, nonatomic) JournalViewController *journalViewController;
@property (nonatomic) CGFloat progressBarValue;

- (void)refresh;
- (void)importanceWasChanged;
- (void)temperatureWasChanged;
+ (CGFloat)fontSizeForImportance:(CGFloat)importance;

@end
