//
//  EntryViewController.m
//  Kuriku
//
//  Created by Tony Mann on 12/13/13.
//  Copyright (c) 2013 7Actions. All rights reserved.
//

#import "EntryViewController.h"
#import "Entry.h"
#import <InnerBand/InnerBand.h>

@interface EntryViewController ()

@property (weak, nonatomic) IBOutlet UITextField *titleField;

@end

@implementation EntryViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
    
- (IBAction)cancelButtonWasTapped:(UIBarButtonItem *)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}
    
- (IBAction)saveButtonWasTapped:(UIBarButtonItem *)sender {
    Entry *entry = [Entry create];
    entry.title = self.titleField.text;
    [[IBCoreDataStore mainStore] save];
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
