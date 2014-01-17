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
    
    self.titleTextView.attributedText = [self titleForTodo:todo];
    self.titleTextView.nuiClass = [NSString stringWithFormat:@"todo %@", [self styleClassForTodo:todo]];
    self.lastEntryDateLabel.text = [todo.lastEntryDate formattedDatePattern:@"M/d"];
    self.lastEntryTypeLabel.text = [self entryTypeString:todo.lastEntryType];
    self.dueDateLabel.text = [self dueDateString:todo.dueDate];
    self.holdDateLabel.text = [self holdDateString:todo.holdDate];
}

@end
