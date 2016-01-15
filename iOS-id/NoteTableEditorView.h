//
//  NoteTableEditorView.h
//  iOS-id
//
//  Created by stephen on 10/18/13.
//  Copyright (c) 2013 stephen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Notes.h"

@protocol NoteTableEditorControllerDelegate; // declare a protocol name to be used by the parent for communication

@interface NoteTableEditorView : UIViewController

- (IBAction)cancelButtonTouch:(id)sender;
- (IBAction)saveButtonTouch:(id)sender;

@property IBOutlet UITextView *noteTextView;

// parent connections
@property (nonatomic, strong) Notes *selectedNote;
@property (weak)id <NoteTableEditorControllerDelegate> delegate;


@end


// define delegate protocol for parent.
// These protocol declarations dictate what the parent will define
@protocol NoteTableEditorControllerDelegate <NSObject>

@optional

- (void) dismissPopover:(BOOL) doclose update:(BOOL)doupdate;

@end
