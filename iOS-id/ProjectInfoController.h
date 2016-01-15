//
//  ProjectInfoController.h
//  iOS-id
//
//  Created by stephen on 10/2/13.
//  Copyright (c) 2013 stephen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import "Projects.h"
#import "ProjectGroup.h"
#import "Tasks.h"
#import "Notes.h"
#import "Photos.h"

#import "PictureAlbumView.h"
#import "PictureAlbumView2.h"
#import "NoteWriterView.h"
#import "NoteTableEditorView.h"
#import "projectInfoMapKit.h"
#import "TableCellPlainLabel.h"
#import "MapExpandedView.h"
#import "PDFListController.h"

#define METERS_PER_MILE 1609.344

@protocol ProjectInfoControllerDelegate; // declare a protocol name to be used by the parent for communication

// delegate note writer by adding it to the interface.
// First delegate namespace is for sending; the second is for receiving
@interface ProjectInfoController : UIViewController <NoteWriterControllerDelegate, NoteTableEditorControllerDelegate, PictureAlbumControllerDelegate,PictureAlbumControllerDelegate2, MapExpandedControllerDelegate, UIPopoverControllerDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITableViewDelegate, UITableViewDataSource, PDFListControllerDelegate>
{
    NSInteger accessoryRowProjectIndex;
    UITableViewCell *selectedCell;
}

// block functions
- (void)onCameraBlockCompleted;

- (void)loadData:(BOOL)withAnimation;

- (UIButton *)createAccessoryButton:(NSString *)imageName;

- (NSIndexPath *)getRowByTouch:(id)event;
- (void) onCameraImageTap:(UIGestureRecognizer *)gestureRecognizer;
- (void) onThumnailTap:(UIGestureRecognizer *)gestureRecognizer;
- (void) onNoteImageTap:(UIGestureRecognizer *)gestureRecognizer;
- (void)applyCustomColors;

- (void)startUpdateMonitor;
- (void)stopUpdateMonitor;
- (void)onUpdateMonitorTimer:(NSTimer *)timer;

@property (weak) NSTimer *updateWatchTimer;
@property (nonatomic, assign) BOOL isMonitorActivationHandled;

- (UITapGestureRecognizer *)createTapRecognizer:(SEL)selector;

- (IBAction)goBackButtonTouch:(id)sender;
- (IBAction)addNoteButtonTouch:(id)sender;
- (IBAction)logoutButtonTouch:(id)sender;
- (IBAction)openInspectionOnTouch:(id)sender;
- (IBAction)expandMapButtonTouch:(id)sender;
- (IBAction)openCameraApp:(id)sender;
- (IBAction)selectImageFromCamera:(id)sender;


- (IBAction)showAddressBook:(id)sender;
- (IBAction)showEventCalendar:(id)sender;
- (IBAction)showPdfHistoryViewer:(id)sender;
- (IBAction)showPdfAgreementViewer:(id)sender;
- (IBAction)showPdfResourceViewer:(id)sender;
- (IBAction)showFFAwebsite:(id)sender;


@property IBOutlet UIView *bioView;
@property IBOutlet UILabel *projectLabel;
@property IBOutlet UITableView *noteTableView;
@property IBOutlet UIToolbar *notesToolbar;
@property IBOutlet UIToolbar *infoToolbar;
@property IBOutlet UIToolbar *statusToolbar;
@property IBOutlet UINavigationItem *navigationItem;
@property IBOutlet UINavigationBar *navigationBar;

//@property (weak, nonatomic) IBOutlet UILabel *cellLabel;

@property (nonatomic) NSInteger accessoryRowProjectIndex;
@property UITableViewCell *selectedCell;

// image collection
@property NSMutableArray *recipePhotos;
@property NSIndexPath *selectedImageCell;

// parent connections
@property (nonatomic, strong) Tasks *selectedTask;
@property (nonatomic, strong) ProjectGroup *selectedProjectGroup;
@property (nonatomic, strong) Projects *selectedProject;
@property (weak)id <ProjectInfoControllerDelegate> delegate;

// child
@property (nonatomic, strong) Notes *selectedNote;
@property (nonatomic, retain) NSString *pdfTitle;
@property (nonatomic, assign) NSString *pdfItemId;

// popover control
@property (strong, nonatomic) UIStoryboardPopoverSegue *currentPopoverSegue;
@property (strong, nonatomic) NoteWriterView *pvcNoteWriter;
@property (strong, nonatomic) NoteTableEditorView *pvcNoteEditor;
@property (strong, nonatomic) PictureAlbumView *pvcPictureAlbum;
@property (strong, nonatomic) MapExpandedView *pvcMapExpanded;
@property (strong, nonatomic) PDFListController *pvcPDFList;


@property (strong, nonatomic) PictureAlbumView2 *pictureAlbum2;

// map
@property IBOutlet MKMapView *projectMapView;
@property CLLocationCoordinate2D zoomLocation;

@end


// define delegate protocol for parent.
// These protocol declarations dictate what the parent will define
@protocol ProjectInfoControllerDelegate <NSObject>


@end
