//
//  Styles.h
//  Kuriku
//
//  Created by Tony Mann on 12/20/13.
//  Copyright (c) 2013 7Actions. All rights reserved.
//

#import <Foundation/Foundation.h>
@class Entry, Todo;

//NSString *todoFontName(Todo *todo);
//CGFloat todoFontSize(Todo *todo);
//UIColor *todoTextColor(Todo *todo);
//NSString *entryFontName(Entry *entry);
//NSDictionary *addCompletedAttribute(NSDictionary* attributes);

NSAttributedString *todoTitleString(Todo *todo);
NSAttributedString *entryTitleString(Entry *entry);
