//
//  RepeatViewController.h
//  Kuriku
//
//  Created by Tony Mann on 12/29/13.
//  Copyright (c) 2013 7Actions. All rights reserved.
//

#import <UIKit/UIKit.h>

@class RepeatViewController;

@protocol RepeatViewControllerDelegate <NSObject>

- (void)repeatViewControllerDaysChanged:(RepeatViewController *)repeatViewController;

@end

@interface RepeatViewController : UITableViewController

@property (nonatomic) NSInteger days;
@property (nonatomic, weak) id<RepeatViewControllerDelegate> delegate;

@end
