//
//  AdminControlPanelView.m
//  iOS-id
//
//  Created by stephen on 10/7/13.
//  Copyright (c) 2013 stephen. All rights reserved.
//

#import "AdminControlPanelView.h"
#import "AppDelegate.h"
#import "Projects.h"


@interface AdminControlPanelView ()

// data core properties
@property (nonatomic, retain) NSManagedObjectContext *managedObjectContent;
@property (nonatomic, strong) NSMutableArray *a_ns_projectTableData;

@end

@implementation AdminControlPanelView

@synthesize vcGroup;
@synthesize selectedProject;

// synthesize for popup
@synthesize currentPopoverSegue;
@synthesize pvcProjectEditor;


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
    [self loadProjectData];
}

- (IBAction)logoutButtonTouch:(id)sender {
    
    // get reference
    UIViewController *viewCon = [self.storyboard instantiateViewControllerWithIdentifier:@"mainStoryboardView"];
    
    // set options
    viewCon.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
    
    // switch views
    [self presentViewController:viewCon animated:YES completion:nil];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)loadProjectData {
    AppDelegate *appDelegate = [UIApplication sharedApplication].delegate;
    
    // get records; load into array
    _a_ns_projectTableData = [appDelegate getAllProjects];
    
    // apply data to table
    [_projectsTableView reloadData];
}

- (IBAction)addProjectRecord:(id)sender {
   
    if (![_projectNameTextField.text isEqual: @""]) {

        // create instance of project table
        Projects *newEntry = [NSEntityDescription insertNewObjectForEntityForName:@"Projects" inManagedObjectContext:self.managedObjectContent];
        
        // insert (replace with data from text field when ready)
        newEntry.project_name = _projectNameTextField.text;
        newEntry.project_active = [NSNumber numberWithBool:YES];
        
        // error trap
        NSError *error;
        if (![self.managedObjectContent save:&error]) {
            NSLog(@"Error, could not save %@ to local device",[error localizedDescription]);
        }
        
        // clear fields
        _projectNameTextField.text = @"";
        
        // apply data to table
        [self loadProjectData];
        
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
    return [_a_ns_projectTableData count];
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"projectNameCell"; // use our prototype
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if(cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    Projects *record = [_a_ns_projectTableData objectAtIndex:indexPath.row]; // used with database
    //cell.textLabel.text = [_a_ns_projectTableData objectAtIndex:indexPath.row]; // used with string array
    
    cell.textLabel.text = [NSString stringWithFormat:@"%@ ",record.project_name];
    
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
    selectedProject = [_a_ns_projectTableData objectAtIndex:indexPath.row];
    
    [self performSegueWithIdentifier:@"segueGroupByProject" sender:self];
    
}
- (void)accessoryButtonTapped:(id)sender event:(id)event {
    // map touch area
    NSSet *touches = [event allTouches];
    UITouch *touch = [touches anyObject];
    CGPoint currentTouchPosition = [touch locationInView:_projectsTableView];
    NSIndexPath *indexPath = [_projectsTableView indexPathForRowAtPoint:currentTouchPosition];
    
    // fire main event if touch is valid
    if(indexPath != nil) {
        [self tableView:_projectsTableView accessoryButtonTappedForRowWithIndexPath:indexPath];
    }
}
- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath {
    
    // retain
    selectedProject = [_a_ns_projectTableData objectAtIndex:indexPath.row];
 
    // open editor
    [self performSegueWithIdentifier:@"segueProjectEditor" sender:self];
    
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
        [context deleteObject:[_a_ns_projectTableData objectAtIndex:indexPath.row]];
        
        NSError *error = nil;
        if(![context save:&error]) {
            NSLog(@"Error, can't delete %@ %@",error,[error localizedDescription]);
            return;
        }
        
        // remove from table view
        [_a_ns_projectTableData removeObjectAtIndex:indexPath.row];
        [_projectsTableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
        
    }
}
// end allow delete functions


//
// segue control
//

- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if([segue.identifier isEqualToString:@"segueGroupByProject"]) {
        
        // connect
        vcGroup = [segue destinationViewController];
        
        // pass data to tasks view
        [vcGroup setDelegate:self];
        [vcGroup setSelectedProject:selectedProject];
        
    } else if([segue.identifier isEqualToString:@"segueProjectEditor"]) {
        
        // connect with popover
        currentPopoverSegue = (UIStoryboardPopoverSegue *)segue;
        pvcProjectEditor = [segue destinationViewController];
        
        // pass data into popup using popup's predefined variable
        [pvcProjectEditor setDelegate:self];
        [pvcProjectEditor setSelectedProject:selectedProject];
        
    }
}

/////////////////////////////////////////////////
//
// Methods defined in ProjectTableEditorView.h
//
//


- (void) dismissPopover:(BOOL) doclose update:(BOOL)doupdate {
    // dismiss view
    [[currentPopoverSegue popoverController] dismissPopoverAnimated:YES];
    
    if (doupdate) {
        // refresh data
        [self loadProjectData];
    }
}


@end
