//
//  TodoCell.m
//  Kuriku
//
//  Created by Tony Mann on 12/14/13.
//  Copyright (c) 2013 7Actions. All rights reserved.
//

#import "TodoCell.h"
#import "Todo.h"
#import <InnerBand/InnerBand.h>

@interface TodoCell ()
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *urgencyLabel;
@property (weak, nonatomic) IBOutlet UILabel *importanceLabel;
@property (weak, nonatomic) IBOutlet UILabel *lastActionDateLabel;
@end

@implementation TodoCell

- (void)setTodo:(Todo *)todo
{
    _todo = todo;
    
    NSDictionary *attributes = todo.status == TodoStatusNormal ?
        @{} : @{NSStrikethroughStyleAttributeName:@(NSUnderlineStyleSingle)};
    
    self.titleLabel.attributedText = [[NSAttributedString alloc] initWithString:todo.title attributes:attributes];
    
    self.urgencyLabel.text = [@(todo.urgency) stringValue];
    self.importanceLabel.text = [@(todo.importance) stringValue];
    self.lastActionDateLabel.text = [todo.lastActionDate formattedDatePattern:@"M/d"];
}

@end
