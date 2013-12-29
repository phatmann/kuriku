//
//  EditTodoViewController.h
//  Kuriku
//
//  Created by Tony Mann on 12/13/13.
//  Copyright (c) 2013 7Actions. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DatePickerViewController.h"
#import "RepeatViewController.h"

@class Todo;

@protocol EditTodoViewControllerDelegate <NSObject>

- (void)todoWasEdited:(Todo *)todo;

@end

@interface EditTodoViewController : UITableViewController<DatePickerViewControllerDelegate, RepeatViewControllerDelegate>

@property (strong, nonatomic) Todo *todo;
@property (weak, nonatomic) id<EditTodoViewControllerDelegate> delegate;

@end
