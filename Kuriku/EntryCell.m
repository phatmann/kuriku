//
//  EntryCell.m
//  Kuriku
//
//  Created by Tony Mann on 12/14/13.
//  Copyright (c) 2013 7Actions. All rights reserved.
//

#import "EntryCell.h"
#import "Entry.h"

@interface EntryCell ()
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@end

@implementation EntryCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setEntry:(Entry *)entry
{
    _entry = entry;
    
    NSMutableAttributedString *title = [[NSMutableAttributedString alloc]
                                        initWithString:self.entry.title
                                        attributes:@{}];
    
    NSString *subtitle = [NSString stringWithFormat:@"  %d %d", entry.urgency, entry.importance];
    
    [title appendAttributedString:[[NSAttributedString alloc]
                                   initWithString:subtitle
                                   attributes:@{NSFontAttributeName: [UIFont systemFontOfSize:10]}]];

    
    self.titleLabel.attributedText = title;
}

@end
