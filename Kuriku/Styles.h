//
//  Styles.h
//  Kuriku
//
//  Created by Tony Mann on 12/20/13.
//  Copyright (c) 2013 7Actions. All rights reserved.
//

#import <Foundation/Foundation.h>
@class Entry, Todo;

CGFloat todoFontSize(Todo *todo);
NSAttributedString *todoTitleString(Todo *todo);
NSAttributedString *entryTitleString(Entry *entry);
