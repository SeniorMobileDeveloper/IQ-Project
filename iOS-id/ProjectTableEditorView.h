//
//  ProjectTableEditorView.h
//  iOS-id
//
//  Created by stephen on 10/9/13.
//  Copyright (c) 2013 stephen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Projects.h"


@protocol ProjectTableEditorControllerDelegate; // declare a protocol name to be used by the parent for communication

@interface ProjectTableEditorView : UIViewController

- (IBAction)cancelButtonTouch:(id)sender;
- (IBAction)saveButtonTouch:(id)sender;

@property IBOutlet UITextField *projectNameTextField;

// parent connections
@property (nonatomic, strong) Projects *selectedProject;
@property (weak)id <ProjectTableEditorControllerDelegate> delegate;

@end



// define delegate protocol for parent.
// These protocol declarations dictate what the parent will define
@protocol ProjectTableEditorControllerDelegate <NSObject>

@required

- (void) dismissPopover:(BOOL) doclose update:(BOOL)doupdate;

@end