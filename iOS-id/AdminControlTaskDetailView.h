//
//  AdminControlTaskDetailView.h
//  iOS-id
//
//  Created by stephen on 10/8/13.
//  Copyright (c) 2013 stephen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ProjectGroup.h"
#import "TaskTableEditorView.h"

#import "Tasks.h"

@protocol TaskDetailControllerDelegate; // declare a protocol name to be used by the parent for communication

@interface AdminControlTaskDetailView : UIViewController <UITableViewDelegate, UITableViewDataSource, TaskTableEditorControllerDelegate>

- (void)loadData;
- (void)accessoryButtonTapped:(id)sender event:(id)event;

- (IBAction)addTaskRecord:(id)sender;


@property IBOutlet UITextField *taskName;

@property IBOutlet UITableView *tasksTableView;

@property IBOutlet UINavigationItem *titleBarItem;

@property (nonatomic, strong) Tasks *selectedTask;

// parent connections
@property (nonatomic, strong) ProjectGroup *selectedProjectGroup;
@property (weak)id <TaskDetailControllerDelegate> delegate;

// popover control
@property (strong, nonatomic) UIStoryboardPopoverSegue *currentPopoverSegue;
@property (strong, nonatomic) TaskTableEditorView *pvcItemEditor;

@end


// define delegate protocol for parent.
// These protocol declarations dictate what the parent will define
@protocol TaskDetailControllerDelegate <NSObject>


@end
