//
//  ControlPanelTableController.m
//  iOS-id
//
//  Created by stephen on 10/17/13.
//  Copyright (c) 2013 stephen. All rights reserved.
//

#import "ControlPanelTableController.h"
#import "DataManagerObject.h"
#import "AppDelegate.h"

@interface ControlPanelTableController ()

// data core properties
@property (nonatomic, retain) NSManagedObjectContext *managedObjectContent;
@property (nonatomic, strong) NSMutableArray *a_ns_projectTableData;

@end

@implementation ControlPanelTableController

@synthesize selectedProject;
@synthesize vcProjectView;
@synthesize vcProjectInfo;

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    // ensure selected project is loaded (reference singleton class)
    if(selectedProject==nil) {
        DataManagerObject* dm = [DataManagerObject sharedInstance];
        selectedProject = (Projects*)[dm objectForKey:@"selectedProject"];
    }
    
    // database;
    // make instance and reference content object
    AppDelegate *appDelegate = [UIApplication sharedApplication].delegate;
    self.managedObjectContent = appDelegate.managedObjectContent;
    
    // load projects from database
    [self loadProjectData];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)logoutButtonTouch:(id)sender {
    
    //[self performSegueWithIdentifier:@"segueLogin" sender:self];
    // get reference
    UIViewController *viewCon = [self.storyboard instantiateViewControllerWithIdentifier:@"mainStoryboardView"];
    
    // set options
    viewCon.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
    
    // switch views
    [self presentViewController:viewCon animated:YES completion:nil];
    
}

- (void)loadProjectData {
    AppDelegate *appDelegate = [UIApplication sharedApplication].delegate;
    
    // get records; load into array
    _a_ns_projectTableData = [appDelegate getAllProjects];
    
    // apply data to table
    [_projectsTableView reloadData];
}

//
// Table
//

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [_a_ns_projectTableData count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"tableCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    if(cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    // Configure the cell...
    
    // get project
    Projects *record = [_a_ns_projectTableData objectAtIndex:indexPath.row];
    NSString *recordName = [NSString stringWithFormat:@"%@ ",record.project_name];
    
    cell.textLabel.text = recordName;
    
    //cell.backgroundColor = [UIColor grayColor];
    //cell.selectionStyle = nil;
    
    // add image to accesssory.
    UIButton *accessoryButton = [self createAccessoryButton:@"ios7info-x30.png"];
    
    // apply button to cell
    cell.accessoryView = accessoryButton;
    
    return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    // retain
    selectedProject = [_a_ns_projectTableData objectAtIndex:indexPath.row];
    
    [self performSegueWithIdentifier:@"segueCPGroups" sender:self];
    
}
- (UIButton *)createAccessoryButton:(NSString *)imageName {
    // We create our own button so that we can attach an event
    //
    // reference image
    UIImage *accessoryImage = [UIImage imageNamed:imageName];
    // make button
    UIButton *accessoryButton = [UIButton buttonWithType:UIButtonTypeCustom];
    CGRect frame = CGRectMake(44.0, 44.0, accessoryImage.size.width, accessoryImage.size.height);
    accessoryButton.frame = frame;
    [accessoryButton setBackgroundImage:accessoryImage forState:UIControlStateNormal];
    // provide custom event to force-fire the accessory button tap event
    [accessoryButton addTarget:self action:@selector(accessoryButtonTapped:event:) forControlEvents:UIControlEventTouchUpInside];
    accessoryButton.backgroundColor = [UIColor clearColor];
    
    return accessoryButton;
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
    
    [self performSegueWithIdentifier:@"segueInspectionToProjectInfo" sender:self];
    
}

// communicates with next view before change
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // limit routine to specific segue
    if([segue.identifier isEqualToString:@"segueCPGroups"]) {
        
        // connect
        vcProjectView = [segue destinationViewController];
        
        // pass data to tasks view
        [vcProjectView setDelegate:self];
        [vcProjectView setSelectedProject:selectedProject];
        
    } else if([segue.identifier isEqualToString:@"segueInspectionToProjectInfo"]) {
        
        // remember our required value
        DataManagerObject* dm = [DataManagerObject sharedInstance];
        [dm removeAllObjects];
        [dm setObject:selectedProject forKey:@"selectedProject"];
        
        // connect
        vcProjectInfo = [segue destinationViewController];
        
        // pass data to tasks view
        [vcProjectInfo setDelegate:self];
        [vcProjectInfo setSelectedProject:selectedProject];
    }
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/




@end
