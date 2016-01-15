//
//  ControlPanelViewController.h
//  iOS-id
//
//  Created by stephen on 10/22/13.
//  Copyright (c) 2013 stephen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ProjectViewController.h"
#import "ProjectInfoController.h"
#import "Projects.h"
#import "PDFListController.h"


@interface ControlPanelViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, ProjectViewControllerDelegate, ProjectInfoControllerDelegate, PDFListControllerDelegate>

- (void)loadData:(BOOL)withAnimation;
- (UIButton *)createAccessoryButton:(NSString *)imageName;
- (void)applyCustomColors;

- (void)startUpdateMonitor;
- (void)stopUpdateMonitor;
- (void)onUpdateMonitorTimer:(NSTimer *)timer;

@property (weak) NSTimer *updateWatchTimer;
@property (nonatomic, assign) BOOL isMonitorActivationHandled;

- (IBAction)showAddressBook:(id)sender;
- (IBAction)showEventCalendar:(id)sender;
- (IBAction)showPdfResourceViewer:(id)sender;
- (IBAction)showFFAwebsite:(id)sender;


- (IBAction)logoutButtonTouch:(id)sender;

@property (nonatomic, strong) Projects *selectedProject;

@property IBOutlet UITableView *projectsTableView;
@property IBOutlet UINavigationItem *navbarItem;
@property IBOutlet UIToolbar *statusToolbar;

// child
@property (strong, nonatomic) ProjectViewController *vcProjectView;
@property (strong, nonatomic) ProjectInfoController *vcProjectInfo;


// child
@property (nonatomic, retain) NSString *pdfTitle;
@property (nonatomic, assign) NSString *pdfItemId;

// popover control
@property (strong, nonatomic) UIStoryboardPopoverSegue *currentPopoverSegue;
@property (strong, nonatomic) PDFListController *pvcPDFList;


@end
