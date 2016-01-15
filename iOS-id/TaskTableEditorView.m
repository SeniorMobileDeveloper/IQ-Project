//
//  TaskTableEditorView.m
//  iOS-id
//
//  Created by stephen on 10/9/13.
//  Copyright (c) 2013 stephen. All rights reserved.
//

#import "TaskTableEditorView.h"
#import "AppDelegate.h"

@interface TaskTableEditorView ()

// data core properties
@property (nonatomic, retain) NSManagedObjectContext *managedObjectContent;

@end

@implementation TaskTableEditorView

@synthesize delegate;
@synthesize selectedTask;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    // database;
    // make instance and reference content object
    AppDelegate *appDelegate = [UIApplication sharedApplication].delegate;
    self.managedObjectContent = appDelegate.managedObjectContent;
   
    // apply data from parent
    [_nameTextField setText:[selectedTask valueForKey:@"task_desc"]];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (IBAction)cancelButtonTouch:(id)sender {
    
    // is new data saved?
    //
    // IF NOT confirm cancel
    //
    
    // call delegated method to dismiss. This goes to the
    // parent method where it is defined
    [delegate dismissPopover:YES update:NO];
    
}
- (IBAction)saveButtonTouch:(id)sender {
    
    // save data
    if (![_nameTextField.text isEqual: @""]) {
        
        // update
        [selectedTask setValue:_nameTextField.text forKey:@"task_desc"];
        
        // error trap
        NSError *error = nil;
        if (![self.managedObjectContent save:&error]) {
            NSLog(@"Error, could not save %@ to local device",[error localizedDescription]);
        }
        
        [self.view endEditing:YES]; // close keyboard
    }
    
    // call delegated method to dismiss. This goes to the
    // parent method where it is defined
    [delegate dismissPopover:YES update:YES];
    
}

@end
