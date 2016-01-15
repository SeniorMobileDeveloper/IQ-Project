//
//  ProjectTableEditorView.m
//  iOS-id
//
//  Created by stephen on 10/9/13.
//  Copyright (c) 2013 stephen. All rights reserved.
//

#import "ProjectTableEditorView.h"
#import "AppDelegate.h"
#import "Projects.h"

@interface ProjectTableEditorView ()

// data core properties
@property (nonatomic, retain) NSManagedObjectContext *managedObjectContent;

@end

@implementation ProjectTableEditorView

@synthesize delegate;
@synthesize selectedProject;


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
    [_projectNameTextField setText:[selectedProject valueForKey:@"project_name"]];

}
- (void)viewWillAppear:(BOOL)animated {
    //
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
    if (![_projectNameTextField.text isEqual: @""]) {

        // update
        [selectedProject setValue:_projectNameTextField.text forKey:@"project_name"];
        //selectedProject.project_name = _projectNameTextField.text;
        
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
