//
//  ProjectInfoController.m
//  iOS-id
//
//  Created by stephen on 10/2/13.
//  Copyright (c) 2013 stephen. All rights reserved.
//

#import "ProjectInfoController.h"
#import "NSObject+BuiltInApps.h"
#import "NSObject+CameraHandler.h"
#import "NSObject+DataCoreHandler.h"
#import "NSObject+TableCellHandler.h"
#import "NSObject+CommonFunctions.h"
#import "DataManagerObject.h"
#import "AppDelegate.h"



@interface ProjectInfoController ()

// data core properties
@property (nonatomic, retain) NSManagedObjectContext *managedObjectContent;
@property (nonatomic, strong) NSMutableArray *a_ns_tableData;

@end


@implementation ProjectInfoController

DataManagerObject* dm;

@synthesize updateWatchTimer;
@synthesize isMonitorActivationHandled;

@synthesize accessoryRowProjectIndex;
@synthesize selectedCell;
@synthesize notesToolbar;
@synthesize infoToolbar;
@synthesize statusToolbar;
@synthesize navigationItem;

// parent
@synthesize delegate;
@synthesize selectedProject;
@synthesize selectedProjectGroup;
@synthesize selectedTask;

// child
@synthesize selectedNote;
@synthesize pdfItemId;
@synthesize pdfTitle;

// synthesize for popup
@synthesize currentPopoverSegue;
@synthesize pvcNoteWriter;
@synthesize pvcNoteEditor;
@synthesize pvcPictureAlbum;
@synthesize pvcMapExpanded;
@synthesize pvcPDFList;

@synthesize pictureAlbum2;

// for map
@synthesize projectMapView;
@synthesize zoomLocation;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:YES];
    
    // set default location.
    // To prevent user confirmation for using current location, the
    // view defaults to continent view
    
    // override default if location set.
    // Later, use company table from database to determine location
    zoomLocation.latitude = 40.740848;
    zoomLocation.longitude= -73.991145;
    
    // if monitor was not initiated on load, initalize now
    if(!isMonitorActivationHandled)[self startUpdateMonitor];
    
    isMonitorActivationHandled = FALSE; // always reset
    
}
- (void) viewDidAppear:(BOOL)animated {
    [super viewDidAppear:YES];
    
    // convert coordinate to string
    //NSString *strF = [[NSString alloc] initWithFormat:@"%f", zoomLocation.latitude];
    
    
    // animate to location
    if (zoomLocation.latitude != 0 || zoomLocation.longitude != 0) {
        MKCoordinateRegion viewRegion = MKCoordinateRegionMakeWithDistance(zoomLocation, 0.3*METERS_PER_MILE, 0.3*METERS_PER_MILE);
        [projectMapView setRegion:viewRegion animated:NO];
    }
    
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
    dm = [DataManagerObject sharedInstance];
    
    // ensure item is loaded
    if(selectedProject==nil) {
        selectedProject = (Projects *)[dm objectForKey:@"selectedProject"];
        delegate = [dm objectForKey:@"projectInfoDelegate"];
    }
    
    // apply label data from parent
    _projectLabel.text = [selectedProject valueForKey:@"project_name"];
   
    
    // set component design properties by reference
    _bioView.layer.cornerRadius = 10;
    _noteTableView.layer.cornerRadius = 10;
   
    //[[UIBarButtonItem appearance] setTitleTextAttributes:
    //                   [NSDictionary dictionaryWithObjectsAndKeys:[UIFont fontWithName:@"AmericanTypewriter" size:12.0],NSFontAttributeName, nil] forState:UIControlStateNormal];
    
    
    ////navigationItem.titleView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"logo-small.png"]];
    
    [self applyCustomColors];
    
    // remove leftover border
    notesToolbar.clipsToBounds = YES;
    infoToolbar.clipsToBounds = YES;
    
    // because we are deactivating the timer when the view disappears, we have another montior initiator
    // that we need to communciate with. Anytime this load function fires, we want to disable alternative
    // initialize methods
    isMonitorActivationHandled = TRUE;
    
    // load projects from database
    [self loadData:FALSE];

}
- (void)viewWillDisappear:(BOOL)animated
{
    [self stopUpdateMonitor];
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

    NSString *note_status = [dm objectForKey:@"isInspectionNoteUpdated"];
    NSString *photo_status = [dm objectForKey:@"isInspectionPhotoUpdated"];
    if (note_status || photo_status) {
        if (![note_status isEqual:@"nil"] || ![photo_status isEqual:@"nil"]) {
            // refresh data and clear bit
            [self loadData:TRUE];
            
            [dm setObject:@"nil" forKey:@"isInspectionNoteUpdated"];
            [dm setObject:@"nil" forKey:@"isInspectionPhotoUpdated"];
        }
    }
}
//--- end update monitor functions ---//

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)loadData:(BOOL)withAnimation {

    AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    
    // check if we have a previous data count. This is necessary for the animation loader which
    // fails if we try to reload sections that did not previously exist
    int count = 0;
    if(_a_ns_tableData)count = [_a_ns_tableData count];
    
    // get records; load into array
    _a_ns_tableData = [appDelegate getNotesByProject:selectedProject];
    
    // for section animation we must have at least 1 object before and after reload
    if (withAnimation && [_a_ns_tableData count] && count) {
        //NSRange range = NSMakeRange(0, [self numberOfSectionsInTableView:self.noteTableView]);
        //NSIndexSet *sections = [NSIndexSet indexSetWithIndexesInRange:range];
        
        // reload sections should not be used in place of deletesections. We do not have time to write
        // a complete method to account for ids that need to be removed. Instead, we will check a flag
        // and do 1 or other method of a delete item is set
        if ([dm objectForKey:@"isInspectionNoteToBeDeleted"]) {
            // normal method
            [self.noteTableView reloadData];
            
            // clear flags
            [dm setObject:@"nil" forKey:@"isInspectionNoteToBeDeleted"];
        } else {
            // Note: if the try statement fails, the table will not respond to the default load method.
            // This is just something to contend with for now. It will only an issue since for inspection
            // items that do not have a personal note list. The app comes preloaded, but new items will be an issue.
            
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

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}
- (void)applyCustomColors {
    statusToolbar.barTintColor = [UIColor colorWithRed:37.0/255.0 green:37.0/255.0 blue:37.0/255.0 alpha:1.0];
    statusToolbar.translucent = NO;
    
    _navigationBar.barTintColor = [UIColor colorWithRed:32.0/255.0 green:32.0/255.0 blue:32.0/255.0 alpha:1.0];
    _navigationBar.translucent = NO;
}

- (IBAction)goBackButtonTouch:(id)sender {
    
    //
    // back to main view
    //
    
    // get reference
    UIViewController *mainViewCon = [self.storyboard instantiateViewControllerWithIdentifier:@"applicationDashboard"];
    
    // set options
    mainViewCon.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
    
    // switch views
    [self presentViewController:mainViewCon animated:YES completion:nil];
}
- (IBAction)logoutButtonTouch:(id)sender {
    
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
- (IBAction)openInspectionOnTouch:(id)sender {
    
    //
    // back to main view
    //
    
    // get reference
    UIViewController *mainViewCon = [self.storyboard instantiateViewControllerWithIdentifier:@"applicationDashboard"];
    
    // set options
    mainViewCon.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
    
    // switch views
    [self presentViewController:mainViewCon animated:YES completion:nil];
    
}
- (IBAction)addNoteButtonTouch:(id)sender {
    
    [self performSegueWithIdentifier:@"segueNoteWriter" sender:self];
    
}
- (IBAction)expandMapButtonTouch:(id)sender {
    
    [self performSegueWithIdentifier:@"segueMapExpand" sender:self];
    
}
- (IBAction)showPdfHistoryViewer:(id)sender {
    pdfTitle = @"History";
    pdfItemId = @"1";
    [self performSegueWithIdentifier:@"seguePdfView" sender:self];
}
- (IBAction)showPdfAgreementViewer:(id)sender {
    pdfTitle = @"Agreement";
    pdfItemId = @"2";
    [self performSegueWithIdentifier:@"seguePdfView" sender:self];
}
- (IBAction)showPdfResourceViewer:(id)sender {
    pdfTitle = @"Resources";
    pdfItemId = @"3";
    [self performSegueWithIdentifier:@"seguePdfView" sender:self];
}

- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    // whenever we relinquish control, remember who we are
    //DataManagerObject* dm = [DataManagerObject sharedInstance];
    [dm setObject:selectedProject forKey:@"selectedProject"];
    [dm setObject:delegate forKey:@"projectInfoDelegate"];
    // tell any new views to return there
    [dm setObject:@"projectInfoStoryboardView" forKey:@"pdfParentStoryboardId"];
    
    currentPopoverSegue = (UIStoryboardPopoverSegue *)segue;
    
    if([segue.identifier isEqualToString:@"segueNoteWriter"]) {
        
        // connect with popover
        pvcNoteWriter = [segue destinationViewController];
        
        // pass data into popup using popup's predefined variable
        [pvcNoteWriter setDelegate:self];
        [pvcNoteWriter setSelectedProject:selectedProject];
        [pvcNoteWriter setIsPopup:YES];
        [pvcNoteWriter setTypeOfParent:@"project"];
        [pvcNoteWriter setStrPassedInfo:selectedCell.textLabel.text]; // send current cell label as extra data
        
    } else if([segue.identifier isEqualToString:@"segueNoteEditor"]) {
        
        // connect with popover
        pvcNoteEditor = [segue destinationViewController];
        
        // pass data into popup using popup's predefined variable
        [pvcNoteEditor setDelegate:self];
        [pvcNoteEditor setSelectedNote:selectedNote];
    
    } else if([segue.identifier isEqualToString:@"ProjectViewToAlbum"]) {
        
        // connect with popover
        pvcPictureAlbum = [segue destinationViewController];
        
        // pass data into popup using popup's predefined variable
        [pvcPictureAlbum setDelegate:self];
        [pvcPictureAlbum setSelectedNote:selectedNote];
    
        
        
    } else if([segue.identifier isEqualToString:@"segueProjectInfoToPictureView"]) {
        
        // connect with popover
        pictureAlbum2 = [segue destinationViewController];
        
        // pass data
        [pictureAlbum2 setDelegate:self];
        [pictureAlbum2 setSelectedNote:selectedNote];
        
        
    } else if([segue.identifier isEqualToString:@"segueMapExpand"]) {
        
        // connect with popover
        pvcMapExpanded = [segue destinationViewController];
        
        // pass data into popup using popup's predefined variable
        [pvcMapExpanded setDelegate:self];
        [pvcMapExpanded setZoomLocation:zoomLocation];
    } else if([segue.identifier isEqualToString:@"seguePdfView"]) {
        
        // connect with popover
        pvcPDFList = [segue destinationViewController];
        
        // pass data into popup using popup's predefined variable
        [pvcPDFList setDelegate:self];
        [pvcPDFList setPdfItemId:pdfItemId];
        [pvcPDFList setPdfTitle:pdfTitle];
 
    }
    
}
- (IBAction)showFFAwebsite:(id)sender {
    // whenever we relinquish control, remember who we are
    //DataManagerObject* dm = [DataManagerObject sharedInstance];
    [dm setObject:selectedProject forKey:@"selectedProject"];
    [dm setObject:delegate forKey:@"projectInfoDelegate"];
    // tell any new views to return there
    [dm setObject:@"projectInfoStoryboardView" forKey:@"pdfParentStoryboardId"];
    
    // set web request
    [dm setObject:@"url" forKey:@"requestType"];
    [dm setObject:@"http://www.faa.gov" forKey:@"pdfFilename"];
    
    [self switchToWebViewOnDismissPopover:NO];
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
    //cell.textLabel.text = [_a_ns_projectTableData objectAtIndex:indexPath.row]; // used with string array
    
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
  
    // open editor
    [self performSegueWithIdentifier:@"segueNoteEditor" sender:self];
    
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
    CGRect frame = CGRectMake(44.0, 55.0, accessoryImage.size.width, accessoryImage.size.height);
    accessoryButton.frame = frame;
    [accessoryButton setBackgroundImage:accessoryImage forState:UIControlStateNormal];
    // provide custom event to force-fire the accessory button tap event
    [accessoryButton addTarget:self action:@selector(accessoryButtonTapped:event:) forControlEvents:UIControlEventTouchUpInside];
    accessoryButton.backgroundColor = [UIColor clearColor];
    
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
- (void) onThumnailTap:(UIGestureRecognizer *)gestureRecognizer {
    CGPoint currentTouchPosition = [gestureRecognizer locationInView:_noteTableView];
    NSIndexPath *indexPath = [_noteTableView indexPathForRowAtPoint:currentTouchPosition];
    
    // fire main event if touch is valid
    if(indexPath != nil) {
        selectedNote = [_a_ns_tableData objectAtIndex:indexPath.row];
        
        // open album view
        // ProjectViewToAlbum
        [self performSegueWithIdentifier:@"segueProjectInfoToPictureView" sender:self];
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
        [self performSegueWithIdentifier:@"segueNoteEditor" sender:self];
    }
    
}



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
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    UIImage *selectedPicture = info[UIImagePickerControllerEditedImage];
    
    // If a note was selected, picture will be applied to selection. Otherwise, we create an empty note.
    if (selectedNote == nil) {
        selectedNote = [self insertEmptyNote:self.managedObjectContent relationship:@"project" relationshipEntity:(NSEntityDescription *)selectedProject];
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
    //
    // after view closes, reset troublesome views
    __block ProjectInfoController *selfBlockView = self;
    [picker dismissViewControllerAnimated:YES completion:^(void){
        [selfBlockView onCameraBlockCompleted];
    }];
    
    // refresh view
    //[self.view setNeedsDisplay];
}
- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    
    // after view closes, reset troublesome views
    __block ProjectInfoController *selfBlockView = self;
    [picker dismissViewControllerAnimated:YES completion:^(void){
        [selfBlockView onCameraBlockCompleted];
    }];

    
}

// Still not 100% reliable. Status bar seems to stick for every attempt, but not the navigation bar.
- (void)onCameraBlockCompleted {
    // assing point of 30 instead of the original 32 or 37
    //_navigationBar.barTintColor = [UIColor colorWithRed:30.0/255.0 green:30.0/255.0 blue:30.0/255.0 alpha:1.0];
    //statusToolbar.barTintColor = [UIColor colorWithRed:30.0/255.0 green:30.0/255.0 blue:30.0/255.0 alpha:1.0];
}

//
//
// end Camera operation
//
//

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


@end
