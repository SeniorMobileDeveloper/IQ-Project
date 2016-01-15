//
//  ProjectViewController.h
//  iOS-id
//
//  Created by stephen on 10/1/13.
//  Copyright (c) 2013 stephen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreText/CoreText.h>
#import "Projects.h"
#import "Tasks.h"
#import "ProjectGroup.h"
#import "TaskNoteWriterController.h"
#import "TableCellPlainLabel.h"
#import "PDFListController.h"
#import "PDFRenderer.h"

#import "CollapsableTableViewDelegate.h"
#import "SVSegmentedControl.h"

@protocol ProjectViewControllerDelegate; // declare a protocol name to be used by the parent for communication

@interface ProjectViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, CollapsableTableViewDelegate, TaskNoteWriterControllerDelegate, PDFListControllerDelegate, UIGestureRecognizerDelegate>
{
    // expandable table
    NSMutableIndexSet *expandedSections;
    IBOutlet UIActivityIndicatorView *spinner;
}
// TableExpander
- (IBAction) toggleSection2;

- (void)showDebugMessage:(NSString *)msg;
- (void)loadData:(BOOL)withAnimation;

- (NSMutableArray *)getTasksByTableSection:(NSIndexPath *)indexPath;
//- (void)switchValueChanged:(id)sender;
- (void)applyCustomColors;
- (UIButton *)createAccessoryButton:(NSString *)imageName;

- (void)startUpdateMonitor;
- (void)stopUpdateMonitor;
- (void)onUpdateMonitorTimer:(NSTimer *)timer;

@property (weak) NSTimer *updateWatchTimer;
@property (nonatomic, assign) BOOL isMonitorActivationHandled;

//- (CGFloat)heightForCellView:(UITextView*)textView containingString:(NSString*)string;

- (IBAction)logoutButtonTouch:(id)sender;

- (IBAction)showAddressBook:(id)sender;
- (IBAction)showEventCalendar:(id)sender;
- (IBAction)showPdfResourceViewer:(id)sender;
- (IBAction)showFFAwebsite:(id)sender;

@property (nonatomic, strong) Projects *selectedProject;
@property (nonatomic, strong) Tasks *selectedTask;
@property (nonatomic, strong) ProjectGroup *selectedGroup;
@property IBOutlet UIToolbar *statusToolbar;
@property IBOutlet UILabel *projectLabel;

// note control
@property (strong, nonatomic) TaskNoteWriterController *vcNoteWriter;


@property IBOutlet UITableView *projectsTableView;
@property IBOutlet UINavigationItem *navbarItem;

// parent connections
@property (weak)id <ProjectViewControllerDelegate> delegate;

// child
@property (nonatomic, retain) NSString *pdfTitle;
@property (nonatomic, assign) NSString *pdfItemId;

// popover control
@property (strong, nonatomic) UIStoryboardPopoverSegue *currentPopoverSegue;
@property (strong, nonatomic) PDFListController *pvcPDFList;

@end

// define delegate protocol for parent.
// These protocol declarations dictate what the parent will define
@protocol ProjectViewControllerDelegate <NSObject>


@end
