//
//  TaskNoteWriterController.m
//  iOS-id
//
//  Created by stephen on 10/18/13.
//  Copyright (c) 2013 stephen. All rights reserved.
//

#import "TaskNoteWriterController.h"
#import "NSObject+BuiltInApps.h"
#import "NSObject+CameraHandler.h"
#import "NSObject+DataCoreHandler.h"
#import "NSObject+TableCellHandler.h"
#import "NSObject+CommonFunctions.h"
#import "DataManagerObject.h"
#import "AppDelegate.h"


#define IS_OS_8_OR_LATER ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0)
@interface TaskNoteWriterController ()

// data core properties
@property (nonatomic, retain) NSManagedObjectContext *managedObjectContent;
@property (nonatomic, strong) NSMutableArray *a_ns_tableData;

@end

@implementation TaskNoteWriterController

DataManagerObject* dm;

@synthesize updateWatchTimer;
@synthesize isMonitorActivationHandled;

@synthesize delegate;
@synthesize selectedTask;
@synthesize selectedNote;
@synthesize currentPopoverSegue;
@synthesize pvcNoteEditor;
@synthesize pvcNoteWriter;
@synthesize pvcPictureAlbum;
@synthesize notesToolbar;
@synthesize statusToolbar;
@synthesize navbarItem;

// synthesize for popup
@synthesize pdfItemId;
@synthesize pdfTitle;
@synthesize pvcPDFList;
@synthesize pictureAlbum2;

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
    AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    self.managedObjectContent = appDelegate.managedObjectContent;
    
    // create instance
    DataManagerObject* dm = [DataManagerObject sharedInstance];
    
    // ensure selected item is loaded
    if(selectedTask==nil) {
        selectedTask = (Tasks*)[dm objectForKey:@"selectedTask"];
    }
    
    // apply title image
    ////navbarItem.titleView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"logo-small.png"]];
    
    // remove leftover border
    notesToolbar.clipsToBounds = YES;
    
    [self applyCustomColors];
    
    // because we are deactivating the timer when the view disappears, we have another montior initiator
    // that we need to communciate with. Anytime this load function fires, we want to disable alternative
    // initialize methods
    isMonitorActivationHandled = TRUE;
    
    // load projects from database
    [self loadData:FALSE];
    [self setLocationPreference];
}
- (void)viewWillAppear:(BOOL)animated
{
    // if monitor was not initiated on load, initalize now
    if(!isMonitorActivationHandled)[self startUpdateMonitor];
    
    isMonitorActivationHandled = FALSE; // always reset
}
- (void)viewWillDisappear:(BOOL)animated
{
    [self stopUpdateMonitor];
}

-(void)setLocationPreference
{
    self.locationManager = [[CLLocationManager alloc] init];
    self.locationManager.delegate = self;
    self.locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    
    if (![CLLocationManager locationServicesEnabled])
    {
        UIAlertView *servicesDisabledAlert = [[UIAlertView alloc] initWithTitle:@"Location Services Disabled" message:@"You currently have all location services for this device disabled. If you proceed, you will be asked to confirm whether location services should be reenabled." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [servicesDisabledAlert show];
        
    }
    if(IS_OS_8_OR_LATER) {
        NSUInteger code = [CLLocationManager authorizationStatus];
        if (code == kCLAuthorizationStatusNotDetermined && ([self.locationManager respondsToSelector:@selector(requestAlwaysAuthorization)] || [self.locationManager respondsToSelector:@selector(requestWhenInUseAuthorization)])) {
            // choose one request according to your business.
            if([[NSBundle mainBundle] objectForInfoDictionaryKey:@"NSLocationAlwaysUsageDescription"]){
                [self.locationManager requestAlwaysAuthorization];
            } else if([[NSBundle mainBundle] objectForInfoDictionaryKey:@"NSLocationWhenInUseUsageDescription"]) {
                [self.locationManager  requestWhenInUseAuthorization];
            } else {
                NSLog(@"Info.plist does not contain NSLocationAlwaysUsageDescription or NSLocationWhenInUseUsageDescription");
            }
        }
    }
    
    [self.locationManager startUpdatingLocation];
    
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
    
    NSString *note_status = [dm objectForKey:@"isTaskNoteUpdated"];
    NSString *photo_status = [dm objectForKey:@"isTaskPhotoUpdated"];
    if (note_status || photo_status) {
        if (![note_status isEqual:@"nil"] || ![photo_status isEqual:@"nil"]) {
            // refresh data and clear bit
            //[self.noteTableView reloadData];
            [self loadData:TRUE];
            
            [dm setObject:@"nil" forKey:@"isTaskNoteUpdated"];
            [dm setObject:@"nil" forKey:@"isTaskPhotoUpdated"];
        }
    }
}
//--- end update monitor functions ---//

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}
- (void)loadData:(BOOL)withAnimation {
    AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    
    // check if we have a previous data count. This is necessary for the animation loader which
    // fails if we try to reload sections that did not previously exist
    int count = 0;
    if(_a_ns_tableData)count = [_a_ns_tableData count];
    
    // get records; load into array
    _a_ns_tableData = [appDelegate getNotesByTask:selectedTask];
    
    // for section animation we must have at least 1 object before and after reload
    if (withAnimation && [_a_ns_tableData count] && count) {
        //NSRange range = NSMakeRange(0, [self numberOfSectionsInTableView:self.projectsTableView]);
        //NSIndexSet *sections = [NSIndexSet indexSetWithIndexesInRange:range];
        
        // reload sections should not be used in place of deletesections. We do not have time to write
        // a complete method to account for ids that need to be removed. Instead, we will check a flag
        // and do 1 or other method of a delete item is set
        if ([dm objectForKey:@"isTaskNoteToBeDeleted"]) {
            // normal method
            [self.noteTableView reloadData];
            
            // clear flags
            [dm setObject:@"nil" forKey:@"isTaskNoteToBeDeleted"];
        } else {
            
            // Note: if the try statement fails, the table will not respond to the default load method.
            // This is just something to contend with for now. It's unlikely to be an issue since the
            // only way the statement will fail is if we have no items in the list. The app comes
            // preloaded, so we should be fine for now
            
            @try {
                [self.noteTableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationFade];
            }
            @catch (NSException *exception) {
                // error will be caught if sections do not match. Process normally
                [self.noteTableView reloadData];
            }
            @finally {
                //
            }
        }
        
    } else {
        [self.noteTableView reloadData];
    }
    
    // start monitoring timer updates after initial data is loaded
    [self startUpdateMonitor];
}

- (void)applyCustomColors {
    statusToolbar.barTintColor = [UIColor colorWithRed:37.0/255.0 green:37.0/255.0 blue:37.0/255.0 alpha:1.0];
    statusToolbar.translucent = NO;
}
- (IBAction)logoutButtonTouch:(id)sender {
    
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

- (IBAction)addNoteButtonTouch:(id)sender {
    
    [self performSegueWithIdentifier:@"segueTaskToNoteWriter" sender:self];
    
}


- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    //currentPopoverSegue = (UIStoryboardPopoverSegue *)segue;
    
    if([segue.identifier isEqualToString:@"segueTaskToNoteWriter"]) {
        currentPopoverSegue = (UIStoryboardPopoverSegue *)segue;
        
        // connect with popover
        pvcNoteWriter = [segue destinationViewController];
        
        // pass data into popup using popup's predefined variable
        [pvcNoteWriter setDelegate:self];
        [pvcNoteWriter setIsPopup:YES];
        [pvcNoteWriter setTypeOfParent:@"task"];
        [pvcNoteWriter setSelectedTask:selectedTask];
        
    } else if([segue.identifier isEqualToString:@"segueTaskToNoteEditor"]) {
        currentPopoverSegue = (UIStoryboardPopoverSegue *)segue;
        
        // connect with popover
        pvcNoteEditor = [segue destinationViewController];
        
        // pass data into popup using popup's predefined variable
        [pvcNoteEditor setDelegate:self];
        [pvcNoteEditor setSelectedNote:selectedNote];
    } else if([segue.identifier isEqualToString:@"TaskViewToAlbum"]) {
        
        // connect with push view
        pvcPictureAlbum = [segue destinationViewController];
        
        // pass data into view using
        [pvcPictureAlbum setDelegate:self];
        [pvcPictureAlbum setSelectedNote:selectedNote];
    } else if([segue.identifier isEqualToString:@"segueTaskInfoToPictureView"]) {
        
        // connect with popover
        pictureAlbum2 = [segue destinationViewController];
        
        // pass data
        [pictureAlbum2 setDelegate:self];
        [pictureAlbum2 setSelectedNote:selectedNote];
        
        
    } else if([segue.identifier isEqualToString:@"seguePdfView"]) {
        currentPopoverSegue = (UIStoryboardPopoverSegue *)segue;
        
        // connect with popover
        pvcPDFList = [segue destinationViewController];
        
        // pass data into popup using popup's predefined variable
        [pvcPDFList setDelegate:self];
        [pvcPDFList setPdfItemId:pdfItemId];
        [pvcPDFList setPdfTitle:pdfTitle];
        
    }
    
}

//
// Table
//
// These are not ready. Need to convert for use with Notes

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [_a_ns_tableData count];
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
    
    Notes *record = [_a_ns_tableData objectAtIndex:indexPath.row]; // used with database
  
    //cell.textLabel.text = [NSString stringWithFormat:@"%@ ",record.message];
    cell.titleLabel.text = [NSString stringWithFormat:@"%@ ",record.message];
    
    //cell.backgroundColor = [UIColor grayColor];
    //cell.selectionStyle = nil;
    
    
    // add custom note image
    UIImageView *imgView = [self createImageForCell:@"ios7arrow-x30.png"];
    
    // Gestures transferred to row selected
    ////imgView.userInteractionEnabled = TRUE;
    // add gesture to image
    ////[imgView addGestureRecognizer:[self createTapRecognizer:@selector(onNoteImageTap:)]];
    
    // apply to cell
    [cell addSubview:imgView];
    
    // constrain image
    imgView.translatesAutoresizingMaskIntoConstraints = NO;
    
    // constrain position
    cell = (TableCellPlainLabel *)[self addPositionContraintsToCell:cell forView:imgView xpos:-78.f ypos:14.f];
    
    
    // If we have images associated with this note, load a custom
    // image view for a thumbnail. Otherwise, create accessory
    //
    // loadNoteThumbnailFromDisk
    AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    NSMutableArray *a_photos = [appDelegate getPhotosByNote:record];
    if ([a_photos count]) {
        
        // constrain previous icon position in relationship to the thumbnail
        //cell = [self addPositionContraintsToCell:cell forView:imgView xpos:-78.f ypos:14.f];
        
        // add custom image
        UIImageView *imgView2 = [self loadNoteThumbnailByCoreDataPhotos:a_photos];
        imgView2.userInteractionEnabled = TRUE;
        
        // add gesture to image
        [imgView2 addGestureRecognizer:[self createTapRecognizer:@selector(onThumnailTap:)]];
        
        // apply to cell
        [cell addSubview:imgView2];
        
        // constrain image
        imgView2.translatesAutoresizingMaskIntoConstraints = NO;
        
        // constrain position
        cell = (TableCellPlainLabel *)[self addPositionContraintsToCell:cell forView:imgView2 xpos:-15.f ypos:3.f];
        
        // constrain size
        cell = (TableCellPlainLabel *)[self addSizeContraintsToCell:cell forView:imgView2 height:48.f width:48.f];
        
        // do not use accessory view
        cell.accessoryView = nil;
        
    } else {
        
        // constrain previous icon position in relationship to a standard icon
        //cell = [self addPositionContraintsToCell:cell forView:imgView xpos:-78.f ypos:14.f];
        
        // add image to accesssory.
        UIButton *accessoryButton = [self createAccessoryButton:@"ios7camera-x30.png"];
      
        // apply button to cell
        cell.accessoryView = accessoryButton;
    }
    
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    // retain
    selectedNote = [_a_ns_tableData objectAtIndex:indexPath.row];
    
    // open note viewer/editor
    selectedNote = [_a_ns_tableData objectAtIndex:indexPath.row];
    
    // open editor
    [self performSegueWithIdentifier:@"segueTaskToNoteEditor" sender:self];
}
- (UITapGestureRecognizer *)createTapRecognizer:(SEL)selector; {
    // create trigger event
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:selector];
    tap.cancelsTouchesInView = YES;
    tap.numberOfTapsRequired = 1;
    
    return tap;
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
- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath {
    
    // retain
    selectedNote = [_a_ns_tableData objectAtIndex:indexPath.row];
    
    // open camera app
    [self openCameraApp:nil];
    
}


- (NSIndexPath *)getRowByTouch:(id)event {
    // map touch area
    NSSet *touches = [event allTouches];
    UITouch *touch = [touches anyObject];
    CGPoint currentTouchPosition = [touch locationInView:_noteTableView];
    NSIndexPath *indexPath = [_noteTableView indexPathForRowAtPoint:currentTouchPosition];
    
    return indexPath;
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
        [_noteTableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
        
    }
}
// end allow delete functions

//
// Camera operation
//

- (IBAction)openCameraApp:(id)sender {
    
    // create picture control
    UIImagePickerController *picker = [self createPicturePicker:self];
    
    // execute
    [self presentViewController:picker animated:YES completion:NULL];
    
}
- (IBAction)selectImageFromCamera:(id)sender {
    
    // create library control
    UIImagePickerController *picker = [self createLibraryPicker:self];
    
    // execute
    [self presentViewController:picker animated:YES completion:NULL];
    
}
- (void) onThumnailTap:(UIGestureRecognizer *)gestureRecognizer {
    CGPoint currentTouchPosition = [gestureRecognizer locationInView:_noteTableView];
    NSIndexPath *indexPath = [_noteTableView indexPathForRowAtPoint:currentTouchPosition];
    
    // fire main event if touch is valid
    if(indexPath != nil) {
        selectedNote = [_a_ns_tableData objectAtIndex:indexPath.row];
        
        // open album view
        [self performSegueWithIdentifier:@"segueTaskInfoToPictureView" sender:self];
    }
}
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    UIImage *selectedPicture = info[UIImagePickerControllerEditedImage];
    
    // If a note was selected, picture will be applied to selection. Otherwise, we create an empty note.
    if (selectedNote == nil) {
        selectedNote = [self insertEmptyNote:self.managedObjectContent relationship:@"task" relationshipEntity:(NSEntityDescription *)selectedTask];
    }
    
    
    // save image to camera roll
    //UIImageWriteToSavedPhotosAlbum(selectedPicture, self, nil, nil);
    
    
    // Store image to disk.
    //NSDictionary *imageData = [self savePickerPictureToDisk:selectedPicture];
    NSDictionary *imageData = [self createImageDataFromPickerPicture:selectedPicture];
    NSError *error = nil;
    
    // save to database
    Photos *newEntry = [NSEntityDescription insertNewObjectForEntityForName:@"Photos" inManagedObjectContext:self.managedObjectContent];
    
    // insert
    newEntry.photo_name = [imageData objectForKey:@"filename"];
    newEntry.photo_path = @""; // [imageData objectForKey:@"path"]; // path;
    newEntry.photo_date_created = [NSDate date];
    newEntry.photo_image = [imageData objectForKey:@"image"];
    
    // create relationship with parent table (assume parent object was set by parent)
    newEntry.note = selectedNote;
    
    // error trap
    error = nil;
    if (![self.managedObjectContent save:&error]) {
        NSLog(@"Error, could not save %@ to local device",[error localizedDescription]);
    }
    
    // reload data
    [self loadData:FALSE];
    
    // close camera
    [picker dismissViewControllerAnimated:YES completion:NULL];
}
- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [picker dismissViewControllerAnimated:YES completion:NULL];
}

- (IBAction)showPdfResourceViewer:(id)sender {
    //DataManagerObject* dm = [DataManagerObject sharedInstance];
    [dm setObject:selectedTask forKey:@"selectedTask"];
    // tell any new view to return to main navigation
    [dm setObject:@"applicationDashboard" forKey:@"pdfParentStoryboardId"];
    // tell the parent navigation to push control back to this child on return
    [dm setObject:@"segue" forKey:@"pdfEndChildStoryboardId"];
    
    
    pdfTitle = @"Resources";
    pdfItemId = @"3";
    [self performSegueWithIdentifier:@"seguePdfView" sender:self];
}
- (IBAction)showFFAwebsite:(id)sender {
    //DataManagerObject* dm = [DataManagerObject sharedInstance];
    [dm setObject:selectedTask forKey:@"selectedTask"];
    // tell any new view to return to main navigation
    [dm setObject:@"applicationDashboard" forKey:@"pdfParentStoryboardId"];
    // tell the parent navigation to push control back to this child on return
    [dm setObject:@"segue" forKey:@"pdfEndChildStoryboardId"];
    
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


//
// custom tap recognizers
//


- (void)accessoryButtonTapped:(id)sender event:(id)event {
    // get row
    NSIndexPath *indexPath = [self getRowByTouch:event];
    
    // fire main event if touch is valid
    if(indexPath != nil) {
        [self tableView:_noteTableView accessoryButtonTappedForRowWithIndexPath:indexPath];
    }
}
// available when using custom camera view
- (void) onCameraImageTap:(UIGestureRecognizer *)gestureRecognizer {
    //UIView* view = gestureRecognizer.view;
    
    CGPoint currentTouchPosition = [gestureRecognizer locationInView:_noteTableView];
    NSIndexPath *indexPath = [_noteTableView indexPathForRowAtPoint:currentTouchPosition];
    
    // fire main event if touch is valid
    if(indexPath != nil) {
        selectedNote = [_a_ns_tableData objectAtIndex:indexPath.row];
        
        // open camera app
        [self openCameraApp:nil];
    }
    
}
// available when using custom note view
- (void) onNoteImageTap:(UIGestureRecognizer *)gestureRecognizer {
    //UIView* view = gestureRecognizer.view;
    
    CGPoint currentTouchPosition = [gestureRecognizer locationInView:_noteTableView];
    NSIndexPath *indexPath = [_noteTableView indexPathForRowAtPoint:currentTouchPosition];
    
    // fire main event if touch is valid
    if(indexPath != nil) {
        selectedNote = [_a_ns_tableData objectAtIndex:indexPath.row];
        
        // open editor
        [self performSegueWithIdentifier:@"segueTaskToNoteEditor" sender:self];
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
    
    // reload data
    [self loadData:FALSE];
}

//
// Methods defined in NoteTableEditorView.h
//

- (void) dismissPopover:(BOOL) doclose update:(BOOL)doupdate {
    // dismiss view
    [[currentPopoverSegue popoverController] dismissPopoverAnimated:YES];
    
    if (doupdate) {
        // refresh data
        [self loadData:FALSE];
    }
}

#pragma mark CLLocationDelegate
- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
    CLLocation *newLocation = locations[0];
    NSString *locString = [NSString stringWithFormat:@"Latitude=%f, Longitude=%f", newLocation.coordinate.latitude, newLocation.coordinate.longitude];
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"" message:locString delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
    [alertView show];
    [self.locationManager stopUpdatingLocation];
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    NSLog(@"%s:%d %@", __func__, __LINE__, error);
}

static NSString *DescriptionOfCLAuthorizationStatus(CLAuthorizationStatus st)
{
    switch (st)
    {
        case kCLAuthorizationStatusNotDetermined:
            return @"kCLAuthorizationStatusNotDetermined";
        case kCLAuthorizationStatusRestricted:
            return @"kCLAuthorizationStatusRestricted";
        case kCLAuthorizationStatusDenied:
            return @"kCLAuthorizationStatusDenied";
            //case kCLAuthorizationStatusAuthorized: is the same as
            //kCLAuthorizationStatusAuthorizedAlways
        case kCLAuthorizationStatusAuthorizedAlways:
            return @"kCLAuthorizationStatusAuthorizedAlways";
            
        case kCLAuthorizationStatusAuthorizedWhenInUse:
            return @"kCLAuthorizationStatusAuthorizedWhenInUse";
    }
    return [NSString stringWithFormat:@"Unknown CLAuthorizationStatus value: %d", st];
}

- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status
{
    NSLog(@"%s:%d %@", __func__, __LINE__, DescriptionOfCLAuthorizationStatus(status));
}


@end
