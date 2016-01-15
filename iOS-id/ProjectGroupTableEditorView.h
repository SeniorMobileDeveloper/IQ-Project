//
//  ProjectGroupTableEditorView.h
//  iOS-id
//
//  Created by stephen on 10/10/13.
//  Copyright (c) 2013 stephen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ProjectGroup.h"

@protocol ProjectGroupTableEditorControllerDelegate; // declare a protocol name to be used by the parent for communication

@interface ProjectGroupTableEditorView : UIViewController


- (IBAction)cancelButtonTouch:(id)sender;
- (IBAction)saveButtonTouch:(id)sender;

@property IBOutlet UITextField *nameTextField;

// parent connections
@property (nonatomic, strong) ProjectGroup *selectedProjectGroup;
@property (weak)id <ProjectGroupTableEditorControllerDelegate> delegate;

@end



// define delegate protocol for parent.
// These protocol declarations dictate what the parent will define
@protocol ProjectGroupTableEditorControllerDelegate <NSObject>

@required

- (void) dismissPopover:(BOOL) doclose update:(BOOL)doupdate;

@end
