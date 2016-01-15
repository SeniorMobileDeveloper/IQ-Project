//
//  NoteWriterView.h
//  iOS-id
//
//  Created by stephen on 10/3/13.
//  Copyright (c) 2013 stephen. All rights reserved.
//

#import <UIKit/UIKit.h> 
#import "Tasks.h"
#import "Projects.h"
#import "Notes.h"


@protocol NoteWriterControllerDelegate; // declare a protocol name to be used by the parent for communication

@interface NoteWriterView : UIViewController

- (IBAction)saveButtonTouch:(id)sender;
- (IBAction)cancelButtonTouchInPopup:(id)sender;
- (IBAction)saveButtonTouchInPopup:(id)sender;

- (void)returnToParentView;
- (void)removeToolbarControl;
- (void)hideToolbarControl;
- (void)addNoteToRecord;

@property IBOutlet UITextView *noteTextBox;
@property IBOutlet UIToolbar *controlToolbar;

// parent connections
@property (strong, nonatomic)NSString * storyboardName;
@property (nonatomic,assign) BOOL isPopup;
@property (strong, nonatomic)Tasks * selectedTask;
@property (nonatomic, strong)Projects *selectedProject;
@property (strong, nonatomic)NSString * typeOfParent;
@property (strong, nonatomic)NSString * strPassedInfo; // sent from parent
@property (weak)id <NoteWriterControllerDelegate> delegate;

//@property (strong, nonatomic)ProjectViewController *vcProjectView;

@end


// define delegate protocol for parent.
// These protocol declarations dictate what the parent will define
@protocol NoteWriterControllerDelegate <NSObject>

////@required

@optional
- (void) dismissPopover:(BOOL) docancel;


//- (void)dismissView:(NoteWriterView *)lvc;

@end