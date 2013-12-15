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
@property (weak, nonatomic) IBOutlet UISlider *urgencySlider;
@property (weak, nonatomic) IBOutlet UISlider *importanceSlider;

@end

@implementation EntryViewController

- (void)viewDidLoad {
    [super viewDidLoad];
	
    if (!self.entry)
        self.entry = [Entry create];
        
    self.titleField.text        = self.entry.title;
    self.urgencySlider.value    = self.entry.urgency;
    self.importanceSlider.value = self.entry.importance;
    
    [self.titleField becomeFirstResponder];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
    
- (IBAction)cancelButtonWasTapped:(UIBarButtonItem *)sender {
    [self.navigationController popViewControllerAnimated:YES];
}
    
- (IBAction)saveButtonWasTapped:(UIBarButtonItem *)sender {
    self.entry.title      = self.titleField.text;
    self.entry.urgency    = self.urgencySlider.value;
    self.entry.importance = self.importanceSlider.value;
    
    [[IBCoreDataStore mainStore] save];
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)sliderValueChanged:(UISlider *)slider {
    [slider setValue:roundf(slider.value) animated:YES];
}

@end
