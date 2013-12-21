//
//  EditTodoViewController.m
//  Kuriku
//
//  Created by Tony Mann on 12/13/13.
//  Copyright (c) 2013 7Actions. All rights reserved.
//

#import "EditTodoViewController.h"
#import "Todo.h"
#import "Entry.h"
#import <InnerBand/InnerBand.h>

@interface EditTodoViewController ()

@property (weak, nonatomic) IBOutlet UITextField *titleField;
@property (weak, nonatomic) IBOutlet UISlider *urgencySlider;
@property (weak, nonatomic) IBOutlet UISlider *importanceSlider;
@property (weak, nonatomic) IBOutlet UINavigationItem *navigationBarItem;
@property (weak, nonatomic) IBOutlet UITextView *notesField;

@end

@implementation EditTodoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
	
    if (self.todo) {
        self.titleField.text         = self.todo.title;
        self.urgencySlider.value     = self.todo.urgency;
        self.importanceSlider.value  = self.todo.importance;
        self.notesField.text         = self.todo.notes;
        self.navigationBarItem.title = @"Edit Todo";
    } else {
        self.urgencySlider.value     = TodoUrgencyDefaultValue;
        self.importanceSlider.value  = TodoImportanceDefaultValue;
        self.navigationBarItem.title = @"New Todo";
        [self.titleField becomeFirstResponder];
    }
    
    [self titleDidChange];
}

- (IBAction)titleDidChange {
    self.navigationBarItem.rightBarButtonItem.enabled = (self.titleField.text.length > 0);
}
    
- (IBAction)cancelButtonWasTapped:(UIBarButtonItem *)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}
    
- (IBAction)saveButtonWasTapped {
    if (!self.todo) {
        self.todo = [Todo create];
    }
    
    self.todo.title      = self.titleField.text;
    self.todo.urgency    = self.urgencySlider.value;
    self.todo.importance = self.importanceSlider.value;
    self.todo.notes      = self.notesField.text;
    
    [[IBCoreDataStore mainStore] save];
    [self.delegate todoWasEdited:self.todo];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)sliderValueChanged:(UISlider *)slider {
    [slider setValue:roundf(slider.value) animated:YES];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    [self saveButtonWasTapped];
    return NO;
}

@end
