//
//  ControlPanelViewController.m
//  iOS-id
//
//  Created by stephen on 10/22/13.
//  Copyright (c) 2013 stephen. All rights reserved.
//

#import "ControlPanelViewController.h"
//#import "NSObject+DarkTheme.h"
#import "NSObject+BuiltInApps.h"
#import "NSObject+CommonFunctions.h"
#import "DataManagerObject.h"
#import "AppDelegate.h"

@interface ControlPanelViewController ()

// data core properties
@property (nonatomic, retain) NSManagedObjectContext *managedObjectContent;
@property (nonatomic, strong) NSMutableArray *a_ns_projectTableData;

@end

@implementation ControlPanelViewController

DataManagerObject* dm;

@synthesize selectedProject;
@synthesize vcProjectView;
@synthesize vcProjectInfo;
@synthesize navbarItem;
@synthesize statusToolbar;

// synthesize for popup
@synthesize pdfItemId;
@synthesize pdfTitle;
@synthesize currentPopoverSegue;
@synthesize pvcPDFList;
@synthesize updateWatchTimer;
@synthesize isMonitorActivationHandled;


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
    
    // ensure selected project is loaded (reference singleton class)
    dm = [DataManagerObject sharedInstance];
    NSString *childStory = [dm objectForKey:@"pdfNextChildStoryboardId"];
    if (childStory!=nil && ![childStory isEqual:@"nil"]) {
        // switch to child view
        selectedProject = (Projects*)[dm objectForKey:@"selectedProject"];
        [self performSegueWithIdentifier:@"segueCPGroups" sender:self];
    }
    
    // database;
    // make instance and reference content object
    AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    self.managedObjectContent = appDelegate.managedObjectContent;
    
    // apply title image
    ////navbarItem.titleView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"logo-small.png"]];
    
    [self applyCustomColors];
    
    // because we are deactivating the timer when the view disappears, we have another montior initiator
    // that we need to communciate with. Anytime this load function fires, we want to disable alternative
    // initialize methods
    isMonitorActivationHandled = TRUE;
    
    // load projects from database
    [self loadData:FALSE];
    
}

//--- UPDATE MONITOR FUNCTIONS ---//
- (void)startUpdateMonitor
{
    if (!updateWatchTimer) {
        updateWatchTimer = [NSTimer scheduledTimerWithTimeInterval:7.0 target:self selector:@selector(onUpdateMonitorTimer:) userInfo:nil repeats:YES];
    }
}
// not utilized - we let monitor run unless view is unloaded (which naturally kills timer)
- (void)stopUpdateMonitor
{
    [updateWatchTimer invalidate];
    updateWatchTimer = nil;
}
- (void)onUpdateMonitorTimer:(NSTimer *)timer {
    NSString *status = [dm objectForKey:@"isInspectionUpdated"];
    if (status && ![status isEqual:@"nil"]) { // if (childStory!=nil && ![childStory isEqual:@"nil"])
        // refresh data and clear bit
        //[self.projectsTableView reloadData];
        [self loadData:TRUE];
        [dm setObject:@"nil" forKey:@"isInspectionUpdated"];
    }
}
//--- end update monitor functions ---//

- (void)viewWillAppear:(BOOL)animated {
    [self applyCustomColors];
    
    // if monitor was not initiated on load, initalize now
    if(!isMonitorActivationHandled)[self startUpdateMonitor];
    
    isMonitorActivationHandled = FALSE; // always reset
}
- (void)viewWillDisappear:(BOOL)animated
{
    [self stopUpdateMonitor];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

- (void)applyCustomColors {
    statusToolbar.barTintColor = [UIColor colorWithRed:37.0/255.0 green:37.0/255.0 blue:37.0/255.0 alpha:1.0];
    statusToolbar.translucent = NO;
}

- (IBAction)logoutButtonTouch:(id)sender {
    
    // cancel monitors for all views
    [self stopUpdateMonitor];
    
    // cleanup
    [self beforeLogOut];
    
    
    //[self performSegueWithIdentifier:@"segueLogin" sender:self];
    // get reference
    UIViewController *viewCon = [self.storyboard instantiateViewControllerWithIdentifier:@"mainStoryboardView"];
    
    // set options
    viewCon.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
    
    // switch views
    [self presentViewController:viewCon animated:YES completion:nil];
    
}

- (void)loadData:(BOOL)withAnimation {
    AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    
    // check if we have a previous data count. This is necessary for the animation loader which
    // fails if we try to reload sections that did not previously exist
    int count = 0;
    if(_a_ns_projectTableData)count = [_a_ns_projectTableData count];
    
    // get records; load into array
    _a_ns_projectTableData = [appDelegate getAllProjects];
    
    // for section animation we must have at least 1 object before and after reload
    if (withAnimation && [_a_ns_projectTableData count] && count) {
        //NSRange range = NSMakeRange(0, [self numberOfSectionsInTableView:self.projectsTableView]);
        //NSIndexSet *sections = [NSIndexSet indexSetWithIndexesInRange:range];
        
        
        // reload sections should not be used in place of deletesections. We do not have time to write
        // a complete method to account for ids that need to be removed. Instead, we will check a flag
        // and do 1 or other method of a delete item is set
        if ([dm objectForKey:@"isInspectionToBeDeleted"]) {
            // normal method
            [self.projectsTableView reloadData];
            
            // clear flags
            [dm setObject:@"nil" forKey:@"isInspectionToBeDeleted"];
        } else {
        
            // Note: if the try statement fails, the table will not respond to the default load method.
            // This is just something to contend with for now. It's unlikely to be an issue since the
            // only way the statement will fail is if we have no items in the list. The app comes
            // preloaded, so we should be fine for now
            
            @try {
                [self.projectsTableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationFade];
            }
            @catch (NSException *exception) {
                // error will be caught if sections do not match. Process normally
                [self.projectsTableView reloadData];
            }
            @finally {
                //
            }
        }
        
    } else {
        [self.projectsTableView reloadData];
    }
    
    // start monitoring timer updates after initial data is loaded
    [self startUpdateMonitor];
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
/*
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
 */
- (UIButton *)createAccessoryButton:(NSString *)imageName {
    // We create our own button so that we can attach an event
    //
    // reference image
    UIImage *accessoryImage = [UIImage imageNamed:imageName];
    // make button
    UIButton *accessoryButton = [UIButton buttonWithType:UIButtonTypeCustom];
    
    // increase tap size
    CGRect frame = CGRectMake(44.0, 44.0, 40.0, 38.0);
    
    accessoryButton.frame = frame;
    
    /*
     Using a background image has the benefit of also adding a title. However, it does not easily allow
     for a custom hit area. Setting the image property allows the frame to increase without increasing
     the image. More than that, the accessory area will be properly calculated by the table cell so
     that the delete view will naturally shift the custom image. A background image does not have this
     behavoir
     */
    ////[accessoryButton setBackgroundImage:accessoryImage forState:UIControlStateNormal];
    [accessoryButton setImage:accessoryImage forState:UIControlStateNormal];
    
    // provide custom event to force-fire the accessory button tap event
    [accessoryButton addTarget:self action:@selector(accessoryButtonTapped:event:) forControlEvents:UIControlEventTouchUpInside];
    accessoryButton.backgroundColor = [UIColor clearColor];
    
    // test border
    //[[accessoryButton layer] setBorderWidth:2.0f];
    //[[accessoryButton layer] setBorderColor:[UIColor greenColor].CGColor];
    
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

- (IBAction)showPdfResourceViewer:(id)sender {
    //dm = [DataManagerObject sharedInstance];
    // tell any new view to return to navigation controller
    [dm setObject:@"selectedProject" forKey:@"selectedProject"];
    [dm setObject:@"applicationDashboard" forKey:@"pdfParentStoryboardId"];
    [dm setObject:@"controlPanelViewID" forKey:@"pdfFirstChildStoryboardId"];
    // clear children
    [dm setObject:@"nil" forKey:@"pdfNextChildStoryboardId"];
    [dm setObject:@"nil" forKey:@"pdfEndChildStoryboardId"];
    
    pdfTitle = @"Resources";
    pdfItemId = @"3";
    [self performSegueWithIdentifier:@"seguePdfView" sender:self];
}
- (IBAction)showFFAwebsite:(id)sender {
    //dm = [DataManagerObject sharedInstance];
    // tell any new view to return to navigation controller
    [dm setObject:@"selectedProject" forKey:@"selectedProject"];
    [dm setObject:@"applicationDashboard" forKey:@"pdfParentStoryboardId"];
    [dm setObject:@"controlPanelViewID" forKey:@"pdfFirstChildStoryboardId"];
    // clear children
    [dm setObject:@"nil" forKey:@"pdfNextChildStoryboardId"];
    [dm setObject:@"nil" forKey:@"pdfEndChildStoryboardId"];
    
    // set web request
    [dm setObject:@"url" forKey:@"requestType"];
    [dm setObject:@"http://www.faa.gov" forKey:@"pdfFilename"];
    
    [self switchToWebViewOnDismissPopover:NO];
}

//
// Built-in Apps
//

// Address Book

- (IBAction)showAddressBook:(id)sender {
    [self openAddressBook:self];
}
- (IBAction)showEventCalendar:(id)sender {
    [self openEventCalendar:self];
}

//
// End built-in apps
//


// communicates with next view before change
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    currentPopoverSegue = (UIStoryboardPopoverSegue *)segue;
    
    // limit routine to specific segue
    if([segue.identifier isEqualToString:@"segueCPGroups"]) {
        
        // connect
        vcProjectView = [segue destinationViewController];
        
        // pass data to tasks view
        [vcProjectView setDelegate:self];
        [vcProjectView setSelectedProject:selectedProject];
        
    } else if([segue.identifier isEqualToString:@"segueInspectionToProjectInfo"]) {
        
        // remember our required value
        //dm = [DataManagerObject sharedInstance];
        [dm removeAllObjects];
        [dm setObject:selectedProject forKey:@"selectedProject"];
        
        // connect
        vcProjectInfo = [segue destinationViewController];
        
        // pass data to tasks view
        [vcProjectInfo setDelegate:self];
        [vcProjectInfo setSelectedProject:selectedProject];
        
    } else if([segue.identifier isEqualToString:@"seguePdfView"]) {
        
        // connect with popover
        pvcPDFList = [segue destinationViewController];
        
        // pass data into popup using popup's predefined variable
        [pvcPDFList setDelegate:self];
        [pvcPDFList setPdfItemId:pdfItemId];
        [pvcPDFList setPdfTitle:pdfTitle];
        
    }
}

- (void) switchToWebViewOnDismissPopover:(BOOL) doclose {
    if (doclose) {
        [self dismissPopover:YES];
    }
    
    // get reference
    UIViewController *viewCon = [self.storyboard instantiateViewControllerWithIdentifier:@"pdfWebViewID"];
    
    // set options
    viewCon.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
    
    // switch views
    [self presentViewController:viewCon animated:YES completion:nil];
    
}
- (void) dismissPopover:(BOOL)docancel {
    // dismiss view
    [[currentPopoverSegue popoverController] dismissPopoverAnimated:YES];
}
- (void) dismissPopover:(BOOL) doclose update:(BOOL)doupdate {
    // dismiss view
    [[currentPopoverSegue popoverController] dismissPopoverAnimated:YES];
    
    if (doupdate) {
        // refresh data
        [self loadData:FALSE];
    }
}


@end
