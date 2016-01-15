//
//  AdminControlProjectGroupView.m
//  iOS-id
//
//  Created by stephen on 10/9/13.
//  Copyright (c) 2013 stephen. All rights reserved.
//

#import "AdminControlProjectGroupView.h"
#import "AppDelegate.h"

@interface AdminControlProjectGroupView ()

// data core properties
@property (nonatomic, retain) NSManagedObjectContext *managedObjectContent;
@property (nonatomic, strong) NSMutableArray *a_ns_tableData;

@end

@implementation AdminControlProjectGroupView

@synthesize titleBarItem;
@synthesize selectedProjectGroup;
@synthesize pvcItemEditor;
@synthesize currentPopoverSegue;

// parent
@synthesize delegate;
@synthesize selectedProject;

// child
@synthesize vcTaskDetail;

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
    
    // load data from database
    [self loadData];
}
- (void)viewWillAppear:(BOOL)animated {
    // add parent label to title
    NSString *label = [selectedProject valueForKey:@"project_name"];
    titleBarItem.title = [NSString stringWithFormat:@"Project Groups %@",label];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)loadData {
    AppDelegate *appDelegate = [UIApplication sharedApplication].delegate;
    
    // get records; load into array
    _a_ns_tableData = [appDelegate getGroupsByProject:selectedProject];
    
    // apply data to table
    [_groupTableView reloadData];
}

- (IBAction)addRecord:(id)sender {
    
    if (![_groupName.text isEqual: @""]) {
        
        // create instance of table
        ProjectGroup *newEntry = [NSEntityDescription insertNewObjectForEntityForName:@"ProjectGroup" inManagedObjectContext:self.managedObjectContent];
        
        // insert
        newEntry.projectgroup_name = _groupName.text;
        newEntry.projectgroup_active = [NSNumber numberWithBool:YES];
        
        // create relationship with project (assume selectedProject was set by parent)
        newEntry.project = selectedProject;
        
        // error trap
        NSError *error;
        if (![self.managedObjectContent save:&error]) {
            NSLog(@"Error, could not save %@ to local device",[error localizedDescription]);
        }
        
        
        // clear fields
        _groupName.text = @"";
        
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
    return [_a_ns_tableData count];
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"tableCell"; // use our prototype
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if(cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    ProjectGroup *record = [_a_ns_tableData objectAtIndex:indexPath.row]; // used with database
    
    cell.textLabel.text = [NSString stringWithFormat:@"%@ ",record.projectgroup_name];
    
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
    selectedProjectGroup = [_a_ns_tableData objectAtIndex:indexPath.row];
    
    [self performSegueWithIdentifier:@"segueTasksByProject" sender:self];
    
}
- (void)accessoryButtonTapped:(id)sender event:(id)event {
    // map touch area
    NSSet *touches = [event allTouches];
    UITouch *touch = [touches anyObject];
    CGPoint currentTouchPosition = [touch locationInView:_groupTableView];
    NSIndexPath *indexPath = [_groupTableView indexPathForRowAtPoint:currentTouchPosition];
    
    // fire main event if touch is valid
    if(indexPath != nil) {
        [self tableView:_groupTableView accessoryButtonTappedForRowWithIndexPath:indexPath];
    }
}
- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath {
    
    // retain
    selectedProjectGroup = [_a_ns_tableData objectAtIndex:indexPath.row];
    
    [self performSegueWithIdentifier:@"segueProjectGroupEditor" sender:self];
}

// allow delete functions
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
        [context deleteObject:[_a_ns_tableData objectAtIndex:indexPath.row]];
        
        NSError *error = nil;
        if(![context save:&error]) {
            NSLog(@"Error, can't delete %@ %@",error,[error localizedDescription]);
            return;
        }
        
        // remove from table view
        [_a_ns_tableData removeObjectAtIndex:indexPath.row];
        [_groupTableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
        
    }
}
// end allow delete functions

//
// segue control
//

- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if([segue.identifier isEqualToString:@"segueTasksByProject"]) {
        
        // connect
        vcTaskDetail = [segue destinationViewController];
        
        // pass data to tasks view
        [vcTaskDetail setDelegate:self];
        [vcTaskDetail setSelectedProjectGroup:selectedProjectGroup];
        
    } else if([segue.identifier isEqualToString:@"segueProjectGroupEditor"]) {
        
        // connect with popover
        currentPopoverSegue = (UIStoryboardPopoverSegue *)segue;
        pvcItemEditor = [segue destinationViewController];
        
        // pass data into popup using popup's predefined variable
        [pvcItemEditor setDelegate:self];
        [pvcItemEditor setSelectedProjectGroup:selectedProjectGroup];
        
    }
}

/////////////////////////////////////////////////
//
// Methods defined in ProjectGroupTableEditorView.h
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
