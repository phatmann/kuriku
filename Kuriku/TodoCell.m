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

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        UIView *subview = [[NSBundle mainBundle] loadNibNamed:@"TodoCell" owner:self options:nil][0];
        [self.contentView addSubview:subview];
        // TODO: layout subview
    }
    return self;
}

- (void)setTodo:(Todo *)todo
{
    _todo = todo;
    
    NSMutableAttributedString *title = [[NSMutableAttributedString alloc]
                                        initWithString:todo.title
                                        attributes:@{}];
    
    NSString *subtitle = [NSString stringWithFormat:@"  %d %d", todo.urgency, todo.importance];
    
    [title appendAttributedString:[[NSAttributedString alloc]
                                   initWithString:subtitle
                                   attributes:@{NSFontAttributeName: [UIFont systemFontOfSize:10]}]];
    
    self.titleLabel.attributedText = title;
}

@end
