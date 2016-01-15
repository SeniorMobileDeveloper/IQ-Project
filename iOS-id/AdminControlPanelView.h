//
//  AdminControlPanelView.h
//  iOS-id
//
//  Created by stephen on 10/7/13.
//  Copyright (c) 2013 stephen. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "AdminControlProjectGroupView.h"
#import "ProjectTableEditorView.h"

@interface AdminControlPanelView : UIViewController <UITableViewDelegate, UITableViewDataSource, ProjectGroupControllerDelegate, ProjectTableEditorControllerDelegate, UINavigationControllerDelegate>

- (void)loadProjectData;
- (void)accessoryButtonTapped:(id)sender event:(id)event;

- (IBAction)logoutButtonTouch:(id)sender;
- (IBAction)addProjectRecord:(id)sender;


@property (nonatomic, strong) Projects *selectedProject;
@property (strong, nonatomic) AdminControlProjectGroupView *vcGroup;


@property IBOutlet UITextField *projectNameTextField;

@property IBOutlet UITableView *projectsTableView;

// popover control
@property (strong, nonatomic) UIStoryboardPopoverSegue *currentPopoverSegue;
@property (strong, nonatomic) ProjectTableEditorView *pvcProjectEditor;

@end
