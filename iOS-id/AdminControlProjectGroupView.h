//
//  AdminControlProjectGroupView.h
//  iOS-id
//
//  Created by stephen on 10/9/13.
//  Copyright (c) 2013 stephen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AdminControlTaskDetailView.h"
#import "ProjectGroupTableEditorView.h"

#import "Projects.h"
#import "ProjectGroup.h"

@protocol ProjectGroupControllerDelegate; // declare a protocol name to be used by the parent for communication

@interface AdminControlProjectGroupView : UIViewController <UITableViewDelegate, UITableViewDataSource, TaskDetailControllerDelegate, ProjectGroupTableEditorControllerDelegate>

- (void)loadData;
- (void)accessoryButtonTapped:(id)sender event:(id)event;

- (IBAction)addRecord:(id)sender;

@property IBOutlet UITextField *groupName;

@property IBOutlet UITableView *groupTableView;

@property IBOutlet UINavigationItem *titleBarItem;


// parent connections
@property (nonatomic, strong) Projects *selectedProject;
@property (weak)id <ProjectGroupControllerDelegate> delegate;

// child connections
@property (nonatomic, strong) ProjectGroup *selectedProjectGroup;
@property (strong, nonatomic) AdminControlTaskDetailView *vcTaskDetail;

// popover control
@property (strong, nonatomic) UIStoryboardPopoverSegue *currentPopoverSegue;
@property (strong, nonatomic) ProjectGroupTableEditorView *pvcItemEditor;

@end


// define delegate protocol for parent.
// These protocol declarations dictate what the parent will define
@protocol ProjectGroupControllerDelegate <NSObject>


@end
