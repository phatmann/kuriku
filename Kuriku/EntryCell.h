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

@property (weak, nonatomic) IBOutlet UIImageView *repeatIcon;
@property (strong, nonatomic) Entry *entry;
@property (weak, nonatomic) JournalViewController *journalViewController;
@property (nonatomic) CGFloat progressBarValue;
@property (nonatomic) CGFloat importance;

- (void)refresh;
- (void)temperatureWasChanged;
+ (UIFont *)fontForEntry:(Entry *)entry;

@end
