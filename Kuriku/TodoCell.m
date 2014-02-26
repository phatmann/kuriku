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
#import <NUI/UITextView+NUI.h>

@interface TodoCell ()

@property (weak, nonatomic) IBOutlet UITextView *titleTextView;
@property (weak, nonatomic) IBOutlet UILabel *lastEntryDateLabel;
@property (weak, nonatomic) IBOutlet UILabel *lastEntryTypeLabel;
@property (weak, nonatomic) IBOutlet UILabel *dueDateLabel;
@property (weak, nonatomic) IBOutlet UILabel *holdDateLabel;

@end

@implementation TodoCell

- (void)setTodo:(Todo *)todo {
    _todo = todo;
    [self refresh];
}

- (void)refresh
{
    self.titleTextView.attributedText = [self titleForTodo:self.todo];
    self.titleTextView.nuiClass = [NSString stringWithFormat:@"Todo:%@", [self styleClassForTodo:self.todo]];
    [self.titleTextView applyNUI];
    self.lastEntryDateLabel.text = [self.todo.lastEntryDate formattedDatePattern:@"M/d"];
    self.lastEntryTypeLabel.text = [self entryTypeString:self.todo.lastEntryType];
    self.dueDateLabel.text = [self dueDateString:self.todo.dueDate];
    self.holdDateLabel.text = [self holdDateString:self.todo.holdDate];
}

@end
