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

static NSString *baseFontName = @"HelveticaNeue";

NSString *todoFontName(Todo *todo) {
    return todo.urgency > 0 ? [baseFontName stringByAppendingString:@"-Bold"] : baseFontName;
}

CGFloat todoFontSize(Todo *todo) {
    return (todo.importance * 1.5) + 13;
}

UIColor *todoTextColor(Todo *todo) {
    CGFloat hue = (50 - (todo.urgency * 50 / TodoUrgencyMaxValue))/360.0;
    return (todo.urgency > 0) ? [UIColor colorWithHue:hue saturation:1.0 brightness:1.0 alpha:1.0] : [UIColor blackColor];
}

NSString *entryFontName(Entry *entry) {
    if (entry.type == EntryTypeCompleteTodo && entry.todo.urgency > 0)
        return [baseFontName stringByAppendingString:@"-BoldItalic"];
    
    if (entry.todo.urgency > 0)
        return [baseFontName stringByAppendingString:@"-Bold"];
    
    if (entry.type == EntryTypeCompleteTodo)
        return [baseFontName stringByAppendingString:@"-Italic"];
    
    return baseFontName;
}

NSDictionary *addCompletedAttribute(NSDictionary* attributes) {
    NSMutableDictionary *completedAttributes = [NSMutableDictionary dictionaryWithDictionary:attributes];
    completedAttributes[NSStrikethroughStyleAttributeName] = @(NSUnderlineStyleSingle);
    return completedAttributes;
}

NSAttributedString *todoTitleString(Todo *todo) {
    UIFont *font = [UIFont fontWithName:todoFontName(todo) size:todoFontSize(todo)];
    
    NSDictionary *attributes = @{NSFontAttributeName:font, NSForegroundColorAttributeName:todoTextColor(todo)};
    
    if (todo.status == TodoStatusCompleted) {
        attributes = addCompletedAttribute(attributes);
    }
    
    return [[NSAttributedString alloc] initWithString:todo.title attributes:attributes];
}

NSAttributedString *entryTitleString(Entry *entry) {
    UIFont *font = [UIFont fontWithName:entryFontName(entry) size:todoFontSize(entry.todo)];
    
    NSDictionary *attributes = @{NSFontAttributeName:font, NSForegroundColorAttributeName:todoTextColor(entry.todo)};
    
    if (entry.type == EntryTypeCompleteTodo) {
        attributes = addCompletedAttribute(attributes);
    }
    
    return [[NSAttributedString alloc] initWithString:entry.todo.title attributes:attributes];
}
