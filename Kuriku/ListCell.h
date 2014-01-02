//
//  ListCell.h
//  
//
//  Created by Tony Mann on 1/1/14.
//
//

#import <UIKit/UIKit.h>

#import "Entry.h"

@interface ListCell : UITableViewCell

- (NSString *)entryTypeString:(EntryType)type;
- (NSString *)dueDateString:(NSDate *)dueDate;
- (NSString *)holdDateString:(NSDate *)holdDate;
- (NSString *)styleClassForTodo:(Todo *)todo;
- (NSString *)styleClassForEntry:(Entry *)entry;
- (NSMutableAttributedString *)titleForTodo:(Todo *)todo;
- (NSMutableAttributedString *)titleForEntry:(Entry *)entry;

@end
