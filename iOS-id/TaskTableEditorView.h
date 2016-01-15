//
//  TaskTableEditorView.h
//  iOS-id
//
//  Created by stephen on 10/9/13.
//  Copyright (c) 2013 stephen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Tasks.h"

@protocol TaskTableEditorControllerDelegate; // declare a protocol name to be used by the parent for communication

@interface TaskTableEditorView : UIViewController


- (IBAction)cancelButtonTouch:(id)sender;
- (IBAction)saveButtonTouch:(id)sender;

@property IBOutlet UITextField *nameTextField;

// parent connections
@property (nonatomic, strong) Tasks *selectedTask;
@property (weak)id <TaskTableEditorControllerDelegate> delegate;


@end


// define delegate protocol for parent.
// These protocol declarations dictate what the parent will define
@protocol TaskTableEditorControllerDelegate <NSObject>

@required

- (void) dismissPopover:(BOOL) doclose update:(BOOL)doupdate;

@end