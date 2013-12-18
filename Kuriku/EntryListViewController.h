//
//  EntryListViewController.h
//  
//
//  Created by Tony Mann on 12/16/13.
//
//

#import <UIKit/UIKit.h>
#import <InnerBand/InnerBand.h>

@interface EntryListViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, UIActionSheetDelegate, NSFetchedResultsControllerDelegate>
@property (strong, nonatomic) NSFetchedResultsController *fetchedResultsController;
@end
