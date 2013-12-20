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

static NSString *baseFontName = @"Helvetica Neue";

CGFloat todoFontSize(Todo *todo) {
    return (todo.importance * 1.5) + 13;
}

UIFont *todoFont(Todo *todo) {
    UIFontDescriptor *fontDescriptor = [[UIFontDescriptor alloc] init];
    fontDescriptor = [fontDescriptor fontDescriptorWithFamily:baseFontName];
    UIFontDescriptorSymbolicTraits fontTraits = 0;
    
    if (todo.urgency > 0)
        fontTraits |= UIFontDescriptorTraitBold;
    
    fontDescriptor = [fontDescriptor fontDescriptorWithSymbolicTraits:fontTraits];
    return [UIFont fontWithDescriptor:fontDescriptor size:todoFontSize(todo)];
}

UIColor *todoTextColor(Todo *todo) {
    CGFloat hue = (50 - (todo.urgency * 50 / TodoUrgencyMaxValue))/360.0;
    return (todo.urgency > 0) ? [UIColor colorWithHue:hue saturation:1.0 brightness:1.0 alpha:1.0] : [UIColor blackColor];
}

UIFont *entryFont(Entry *entry) {
    UIFontDescriptor *fontDescriptor = [[UIFontDescriptor alloc] init];
    fontDescriptor = [fontDescriptor fontDescriptorWithFamily:baseFontName];
    UIFontDescriptorSymbolicTraits fontTraits = 0;
    
    if (entry.type == EntryTypeCompleteTodo)
        fontTraits |= UIFontDescriptorTraitItalic;
    
    if (entry.todo.urgency > 0)
        fontTraits |= UIFontDescriptorTraitBold;
    
    fontDescriptor = [fontDescriptor fontDescriptorWithSymbolicTraits:fontTraits];
    return [UIFont fontWithDescriptor:fontDescriptor size:todoFontSize(entry.todo)];
}

NSDictionary *addCompletedAttribute(NSDictionary* attributes) {
    NSMutableDictionary *completedAttributes = [NSMutableDictionary dictionaryWithDictionary:attributes];
    completedAttributes[NSStrikethroughStyleAttributeName] = @(NSUnderlineStyleSingle);
    return completedAttributes;
}

NSAttributedString *todoTitleString(Todo *todo) {
    NSDictionary *attributes = @{NSFontAttributeName:todoFont(todo), NSForegroundColorAttributeName:todoTextColor(todo)};
    
    if (todo.status == TodoStatusCompleted) {
        attributes = addCompletedAttribute(attributes);
    }
    
    return [[NSAttributedString alloc] initWithString:todo.title attributes:attributes];
}

NSAttributedString *entryTitleString(Entry *entry) {
    NSDictionary *attributes = @{NSFontAttributeName:entryFont(entry), NSForegroundColorAttributeName:todoTextColor(entry.todo)};
    
    if (entry.type == EntryTypeCompleteTodo) {
        attributes = addCompletedAttribute(attributes);
    }
    
    return [[NSAttributedString alloc] initWithString:entry.todo.title attributes:attributes];
}
