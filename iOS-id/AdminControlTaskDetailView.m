//
//  AdminControlTaskDetailView.m
//  iOS-id
//
//  Created by stephen on 10/8/13.
//  Copyright (c) 2013 stephen. All rights reserved.
//

#import "AdminControlTaskDetailView.h"
#import "AppDelegate.h"

@interface AdminControlTaskDetailView ()

// data core properties
@property (nonatomic, retain) NSManagedObjectContext *managedObjectContent;
@property (nonatomic, strong) NSMutableArray *a_ns_taskTableData;

@end

@implementation AdminControlTaskDetailView

@synthesize titleBarItem;
@synthesize selectedTask;

@synthesize pvcItemEditor;
@synthesize currentPopoverSegue;

// parent
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
    
    // load projects from database
    [self loadData];
}
- (void)viewWillAppear:(BOOL)animated {
    // add parent label to title
    NSString *label = [selectedProjectGroup valueForKey:@"projectgroup_name"];
    titleBarItem.title = [NSString stringWithFormat:@"Tasks for %@",label];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)loadData {
    AppDelegate *appDelegate = [UIApplication sharedApplication].delegate;
   
    // get records; load into array
    _a_ns_taskTableData = [appDelegate getTasksByGroup:selectedProjectGroup];
    
    // apply data to table
    [_tasksTableView reloadData];
}

- (IBAction)addTaskRecord:(id)sender {
  
    if (![_taskName.text isEqual: @""]) {
        
        // create instance of table
        Tasks *newEntry = [NSEntityDescription insertNewObjectForEntityForName:@"Tasks" inManagedObjectContext:self.managedObjectContent];
        
        // insert
        newEntry.task_name = @"";
        newEntry.task_desc = _taskName.text;
        newEntry.task_active = [NSNumber numberWithBool:YES];
        newEntry.task_complete = 0;//[NSNumber numberWithBool:NO];
        
        // create relationship with project (assume selectedProject was set by parent)
        newEntry.group = selectedProjectGroup;
        
        // error trap
        NSError *error;
        if (![self.managedObjectContent save:&error]) {
            NSLog(@"Error, could not save %@ to local device",[error localizedDescription]);
        }
        
        // The following method correctly links the task to the project; however, it directly assigns the current task,
        // essentially overwriting previous relationships. Instead, we assign the project to the task entry above.
        /*
        // insert relationship for selected project
        selectedProject.tasks = [NSSet setWithObjects:newEntry, nil];
       
        // error trap
        NSError *error2;
        if (![self.managedObjectContent save:&error2]) {
            NSLog(@"Error, could not create relationship for %@ on local device",[error localizedDescription]);
        }
        */
  
        
        // clear fields
        _taskName.text = @"";
        
        // apply data to table
        [self loadData];
        
        [self.view endEditing:YES]; // close keyboard
    }
    
}


//
// Table
//

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [_a_ns_taskTableData count];
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"tableCell"; // use our prototype
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if(cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    Tasks *record = [_a_ns_taskTableData objectAtIndex:indexPath.row]; // used with database

    cell.textLabel.text = [NSString stringWithFormat:@"%@ ",record.task_desc];
    
    //cell.backgroundColor = [UIColor grayColor];
    //cell.selectionStyle = nil;
    
    // add image to accesssory.
    // We create our own button so that we can attach an event
    //
    // reference image
    UIImage *accessoryImage = [UIImage imageNamed:@"ios7note-x30.png"];
    // make button
    UIButton *accessoryButton = [UIButton buttonWithType:UIButtonTypeCustom];
    CGRect frame = CGRectMake(44.0, 44.0, accessoryImage.size.width, accessoryImage.size.height);
    accessoryButton.frame = frame;
    [accessoryButton setBackgroundImage:accessoryImage forState:UIControlStateNormal];
    // provide custom event to force-fire the accessory button tap event
    [accessoryButton addTarget:self action:@selector(accessoryButtonTapped:event:) forControlEvents:UIControlEventTouchUpInside];
    accessoryButton.backgroundColor = [UIColor clearColor];
    
    // apply button to cell
    //cell.accessoryView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"ios7note-x30.png"]];
    cell.accessoryView = accessoryButton;
   
    
    return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    // retain
    selectedTask = [_a_ns_taskTableData objectAtIndex:indexPath.row];

}
- (void)accessoryButtonTapped:(id)sender event:(id)event {
    // map touch area
    NSSet *touches = [event allTouches];
    UITouch *touch = [touches anyObject];
    CGPoint currentTouchPosition = [touch locationInView:_tasksTableView];
    NSIndexPath *indexPath = [_tasksTableView indexPathForRowAtPoint:currentTouchPosition];
    
    // fire main event if touch is valid
    if(indexPath != nil) {
        [self tableView:_tasksTableView accessoryButtonTappedForRowWithIndexPath:indexPath];
    }
}
- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath {
    
    // retain
    selectedTask = [_a_ns_taskTableData objectAtIndex:indexPath.row];
    
    [self performSegueWithIdentifier:@"segueTaskEditor" sender:self];
}

// allow delete function
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
    return UITableViewCellEditingStyleDelete;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    NSManagedObjectContext *context = [self managedObjectContent];
    
    if( editingStyle == UITableViewCellEditingStyleDelete ) {
        // delete object from database
        [context deleteObject:[_a_ns_taskTableData objectAtIndex:indexPath.row]];
        
        NSError *error = nil;
        if(![context save:&error]) {
            NSLog(@"Error, can't delete %@ %@",error,[error localizedDescription]);
            return;
        }
        
        // remove from table view
        [_a_ns_taskTableData removeObjectAtIndex:indexPath.row];
        [_tasksTableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
        
    }
}
// end allow delete functions

//
// segue control
//

- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if([segue.identifier isEqualToString:@"segueTaskEditor"]) {
        
        // connect with popover
        currentPopoverSegue = (UIStoryboardPopoverSegue *)segue;
        pvcItemEditor = [segue destinationViewController];
        
        // pass data into popup using popup's predefined variable
        [pvcItemEditor setDelegate:self];
        [pvcItemEditor setSelectedTask:selectedTask];
        
    }
}

/////////////////////////////////////////////////
//
// Methods defined in TaskTableEditorView.h
//
//


- (void) dismissPopover:(BOOL) doclose update:(BOOL)doupdate {
    // dismiss view
    [[currentPopoverSegue popoverController] dismissPopoverAnimated:YES];
    
    if (doupdate) {
        // refresh data
        [self loadData];
    }
}


@end
