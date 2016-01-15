//
//  NSObject+DataCoreHandler.h
//  iOS-id
//
//  Created by stephen on 10/20/13.
//  Copyright (c) 2013 stephen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AppDelegate.h"
#import "Notes.h"
#import "Photos.h"
#import "Projects.h"
#import "ProjectGroup.h"
#import "Tasks.h"
#import "Pdf.h"
#import "Company.h"

@interface NSObject (DataCoreHandler)

- (Notes *)insertEmptyNote:(NSManagedObjectContext *)managedObjectContent relationship:(NSString *)typeOf relationshipEntity:(NSEntityDescription *)entity;

- (UIImageView *)loadNoteThumbnailByCoreDataPhotos:(NSMutableArray *)photoitems;

- (BOOL)rebuildDatabase:(NSManagedObjectContext *)managedObjectContent;
- (BOOL)rebuildDatabaseOnEmpty:(AppDelegate *)appDelegate managedObjectContent:(NSManagedObjectContext *)managedObjectContent delayBuild:(BOOL)delayBuild;
- (BOOL)installDatabasePhotos:(AppDelegate *)appDelegate managedObjectContent:(NSManagedObjectContext *)managedObjectContent;

- (void)createGroupsAndTasksForProject:(Projects *)project items:(NSArray *)items tasks:(NSArray *)tasks noteItems:(NSArray *)noteItems photoItems:(NSArray *)photoItems managedobject:(NSManagedObjectContext *)managedObjectContent;

- (void)createTasksForGroup:(ProjectGroup *)group items:(NSArray *)items noteItems:(NSArray *)noteItems photoItems:(NSArray *)photoItems managedobject:(NSManagedObjectContext *)managedObjectContent;
- (void)createNotesForTasks:(Tasks *)task note:(NSString *)noteMessage photo:(NSString *)photoName managedobject:(NSManagedObjectContext *)managedObjectContent;

- (void)createPdfs:(NSManagedObjectContext *)managedObjectContent;
- (void)applyDataSampleToEntry:(Projects *)projectEntry managedobject:(NSManagedObjectContext *)managedObjectContent;


@end
