//
//  TaskNoteWriterController.h
//  iOS-id
//
//  Created by stephen on 10/18/13.
//  Copyright (c) 2013 stephen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
#import "Tasks.h"
#import "Notes.h"

#import "PictureAlbumView.h"
#import "PictureAlbumView2.h"
#import "NoteWriterView.h"
#import "NoteTableEditorView.h"
#import "TableCellPlainLabel.h"
#import "PDFListController.h"

@protocol TaskNoteWriterControllerDelegate; // declare a protocol name to be used by the parent for communication

@interface TaskNoteWriterController : UIViewController <UITableViewDelegate, UITableViewDataSource, UIImagePickerControllerDelegate, UINavigationControllerDelegate, NoteWriterControllerDelegate, NoteTableEditorControllerDelegate, PictureAlbumControllerDelegate,PictureAlbumControllerDelegate2, PDFListControllerDelegate, CLLocationManagerDelegate>

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

- (IBAction)addNoteButtonTouch:(id)sender;
- (IBAction)openCameraApp:(id)sender;
- (IBAction)selectImageFromCamera:(id)sender;
- (IBAction)logoutButtonTouch:(id)sender;

- (IBAction)showAddressBook:(id)sender;
- (IBAction)showEventCalendar:(id)sender;
- (IBAction)showPdfResourceViewer:(id)sender;
- (IBAction)showFFAwebsite:(id)sender;

@property IBOutlet UITableView *noteTableView;
@property IBOutlet UIToolbar *notesToolbar;
@property IBOutlet UIToolbar *statusToolbar;
@property IBOutlet UINavigationItem *navbarItem;

@property (nonatomic, strong) Notes *selectedNote;

// parent connections
@property (nonatomic, strong) Tasks *selectedTask;
@property (weak)id <TaskNoteWriterControllerDelegate> delegate;

// popover control
@property (strong, nonatomic) UIStoryboardPopoverSegue *currentPopoverSegue;
@property (strong, nonatomic) NoteWriterView *pvcNoteWriter;
@property (strong, nonatomic) NoteTableEditorView *pvcNoteEditor;
@property (strong, nonatomic) PictureAlbumView *pvcPictureAlbum;

@property (strong, nonatomic) PictureAlbumView2 *pictureAlbum2;

// child
@property (nonatomic, retain) NSString *pdfTitle;
@property (nonatomic, assign) NSString *pdfItemId;

// popover control
@property (strong, nonatomic) PDFListController *pvcPDFList;

@property (nonatomic, strong) CLLocationManager *locationManager;

@end

// define delegate protocol for parent.
// These protocol declarations dictate what the parent will define
@protocol TaskNoteWriterControllerDelegate <NSObject>


@end
