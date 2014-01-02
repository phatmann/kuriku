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

CGFloat todoFontSize(Todo *todo) {
    return (todo.importance * 2) + 13;
}

CGFloat entryFontSize(Entry *entry) {
    return (entry.status == EntryStatusClosed) ?
        17 : todoFontSize(entry.todo);
}

UIFontDescriptorSymbolicTraits todoFontTraits(Todo *todo) {
    UIFontDescriptorSymbolicTraits fontTraits = 0;
    
    if (todo.commitment == TodoCommitmentToday)
        fontTraits |= UIFontDescriptorTraitBold;
    
    return fontTraits;
}

UIFontDescriptorSymbolicTraits entryFontTraits(Entry *entry) {
    UIFontDescriptorSymbolicTraits fontTraits = (entry.status == EntryStatusClosed) ?
        0 : todoFontTraits(entry.todo);
    
    return fontTraits;
}

UIColor *todoTextColor(Todo *todo) {
    CGFloat hue = (50 - (todo.urgency * 50 / TodoRangeMaxValue))/360.0;
    
    if (todo.commitment == TodoCommitmentMaybe)
        return [UIColor colorWithWhite:0.5 alpha:1.0];
    
    return (todo.urgency > 0) ? [UIColor colorWithHue:hue saturation:1.0 brightness:1.0 alpha:1.0] : [UIColor blackColor];
}

UIColor *entryTextColor(Entry *entry) {
    return (entry.status == EntryStatusClosed) ? [UIColor blackColor] : todoTextColor(entry.todo);
}

UIFont *todoFont(Todo *todo) {
    UIFontDescriptor *fontDescriptor = fontDescriptorFromTraits(todoFontTraits(todo));
    return [UIFont fontWithDescriptor:fontDescriptor size:todoFontSize(todo)];
}

UIFont *entryFont(Entry *entry) {
    UIFontDescriptor *fontDescriptor = fontDescriptorFromTraits(entryFontTraits(entry));
    return [UIFont fontWithDescriptor:fontDescriptor size:entryFontSize(entry)];
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
    
    return title;
}

NSAttributedString *entryTitleString(Entry *entry) {
    NSMutableDictionary *attributes = [@{NSFontAttributeName:entryFont(entry), NSForegroundColorAttributeName:entryTextColor(entry)} mutableCopy];
    
    switch (entry.status) {
        case EntryStatusClosed:
            attributes[NSStrikethroughStyleAttributeName] = @(NSUnderlineStyleSingle);
            break;
            
        case EntryStatusHold:
            attributes[NSUnderlineStyleAttributeName] = @(NSUnderlineStyleSingle | NSUnderlinePatternDot);
            break;
            
        default:
            break;
    }
    
    NSMutableAttributedString *title = [[NSMutableAttributedString alloc] initWithString:entry.todo.title attributes:attributes];
    return title;
}

#pragma mark -

UIFontDescriptor *fontDescriptorFromTraits(UIFontDescriptorSymbolicTraits fontTraits) {
    UIFontDescriptor *fontDescriptor = [[UIFontDescriptor alloc] init];
    fontDescriptor = [fontDescriptor fontDescriptorWithFamily:baseFontName];
    return [fontDescriptor fontDescriptorWithSymbolicTraits:fontTraits];
}
