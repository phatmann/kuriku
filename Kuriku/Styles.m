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

UIFontDescriptor *fontDescriptorFromTraits(UIFontDescriptorSymbolicTraits fontTraits) {
    UIFontDescriptor *fontDescriptor = [[UIFontDescriptor alloc] init];
    fontDescriptor = [fontDescriptor fontDescriptorWithFamily:baseFontName];
    return [fontDescriptor fontDescriptorWithSymbolicTraits:fontTraits];
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

NSDictionary *addStrikethroughAttribute(NSDictionary* attributes) {
    NSMutableDictionary *completedAttributes = [NSMutableDictionary dictionaryWithDictionary:attributes];
    completedAttributes[NSStrikethroughStyleAttributeName] = @(NSUnderlineStyleSingle);
    return completedAttributes;
}

NSAttributedString *todoTitleString(Todo *todo) {
    NSDictionary *attributes = @{NSFontAttributeName:todoFont(todo), NSForegroundColorAttributeName:todoTextColor(todo)};
    
    if (todo.completed) {
        attributes = addStrikethroughAttribute(attributes);
    }
    
    return [[NSAttributedString alloc] initWithString:todo.title attributes:attributes];
}

NSAttributedString *entryTitleString(Entry *entry) {
    NSDictionary *attributes = @{NSFontAttributeName:entryFont(entry), NSForegroundColorAttributeName:todoTextColor(entry.todo)};
    
    if (entry.status == EntryStatusInactive) {
        attributes = addStrikethroughAttribute(attributes);
    }
    
    return [[NSAttributedString alloc] initWithString:entry.todo.title attributes:attributes];
}
