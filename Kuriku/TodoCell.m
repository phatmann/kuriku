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
@property (weak, nonatomic) IBOutlet UILabel *lastActionDateLabel;
@end

@implementation TodoCell

- (void)setTodo:(Todo *)todo
{
    _todo = todo;
    self.titleLabel.attributedText = todoTitleString(todo);
    self.lastActionDateLabel.text = todo.lastActionDate ? [todo.lastActionDate formattedDatePattern:@"M/d"] : @"NOT STARTED";
}

@end
