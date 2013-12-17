//
//  EditTodoViewController.m
//  Kuriku
//
//  Created by Tony Mann on 12/13/13.
//  Copyright (c) 2013 7Actions. All rights reserved.
//

#import "EditTodoViewController.h"
#import "Todo.h"
#import <InnerBand/InnerBand.h>

@interface EditTodoViewController ()

@property (weak, nonatomic) IBOutlet UITextField *titleField;
@property (weak, nonatomic) IBOutlet UISlider *urgencySlider;
@property (weak, nonatomic) IBOutlet UISlider *importanceSlider;

@end

@implementation EditTodoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
	
    if (self.todo) {
        self.titleField.text        = self.todo.title;
        self.urgencySlider.value    = self.todo.urgency;
        self.importanceSlider.value = self.todo.importance;
    } else {
        self.urgencySlider.value    = TodoUrgencyDefaultValue;
        self.importanceSlider.value = TodoImportanceDefaultValue;
        [self.titleField becomeFirstResponder];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
    
- (IBAction)cancelButtonWasTapped:(UIBarButtonItem *)sender {
    [self.navigationController popViewControllerAnimated:YES];
}
    
- (IBAction)saveButtonWasTapped:(UIBarButtonItem *)sender {
    if (!self.todo)
        self.todo = [Todo create];
    
    self.todo.title      = self.titleField.text;
    self.todo.urgency    = self.urgencySlider.value;
    self.todo.importance = self.importanceSlider.value;
    
    [[IBCoreDataStore mainStore] save];
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)sliderValueChanged:(UISlider *)slider {
    [slider setValue:roundf(slider.value) animated:YES];
}

@end
