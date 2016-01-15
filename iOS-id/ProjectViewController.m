//
//  ProjectViewController.m
//  iOS-id
//
//  Created by stephen on 10/1/13.
//  Copyright (c) 2013 stephen. All rights reserved.
//

#import "ProjectViewController.h"
#import "CollapsableTableView.h"
#import "DataManagerObject.h"
#import "AppDelegate.h"
#import "NSObject+BuiltInApps.h"
#import "NSObject+CommonFunctions.h"

@interface ProjectViewController ()

// data core properties
@property (nonatomic, retain) NSManagedObjectContext *managedObjectContent;
@property (nonatomic, strong) NSMutableArray *a_ns_projectTableData;
@property (nonatomic, strong) NSMutableArray *a_ns_groupTableData;
@property (nonatomic, strong) NSMutableArray *a_ns_taskTableData;

@end

NSInteger accessoryRowProjectIndex;
UITableViewCell *selectedCell;


@implementation ProjectViewController

DataManagerObject* dm;

@synthesize selectedProject;
@synthesize selectedTask;
@synthesize selectedGroup;
@synthesize vcNoteWriter;
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
 
    // TableExpansion - prepare for our expanded cells
    //if(!expandedSections) {
    //    expandedSections = [[NSMutableIndexSet alloc] init];
    //}
    
    // configure expanded table
    CollapsableTableView* tableView = (CollapsableTableView*) _projectsTableView;
    tableView.collapsableTableViewDelegate = self;
    
    // ensure selected project is loaded
    dm = [DataManagerObject sharedInstance];
    if(selectedProject==nil) {
        selectedProject = (Projects*)[dm objectForKey:@"selectedProject"];
    }
    NSString *childStory = [dm objectForKey:@"pdfEndChildStoryboardId"];
    if (childStory!=nil && ![childStory isEqual:@"nil"]) {
        // switch to child view
        selectedTask = (Tasks*)[dm objectForKey:@"selectedTask"];
        [self performSegueWithIdentifier:@"segueProjectViewToNoteWriter" sender:self];
    }
    
    // database;
    // make instance and reference content object
    AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    self.managedObjectContent = appDelegate.managedObjectContent;
    
    // apply label data from parent
    _projectLabel.text = [selectedProject valueForKey:@"project_name"];
    _projectLabel.textColor = [UIColor whiteColor];
    
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
- (void)viewWillDisappear:(BOOL)animated
{
    [self stopUpdateMonitor];
}
- (void)viewWillAppear:(BOOL)animated
{
    // if monitor was not initiated on load, initalize now
    if(!isMonitorActivationHandled)[self startUpdateMonitor];
    
    isMonitorActivationHandled = FALSE; // always reset
}
// not utilized - we let monitor run unless view is unloaded (which naturally kills timer)
- (void)stopUpdateMonitor
{
    [updateWatchTimer invalidate];
    updateWatchTimer = nil;
}
- (void)onUpdateMonitorTimer:(NSTimer *)timer {
    // We should also montor for inspection update since we display the inspection label; however, we
    // need to consider the variables already used by controlPanelVeiwController which handles
    // inspection updates
    
    
    NSString *p_status = [dm objectForKey:@"isProjectUpdated"];
    NSString *t_status = [dm objectForKey:@"isTaskUpdated"];
    if (p_status || t_status) {
        if (![p_status isEqual:@"nil"] || ![t_status isEqual:@"nil"]) {
            // refresh data and clear bit
            // SEE loadData for the reasons we use the default load method
            // for project updates
            if (![p_status isEqual:@"nil"]) {
                [self loadData:FALSE];
            } else {
                [self loadData:TRUE];
            }
            
            
            // animate howto
            // [_tasksTableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
           
            [dm setObject:@"nil" forKey:@"isProjectUpdated"];
            [dm setObject:@"nil" forKey:@"isTaskUpdated"];
        }
    }
}
//--- end update monitor functions ---//

- (IBAction)logoutButtonTouch:(id)sender {

    [self stopUpdateMonitor];
    
    // cleanup
    [self beforeLogOut];
    
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
- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}
- (void)applyCustomColors {
    statusToolbar.barTintColor = [UIColor colorWithRed:37.0/255.0 green:37.0/255.0 blue:37.0/255.0 alpha:1.0];
    statusToolbar.translucent = NO;
}

- (void)loadData:(BOOL)withAnimation {
    AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    
    // check if we have a previous data count. This is necessary for the animation loader which
    // fails if we try to reload sections that did not previously exist
    int count = 0;
    
    if(_a_ns_groupTableData)count = [_a_ns_groupTableData count];
    
    // get records; load into array
    _a_ns_groupTableData = [appDelegate getGroupsByProject:selectedProject];
   
    // just load normally until we can figure out the refresh problem with the other method
    [self.projectsTableView reloadData];
    
    /*
     
    // We have an issue when the sections do not match, an error stalls the table update. Using
    // TRY/CATCH does not solve the problem since it seems that once the error initiates, the
    // table does not respond to the fallback CATCH statement.
    // At the moment, I do not have a way (or know of a method) that can anticipate how many
    // sections a table will end up with before data is applied. The solution for now is to
    // always use the default load method (without animation) anytime we process udpates for
    // the project sections. Tasks do not alter section numbers so we do not have to apply
    // the rule to all
   
    // for section animation we must have at least 1 object before and after reload
    // and the previous sections count must be equal to or greater than the new count
    if (withAnimation && [_a_ns_groupTableData count] && count) {
        NSRange range = NSMakeRange(0, [self numberOfSectionsInTableView:self.projectsTableView]);
        NSIndexSet *sections = [NSIndexSet indexSetWithIndexesInRange:range];
  
        // reload sections should not be used in place of deletesections. We do not have time to write
        // a complete method to account for ids that need to be removed. Instead, we will check a flag
        // and do 1 or other method of a delete item is set
        if ([dm objectForKey:@"isProjectToBeDeleted"] || [dm objectForKey:@"isTaskToBeDeleted"]) {
            // normal method
            [self.projectsTableView reloadData];
            
            // clear flags
            [dm setObject:@"nil" forKey:@"isProjectToBeDeleted"];
            [dm setObject:@"nil" forKey:@"isTaskToBeDeleted"];
        } else {
        
            [self.projectsTableView reloadSections:sections withRowAnimation:UITableViewRowAnimationFade];
        }
    } else {
        [self.projectsTableView reloadData];
    }
    */
 
    // start monitoring timer updates after initial data is loaded
    [self startUpdateMonitor];
}


//
// Table
//


- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    ProjectGroup *record = [_a_ns_groupTableData objectAtIndex:section]; // used with database
    return [NSString stringWithFormat:@"%@ ",record.projectgroup_name];
    
    // somehow we have to incorporate the following into the header cell
    /*
     // how many tasks ready/completed for group?
     
     // default label
     UILabel *taskLabel;
     NSString *strNumOfTasksCompleted = @"0";
     
     _a_ns_taskTableData = [appDelegate getTasksByGroup:grouprecord];
     if ([_a_ns_taskTableData count]) {
        strNumOfTasksCompleted = [NSString stringWithFormat:@"0 / %lu",(unsigned long)[_a_ns_taskTableData count]];
     }
     
     // initialize and setup
     taskLabel = [[UILabel alloc] initWithFrame:CGRectZero];
     taskLabel.backgroundColor = [UIColor clearColor];
     
     // add
     [cell addSubview:taskLabel];
     
     // constrain
     taskLabel.translatesAutoresizingMaskIntoConstraints = NO;
     
     NSLayoutConstraint *Hconstraint = [NSLayoutConstraint constraintWithItem:taskLabel attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual toItem:cell attribute:NSLayoutAttributeTrailing multiplier:1.0f constant:-70.f];
     
     NSLayoutConstraint *Vconstraint = [NSLayoutConstraint constraintWithItem:taskLabel attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:cell attribute:NSLayoutAttributeTop multiplier:1.0f constant:11.f];
     
     //NSLayoutConstraint *Hconstraint2 = [NSLayoutConstraint constraintWithItem:taskLabel attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0f constant:30.f];
     
     [cell addConstraint:Vconstraint];
     [cell addConstraint:Hconstraint];
     
     // apply text to new label control
     taskLabel.text = strNumOfTasksCompleted;
     
    */
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return [_a_ns_groupTableData count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{

    ProjectGroup *record = [_a_ns_groupTableData objectAtIndex:section];
    return record.tasks.count;
}
- (NSMutableArray *)getTasksByTableSection:(NSIndexPath *)indexPath {
    // reset
    [_a_ns_taskTableData removeAllObjects];
    
    // get project
    ProjectGroup *record = [_a_ns_groupTableData objectAtIndex:indexPath.section];
    if(record.tasks) {
        // get records; load into array
        AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
        _a_ns_taskTableData = [appDelegate getTasksByGroup:record];
    }
    return _a_ns_taskTableData;
}
// 1099
/*- (CGFloat)heightForCellView:(UITextView*)textView containingString:(NSString*)string {
    float Hpadding = 24;
    float Vpadding = 16;
    float widthOfLabelView = textView.contentSize.width - Hpadding;
    float height = [string sizeWithFont:[UIFont systemFontOfSize:kFontSize] constrainedToSize:CGSizeMake(widthOfLabelView, 999999.0f) lineBreakMode:NSLineBreakByWordWrapping ].height + Vpadding;
    
    return height;
}*/
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    // #1
    //CGFloat height = 100;
    
    //return height;
    
    //float height = [self heightForCellView:self.textView containingString:self.mode];
    //return  height+8;
    
    
    
    
    // #2
    //NSString *content = [_a_ns_taskTableData objectAtIndex:indexPath.row];
    // max permitted size
    //CGSize maxSize = CGSizeMake(200, 1000);
    //CGSize size = [content sizeWithAttributes:<#(NSDictionary *)#>]
    
    
    // #3
    //NSString *content = [_a_ns_taskTableData objectAtIndex:indexPath.row];
    //CGSize maxSize = CGSizeMake(200, 1000);
    //CGSize size = CGSizeZero;
    //NSDictionary *attr = [NSDictionary dictionaryWithObjectsAndKeys:nil,NSFontAttributeName, nil];
    //size = [content boundingRectWithSize:maxSize options:[NSStringDrawingUsesLineFragmentOrigin attributes:attr context:nil].size;
    
    
    // #4
    //CGSize maxSize = CGSizeMake(200.f, 1000);
    
    //Helvetica Neue
    
    //NSString *content = [_a_ns_taskTableData objectAtIndex:indexPath.row];
    //NSDictionary *attr = [NSDictionary dictionaryWithObjectsAndKeys:nil,NSFontAttributeName, nil];
    //CGRect frame = [content boundingRectWithSize:maxSize options:(NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading) attributes:attr context:nil];
    
    
  
    
    // #5
    //NSString *content = @"Testing content"; // [_a_ns_taskTableData objectAtIndex:indexPath.row];
    //CGSize maxSize = CGSizeMake(200, CGFLOAT_MAX);
    
    //NSDictionary *attr = [NSDictionary dictionaryWithObjectsAndKeys:nil,NSFontAttributeName, nil];
    //UIFont *font = @"Helvetica Neue";
    //NSAttributedString *attr = [[NSAttributedString alloc] initWithString:content attributes:@{NSFontAttributeName:font}];
    
    //CGSize size = [content boundingRectWithSize:maxSize options:NSStringDrawingUsesLineFragmentOrigin attributes:attr context:nil].size;
    
    //return ceilf(size.height)+5;
    
    
    // #6
    //NSString *content = @"Testing content Testing content Testing content Testing content Testing content Testing content Testing content Testing content Testing content Testing content Testing content Testing content Testing content Testing content";
    NSString *content; // = [_a_ns_taskTableData objectAtIndex:indexPath.row];
    
    // get record name
    Tasks *taskrecord = nil;
    _a_ns_taskTableData = [self getTasksByTableSection:indexPath];
    if ([_a_ns_taskTableData count]) {
        taskrecord = [_a_ns_taskTableData objectAtIndex:indexPath.row]; // used with database
        content = [NSString stringWithFormat:@"%@ ",taskrecord.task_desc];
    }
    
    CGSize maxSize = CGSizeMake(200, CGFLOAT_MAX);
    NSDictionary *attr = @{NSFontAttributeName:[UIFont systemFontOfSize:12.0]};
    CGSize size = [content boundingRectWithSize:maxSize options:NSStringDrawingUsesLineFragmentOrigin attributes:attr context:nil].size;
    
    CGFloat minHeight = 55.f;
    
    if (size.height<minHeight) {
        size.height=minHeight;
    }
    
    // debug
    if([content isEqual:@"Is the instrument arrangement and visibility of flight and navigation instruments in accordance with the applicable regulations?"]) {
        //
    }
    
    return ceilf(size.height)+5;
    
    
    
    //return tableView.rowHeight+5+30;
    
}



- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"xibTableCellPlainLabel"; // name our custom xib
    //UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    TableCellPlainLabel *cell = (TableCellPlainLabel *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if(cell == nil) {
        //cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"TableCellPlainLabel" owner:self options:nil];
        cell = [nib objectAtIndex:0];
    }
    
    NSString *recordName = @"";

    // Project data has already been applied by the header. We now only have to be concerned
    // with showing Groups and then a 3rd nest for Tasks.

    
    // get record name
    Tasks *taskrecord = nil;
    _a_ns_taskTableData = [self getTasksByTableSection:indexPath];
    if ([_a_ns_taskTableData count]) {
        taskrecord = [_a_ns_taskTableData objectAtIndex:indexPath.row]; // used with database
        recordName = [NSString stringWithFormat:@"%@ ",taskrecord.task_desc];
    }
    
    //cell.textLabel.text = recordName;
    cell.titleLabel.text = recordName;
   
    //cell.backgroundColor = [UIColor grayColor];
    //cell.selectionStyle = nil;
  
    
    // add image to accesssory.
    UIButton *accessoryButton;
    if (taskrecord.notes.count>0) {
        accessoryButton = [self createAccessoryButton:@"ios7note-red-x30.png"];
    } else {
        accessoryButton = [self createAccessoryButton:@"ios7note-x30-n.png"];
    }
    
    // apply button to cell
    cell.accessoryView = accessoryButton;
    
    
    //
    // custom switch for table cell
    //
    
    // initialize and setup
    /*UISwitch *taskCompletedSwitch = [[UISwitch alloc] initWithFrame:CGRectZero];
    [taskCompletedSwitch addTarget:self action:@selector(switchValueChanged:) forControlEvents:UIControlEventValueChanged];
    [taskCompletedSwitch setOn:NO animated:NO];
    if (taskrecord!=nil) {
        if (taskrecord.task_complete.boolValue) {
            [taskCompletedSwitch setOn:YES animated:NO];
        }
    }*/
    
    SVSegmentedControl *svComplete = [[SVSegmentedControl alloc] initWithSectionTitles:[NSArray arrayWithObjects:@"NO", @"YES", @"NA", nil]];
    [svComplete addTarget:self action:@selector(segmentedControlChangedValue:) forControlEvents:UIControlEventValueChanged];
    svComplete.crossFadeLabelsOnDrag = YES;
    svComplete.thumb.tintColor = [UIColor colorWithRed:0 green:0.5 blue:0.1 alpha:1];
    svComplete.textColor = [UIColor colorWithRed:0.7 green:0.7 blue:0.3 alpha:1];
    //svComplete.backgroundTintColor = [UIColor colorWithRed:0 green:0.5 blue:0.1 alpha:1];
    [svComplete setSelectedSegmentIndex:[taskrecord.task_complete intValue] animated:NO];
    [svComplete setTag:indexPath.row];
    [cell addSubview:svComplete];
    svComplete.translatesAutoresizingMaskIntoConstraints = NO;
    NSLayoutConstraint *Hconstraint = [NSLayoutConstraint constraintWithItem:svComplete attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual toItem:cell attribute:NSLayoutAttributeTrailing multiplier:1.0f constant:-70.f];
    
    NSLayoutConstraint *Vconstraint = [NSLayoutConstraint constraintWithItem:svComplete attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:cell attribute:NSLayoutAttributeTop multiplier:1.0f constant:11.f];
    
    //NSLayoutConstraint *VBconstraint = [NSLayoutConstraint constraintWithItem:taskCompletedSwitch attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:cell attribute:NSLayoutAttributeBottom multiplier:1.0f constant:-7.f];
    
    [cell addConstraint:Vconstraint];
    //[cell addConstraint:VBconstraint];
    [cell addConstraint:Hconstraint];
    
    return cell;

}

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

#pragma mark - UIControlEventValueChanged

- (void)segmentedControlChangedValue:(SVSegmentedControl*)segmentedControl {
    //NSLog(@"segmentedControl %li did select index %lu (via UIControl method)", (long)segmentedControl.tag, (unsigned long)segmentedControl.selectedSegmentIndex);
    UIView *view = [segmentedControl superview];
    while (view != nil && ![view isKindOfClass:[UITableViewCell class]]) {
        view = [view superview];
    }
    UITableViewCell *cell = (UITableViewCell *)view;
    NSIndexPath *indexPath = [_projectsTableView indexPathForCell:cell];
    [_projectsTableView selectRowAtIndexPath:indexPath animated:NO scrollPosition:UITableViewScrollPositionNone];
    if(indexPath != nil) {
        
        _a_ns_taskTableData = [self getTasksByTableSection:indexPath];
        selectedTask = [_a_ns_taskTableData objectAtIndex:indexPath.row];
        if(selectedTask!=nil)
        {
            selectedTask.task_complete = [NSNumber numberWithInteger:segmentedControl.selectedSegmentIndex];
        }
    }
}

- (void)buttonClickDetected:(id)sender {

    //CGPoint currentTouchPosition = [sender locationInView:_projectsTableView];
    //NSIndexPath *indexPath = [_projectsTableView indexPathForRowAtPoint:currentTouchPosition];
    
    // worked for IOS 7 but not for 8
    //UITableViewCell *cell2 = (UITableViewCell *)[[sender superview] superview];
    //NSIndexPath *indexPath = [_projectsTableView indexPathForCell:cell];
    
    // updated for IOS 8
    UIView *view = [sender superview];
    while (view != nil && ![view isKindOfClass:[UITableViewCell class]]) {
        view = [view superview];
    }
    UITableViewCell *cell = (UITableViewCell *)view;
    NSIndexPath *indexPath = [_projectsTableView indexPathForCell:cell];
    [_projectsTableView selectRowAtIndexPath:indexPath animated:NO scrollPosition:UITableViewScrollPositionNone];
    
    if(indexPath != nil) {
        
        // the presense of a switch tells us there are items
        _a_ns_taskTableData = [self getTasksByTableSection:indexPath];
        selectedTask = [_a_ns_taskTableData objectAtIndex:indexPath.row];
    
        UIButton *selButton = (UIButton*)sender;
        // update
        if (selectedTask!=nil) {
            NSNumber *newNumber;
            if([selectedTask.task_complete intValue] == 0)
            {
                newNumber = [NSNumber numberWithInt:1];
                [selButton setBackgroundImage:[UIImage imageNamed:@"selector-yes"] forState:UIControlStateNormal];
            }
            else if([selectedTask.task_complete intValue] == 1)
            {
                newNumber = [NSNumber numberWithInt:0];
                [selButton setBackgroundImage:[UIImage imageNamed:@"selector-no"] forState:UIControlStateNormal];
            }
            
            [selectedTask setValue:newNumber forKey:@"task_complete"];
            
            // error trap
            NSError *error = nil;
            if (![self.managedObjectContent save:&error]) {
                NSLog(@"Error, could not save %@ to local device",[error localizedDescription]);
            }
            
            //if (toggleSwitch.on) { switchLabel.text = @&quot;Enabled&quot;; }
            //else { switchLabel.text = @&quot;Disabled&quot;;}
        }
    }
  
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    // multiple sections requires we retrieve our list for each selection
    _a_ns_taskTableData = [self getTasksByTableSection:indexPath];
    
    // retain
    selectedTask = [_a_ns_taskTableData objectAtIndex:indexPath.row];
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
    
    // multiple sections requires we retrieve our list for each selection
    _a_ns_taskTableData = [self getTasksByTableSection:indexPath];
    
    // retain
    selectedTask = [_a_ns_taskTableData objectAtIndex:indexPath.row];
    
    [self performSegueWithIdentifier:@"segueProjectViewToNoteWriter" sender:self];
    
}

// TableExpansion
#pragma mark -
#pragma mark CollapsableTableViewDelegate

- (void) collapsableTableView:(CollapsableTableView*) tableView willCollapseSection:(NSInteger) section title:(NSString*) sectionTitle headerView:(UIView*) headerView
{
    [spinner startAnimating];
}

- (void) collapsableTableView:(CollapsableTableView*) tableView didCollapseSection:(NSInteger) section title:(NSString*) sectionTitle headerView:(UIView*) headerView
{
    [spinner stopAnimating];
}

- (void) collapsableTableView:(CollapsableTableView*) tableView willExpandSection:(NSInteger) section title:(NSString*) sectionTitle headerView:(UIView*) headerView
{
    [spinner startAnimating];
}

- (void) collapsableTableView:(CollapsableTableView*) tableView didExpandSection:(NSInteger) section title:(NSString*) sectionTitle headerView:(UIView*) headerView
{
    [spinner stopAnimating];
}
#pragma mark -
#pragma mark IBAction methods

- (IBAction) toggleSection2
{
    NSString* sectionTitle = @"Header";
    //[NSString stringWithFormat:@"Tag %i",1]; // Use this expression when using custom header views.
    //[ProjectViewController titleForHeaderForSection:1]; // Use this expression when specifying text for headers.

    
    CollapsableTableView* tableView = (CollapsableTableView*) _projectsTableView;
    BOOL isCollapsed = [[tableView.headerTitleToIsCollapsedMap objectForKey:sectionTitle] boolValue];
    [tableView setIsCollapsed:! isCollapsed forHeaderWithTitle:sectionTitle];
}
// end TableExpansion


- (IBAction)showPdfResourceViewer:(id)sender {
    //DataManagerObject* dm = [DataManagerObject sharedInstance];
    [dm setObject:selectedProject forKey:@"selectedProject"];
    // tell any new view to return to main navigation
    [dm setObject:@"applicationDashboard" forKey:@"pdfParentStoryboardId"];
    
    // tell the parent navigation to push control back to this child on return
    [dm setObject:@"segue" forKey:@"pdfNextChildStoryboardId"];
    // clear final child
    [dm setObject:@"nil" forKey:@"pdfEndChildStoryboardId"];
    
    pdfTitle = @"Resources";
    pdfItemId = @"3";
    [self performSegueWithIdentifier:@"seguePdfView" sender:self];
}
- (IBAction)showFFAwebsite:(id)sender {
    //DataManagerObject* dm = [DataManagerObject sharedInstance];
    [dm setObject:selectedProject forKey:@"selectedProject"];
    // tell any new view to return to main navigation
    [dm setObject:@"applicationDashboard" forKey:@"pdfParentStoryboardId"];
    
    // tell the parent navigation to push control back to this child on return
    [dm setObject:@"segue" forKey:@"pdfNextChildStoryboardId"];
    // clear final child
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
    if([segue.identifier isEqualToString:@"segueProjectViewToNoteWriter"]) {
        
        // remember our required value
        //DataManagerObject* dm = [DataManagerObject sharedInstance];
        //[dm removeAllObjects];
        //[dm setObject:selectedProject forKey:@"selectedProject"];
        
        // connect
        vcNoteWriter = [segue destinationViewController];
        
        // pass data to tasks view
        [vcNoteWriter setDelegate:self];
        [vcNoteWriter setSelectedTask:selectedTask];
     
    } else if([segue.identifier isEqualToString:@"seguePdfView"]) {
        
        // connect with popover
        pvcPDFList = [segue destinationViewController];
        
        // pass data into popup using popup's predefined variable
        [pvcPDFList setDelegate:self];
        [pvcPDFList setPdfItemId:pdfItemId];
        [pvcPDFList setPdfTitle:pdfTitle];
        
    }
}

/////////////////////////////////////////////////
//
// Methods defined in NoteWriterView.h
//
//

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

//- (void)dismissView:(NoteWriterView *)lvc {
//    [self dismissViewControllerAnimated:YES completion:NULL];
//}


// for debug
- (void)showDebugMessage:(NSString *)msg {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:msg delegate:nil cancelButtonTitle:@"ok" otherButtonTitles:nil, nil];
    
    [alert show];
}

-(IBAction)generatePDF:(id)sender
{
    [dm setObject:selectedProject forKey:@"selectedProject"];
    // tell any new view to return to main navigation
    [dm setObject:@"applicationDashboard" forKey:@"pdfParentStoryboardId"];
    
    // tell the parent navigation to push control back to this child on return
    [dm setObject:@"segue" forKey:@"pdfNextChildStoryboardId"];
    // clear final child
    [dm setObject:@"nil" forKey:@"pdfEndChildStoryboardId"];
    
    NSString *fileName = @"Invoice.pdf";
    [PDFRenderer generateHTML];
    [self previewPDF];
}

-(NSString*)getFileName:(NSString*)fileName
{
    NSArray *arrayPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *path = [arrayPaths objectAtIndex:0];
    NSString* pdfFileName = [path stringByAppendingPathComponent:fileName];
    return pdfFileName;
}

-(void) previewPDF
{
    UIViewController *viewCon = [self.storyboard instantiateViewControllerWithIdentifier:@"pdfPreviewID"];
     viewCon.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
    [self presentViewController:viewCon animated:YES completion:nil];
}

/*
 --how to convert types--
 NSString *strF = [NSString stringWithFormat:@"%d",accessoryRowProjectIndex];
 
 --how to call functions--
 [self showDebugMessage:strF];
 
 --how to create inline table cell button--
 UIButton *button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
 // set button position and params
 button.frame = CGRectMake(cell.frame.origin.x+100, cell.frame.origin.y+20, 100, 30);
 [button setTitle:@"Edit" forState:UIControlStateNormal];
 [button addTarget:self action:@selector(editProjectName:) forControlEvents:UIControlEventTouchUpInside];
 button.backgroundColor = [UIColor clearColor];
 [cell.contentView addSubview:button];

 --how to add item to beginning of array--
 // shift to front of array
 [_recipePhotos insertObject:selectedPicture atIndex:0];
 [_recipePhotos insertObject:@"angry_birds_cake.jpg" atIndex:0];

 --how to pass database value to new view--
 [pvcProjectEditor setProjectName:[selectedProject valueForKey:@"project_name"]];

 --set visual contraints--
 NSArray *Vconstraint = [NSLayoutConstraint constraintsWithVisualFormat:@"V:|-[_tasksToDoLabel(=11)]-|" options:NSLayoutFormatDirectionLeadingToTrailing metrics:nil views:NSDictionaryOfVariableBindings(_tasksToDoLabel)];
 NSArray *Hconstraint = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|-[_tasksToDoLabel(=895)]-|" options:NSLayoutFormatDirectionLeadingToTrailing metrics:nil views:NSDictionaryOfVariableBindings(_tasksToDoLabel)];
 
 */

@end
