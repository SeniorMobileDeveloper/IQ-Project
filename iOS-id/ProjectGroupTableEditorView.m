//
//  ProjectGroupTableEditorView.m
//  iOS-id
//
//  Created by stephen on 10/10/13.
//  Copyright (c) 2013 stephen. All rights reserved.
//

#import "ProjectGroupTableEditorView.h"
#import "AppDelegate.h"

@interface ProjectGroupTableEditorView ()

// data core properties
@property (nonatomic, retain) NSManagedObjectContext *managedObjectContent;

@end

@implementation ProjectGroupTableEditorView

@synthesize delegate;
@synthesize selectedProjectGroup;

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
    [_nameTextField setText:[selectedProjectGroup valueForKey:@"projectgroup_name"]];
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
        [selectedProjectGroup setValue:_nameTextField.text forKey:@"projectgroup_name"];
       
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
