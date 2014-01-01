//
//  TodoCell.m
//  Kuriku
//
//  Created by Tony Mann on 12/14/13.
//  Copyright (c) 2013 7Actions. All rights reserved.
//

#import "TodoCell.h"
#import "Todo.h"
#import "Styles.h"
#import <InnerBand/InnerBand.h>

@interface TodoCell ()
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *lastEntryLabel;
@property (weak, nonatomic) IBOutlet UILabel *dueDateLabel;
@property (weak, nonatomic) IBOutlet UILabel *holdDateLabel;
@end

@implementation TodoCell

- (void)setTodo:(Todo *)todo
{
    _todo = todo;
    self.titleLabel.attributedText = todoTitleString(todo);
    
    NSDate *date;
    NSString *datePrefix;
    
    switch (todo.status) {
        case TodoStatusNormal:
            date = todo.lastEntryDate;
            datePrefix = @"LAST ACTION";
            break;
        case TodoStatusCompleted:
            date = todo.lastEntryDate;
            datePrefix = @"COMPLETED";
            break;
        case TodoStatusOnHold:
            date = todo.holdDate;
            datePrefix = @"ON HOLD UNTIL";
            break;
    }
    
    NSString *dateString = [todo.lastEntryDate formattedDatePattern:@"M/d"];
    NSString *entryTypeString = [self entryTypeString:todo.lastEntryType];
    self.lastEntryLabel.text = [NSString stringWithFormat:@"%@ %@", dateString, entryTypeString];
    self.dueDateLabel.text = [self dueDateString:todo.dueDate];
    self.holdDateLabel.text = [self holdDateString:todo.holdDate];
}

@end
