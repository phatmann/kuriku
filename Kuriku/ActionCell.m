//
//  ActionCell.m
//  Kuriku
//
//  Created by Tony Mann on 12/14/13.
//  Copyright (c) 2013 7Actions. All rights reserved.
//

#import "ActionCell.h"
#import "Action.h"

@interface ActionCell ()
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@end

@implementation ActionCell

- (void)setAction:(Action *)action
{
    _action = action;
    self.titleLabel.text = action.title;
}

@end
