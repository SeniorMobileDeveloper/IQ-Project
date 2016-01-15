//
//  PictureAlbumView.h
//  iOS-id
//
//  Created by stephen on 10/21/13.
//  Copyright (c) 2013 stephen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Photos.h"
#import "Tasks.h"
#import "Projects.h"
#import "PictureAlbumLayout.h"
#import "KTPhotoScrollViewController.h"
#import "PhotoDataSource.h"
#import "PhotoCollectionHeaderView.h"

@protocol PictureAlbumControllerDelegate2; // declare a protocol name to be used by the parent for communication

@interface PictureAlbumView2 : UIViewController <UICollectionViewDelegate, UICollectionViewDataSource, UIImagePickerControllerDelegate>

- (void)loadData;

- (IBAction)openCameraApp:(id)sender;
- (IBAction)selectImageFromCamera:(id)sender;
- (IBAction)doneButtonTouch:(id)sender;
- (IBAction)deleteItemButtonTouch:(id)sender;


// collection view
@property NSIndexPath *selectedImageCell;
@property (nonatomic,weak) IBOutlet PictureAlbumLayout *photoAlbumLayout;

@property IBOutlet UICollectionView *projectImageCollectionView;

@property IBOutlet UIView *mainView;

// parent connections
@property (nonatomic, strong) Tasks *selectedTask;
@property (nonatomic, strong) Projects *selectedProject;
@property (nonatomic, strong) Notes *selectedNote;
@property (weak)id <PictureAlbumControllerDelegate2> delegate;

@end


// define delegate protocol for parent.
// These protocol declarations dictate what the parent will define
@protocol PictureAlbumControllerDelegate2 <NSObject>

@end
