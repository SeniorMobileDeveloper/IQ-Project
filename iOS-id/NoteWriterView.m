//
//  NoteWriterView.m
//  iOS-id
//
//  Created by stephen on 10/3/13.
//  Copyright (c) 2013 stephen. All rights reserved.
//

#import "NoteWriterView.h"
#import "AppDelegate.h"

@interface NoteWriterView ()

// data core properties
@property (nonatomic, retain) NSManagedObjectContext *managedObjectContent;

@end

@implementation NoteWriterView

@synthesize delegate;
@synthesize strPassedInfo;
@synthesize storyboardName;
@synthesize selectedProject;
@synthesize selectedTask;
@synthesize isPopup;
@synthesize typeOfParent;

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
    
    if (!isPopup) {
        // remove toolbar control
        //[self removeToolbarControl];
        // hide toolbar control
        [self hideToolbarControl];
    }
}
- (void) viewWillAppear:(BOOL)animated {
    
    // available values preset by the parent (not all are used)
    // strPassedInfo
}
- (void)viewDidAppear:(BOOL)animated {
    [_noteTextBox becomeFirstResponder];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (void)removeToolbarControl {
    [_controlToolbar removeFromSuperview];
}
- (void)hideToolbarControl {
    _controlToolbar.alpha = 0;
}

- (IBAction)cancelButtonTouchInPopup:(id)sender {
    // is new data saved?
    //
    // IF NOT confirm cancel
    //
    
    // call delegated method to dismis. This goes to the
    // parent method where it is defined
    [delegate dismissPopover:YES];
}
- (IBAction)saveButtonTouchInPopup:(id)sender {
    // save data
    [self addNoteToRecord];
    
    // call delegated method to dismis. This goes to the
    // parent method where it is defined
    [delegate dismissPopover:YES];
}
- (IBAction)saveButtonTouch:(id)sender {
    
    // save data
    [self addNoteToRecord];
    
    // call delegated method to dismis. This goes to the
    // parent method where it is defined
    ////[delegate dismissPopover:YES];
    
    [self returnToParentView];
}
- (void)addNoteToRecord {
    
    if (![_noteTextBox.text isEqual: @""]) {
        
        // create instance of table
        Notes *newEntry = [NSEntityDescription insertNewObjectForEntityForName:@"Notes" inManagedObjectContext:self.managedObjectContent];
        
        
        // insert
        newEntry.name = @"";
        newEntry.message = _noteTextBox.text;
        newEntry.date_created = [NSDate date];
       
        // create relationship with parent table (assume parent object was set by parent)
        if ([typeOfParent isEqual: @"project"]) {
            newEntry.project = selectedProject;
        } else {
            newEntry.task = selectedTask;
        }
        
        // error trap
        NSError *error;
        if (![self.managedObjectContent save:&error]) {
            NSLog(@"Error, could not save %@ to local device",[error localizedDescription]);
        }
        
        // clear fields
        _noteTextBox.text = @"";
   
        
        [self.view endEditing:YES]; // close keyboard
    }
    
}

- (void)returnToParentView {
    
    //if ([self.delegate respondsToSelector:@selector(dismissView:)]) {
    //    [self.delegate dismissView:self];
    //}
    //[delegate dismissView:self];
    
    // [self dismissModalViewControllerAnimated:YES]
    
    /*
    ////[self performSegueWithIdentifier:@"segueProjectInfo" sender:self];
    // get reference
    UIViewController *viewCon = [self.storyboard instantiateViewControllerWithIdentifier:storyboardName];
    
    // set options
    viewCon.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
    
    // switch views
    [self presentViewController:viewCon animated:YES completion:nil];
     */
    
}


/*

 --When applying a value to a text box--
 [_textBoxName setText:theValue];
 
 */

@end
