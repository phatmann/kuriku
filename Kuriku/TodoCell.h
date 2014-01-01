//
//  TodoCell.h
//  Kuriku
//
//  Created by Tony Mann on 12/14/13.
//  Copyright (c) 2013 7Actions. All rights reserved.
//

#import "ListCell.h"

@class Todo;

@interface TodoCell : ListCell

@property (strong, nonatomic) Todo *todo;

@end
