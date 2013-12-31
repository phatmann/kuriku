//
//  Styles.m
//  Kuriku
//
//  Created by Tony Mann on 12/20/13.
//  Copyright (c) 2013 7Actions. All rights reserved.
//

#import "Styles.h"
#import "Entry.h"
#import "Todo.h"
#import <InnerBand/InnerBand.h>

static NSString *baseFontName = @"Helvetica Neue";

UIFontDescriptor *fontDescriptorFromTraits(UIFontDescriptorSymbolicTraits fontTraits);
void appendDueDate(Todo *todo, NSMutableAttributedString *title);

CGFloat todoFontSize(Todo *todo) {
    return (todo.importance * 2) + 15;
}

UIFontDescriptorSymbolicTraits todoFontTraits(Todo *todo) {
    UIFontDescriptorSymbolicTraits fontTraits = 0;
    
    if (todo.commitment == TodoCommitmentToday)
        fontTraits |= UIFontDescriptorTraitBold;
    
    return fontTraits;
}

UIFontDescriptorSymbolicTraits entryFontTraits(Entry *entry) {
    UIFontDescriptorSymbolicTraits fontTraits = todoFontTraits(entry.todo);
    
    //if (entry.type == EntryTypeCreateTodo)
        //fontTraits |= UIFontDescriptorTraitBold;
    
    return fontTraits;
}

UIColor *todoTextColor(Todo *todo) {
    CGFloat hue = (50 - (todo.urgency * 50 / TodoRangeMaxValue))/360.0;
    
    if (todo.commitment == TodoCommitmentMaybe)
        return [UIColor colorWithWhite:0.5 alpha:1.0];
    
    return (todo.urgency > 0) ? [UIColor colorWithHue:hue saturation:1.0 brightness:1.0 alpha:1.0] : [UIColor blackColor];
}

UIFont *todoFont(Todo *todo) {
    UIFontDescriptor *fontDescriptor = fontDescriptorFromTraits(todoFontTraits(todo));
    return [UIFont fontWithDescriptor:fontDescriptor size:todoFontSize(todo)];
}

UIFont *entryFont(Entry *entry) {
    UIFontDescriptor *fontDescriptor = fontDescriptorFromTraits(entryFontTraits(entry));
    return [UIFont fontWithDescriptor:fontDescriptor size:todoFontSize(entry.todo)];
}

NSAttributedString *todoTitleString(Todo *todo) {
    NSMutableDictionary *attributes = [@{NSFontAttributeName:todoFont(todo), NSForegroundColorAttributeName:todoTextColor(todo)} mutableCopy];
    
    switch (todo.status) {
        case TodoStatusCompleted:
            attributes[NSStrikethroughStyleAttributeName] = @(NSUnderlineStyleSingle);
            break;
            
        case TodoStatusOnHold:
            attributes[NSUnderlineStyleAttributeName] = @(NSUnderlineStyleSingle | NSUnderlinePatternDot);
            break;
    }
    
    NSMutableAttributedString *title = [[NSMutableAttributedString alloc] initWithString:todo.title attributes:attributes];
    appendDueDate(todo, title);
    
    return title;
}

NSAttributedString *entryTitleString(Entry *entry) {
    NSMutableDictionary *attributes = [@{NSFontAttributeName:entryFont(entry), NSForegroundColorAttributeName:todoTextColor(entry.todo)} mutableCopy];
    
    if (entry.type == EntryTypeHold) {
        attributes[NSUnderlineStyleAttributeName] = @(NSUnderlineStyleSingle | NSUnderlinePatternDot);
    } else {
        if (entry.status == EntryStatusInactive)
            attributes[NSStrikethroughStyleAttributeName] = @(NSUnderlineStyleSingle);
    }
    
    NSMutableAttributedString *title = [[NSMutableAttributedString alloc] initWithString:entry.todo.title attributes:attributes];
    appendDueDate(entry.todo, title);
    return title;
}

void appendDueDate(Todo *todo, NSMutableAttributedString *title) {
    if (todo.dueDate) {
        UIFontDescriptor *fontDescriptor = fontDescriptorFromTraits(UIFontDescriptorTraitItalic);
        UIFont *font = [UIFont fontWithDescriptor:fontDescriptor size:todoFontSize(todo) - 6];
        
        NSAttributedString* dateString = [[NSAttributedString alloc]
                                          initWithString:[todo.dueDate formattedDatePattern:@"  M/d"]
                                              attributes:@{NSFontAttributeName:font, NSForegroundColorAttributeName:todoTextColor(todo)}];
        [title appendAttributedString:dateString];
    }
}

#pragma mark -

UIFontDescriptor *fontDescriptorFromTraits(UIFontDescriptorSymbolicTraits fontTraits) {
    UIFontDescriptor *fontDescriptor = [[UIFontDescriptor alloc] init];
    fontDescriptor = [fontDescriptor fontDescriptorWithFamily:baseFontName];
    return [fontDescriptor fontDescriptorWithSymbolicTraits:fontTraits];
}
