//
//  ControlPanelTableController.h
//  iOS-id
//
//  Created by stephen on 10/17/13.
//  Copyright (c) 2013 stephen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ProjectViewController.h"
#import "ProjectInfoController.h"
#import "Projects.h"

@interface ControlPanelTableController : UITableViewController <ProjectViewControllerDelegate, ProjectInfoControllerDelegate>

- (void)loadProjectData;
- (UIButton *)createAccessoryButton:(NSString *)imageName;

- (IBAction)logoutButtonTouch:(id)sender;

@property (nonatomic, strong) Projects *selectedProject;

@property IBOutlet UITableView *projectsTableView;

// child
@property (strong, nonatomic) ProjectViewController *vcProjectView;
@property (strong, nonatomic) ProjectInfoController *vcProjectInfo;


@end
