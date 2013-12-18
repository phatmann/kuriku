//
//  TodoCell.m
//  Kuriku
//
//  Created by Tony Mann on 12/14/13.
//  Copyright (c) 2013 7Actions. All rights reserved.
//

#import "TodoCell.h"
#import "Todo.h"

@interface TodoCell ()
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@end

@implementation TodoCell

- (void)setTodo:(Todo *)todo
{
    _todo = todo;
    
    NSDictionary *attributes = todo.status == TodoStatusCompleted ?
        @{NSStrikethroughStyleAttributeName:@(NSUnderlineStyleSingle)} : @{};
    
    NSMutableAttributedString *title = [[NSMutableAttributedString alloc]
                                        initWithString:todo.title
                                        attributes:attributes];
    
    NSString *subtitle = [NSString stringWithFormat:@"  %d %d", todo.urgency, todo.importance];
    
    [title appendAttributedString:[[NSAttributedString alloc]
                                   initWithString:subtitle
                                   attributes:@{NSFontAttributeName: [UIFont systemFontOfSize:10]}]];
    
    self.titleLabel.attributedText = title;
}

@end
