//
//  AppDelegate.h
//  iOS-id
//
//  Created by stephen on 9/25/13.
//  Copyright (c) 2013 stephen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Projects.h"
#import "ProjectGroup.h"
#import "Tasks.h"
#import "Notes.h"
#import "Photos.h"
#import "Pdf.h"
#import "Config.h"

@interface AppDelegate : UIResponder <UIApplicationDelegate>
{
    // expandable table
    UIWindow *window;
}

// Included IBOutlet option for expandable table
@property (strong, nonatomic) IBOutlet UIWindow *window;


// data core methods
- (NSManagedObjectContext *)getContextInstance;
- (NSMutableArray *)getAllProjects;
- (NSMutableArray *)getAllPhotos;
- (NSMutableArray *)getTasksByGroup:(ProjectGroup *)item;
- (NSMutableArray *)getGroupsByProject:(Projects *)item;
- (NSMutableArray *)getNotesByTask:(Tasks *)item;
- (NSMutableArray *)getNotesByProject:(Projects *)item;
- (NSMutableArray *)getPhotosByNote:(Notes *)item;
- (NSMutableArray *)getPDFListById:(NSString *)itemid;
- (NSString *)getLastTimeStamp;
- (Projects *)getInspection:(NSDictionary *)item;
- (ProjectGroup *)getProjectGroup:(NSDictionary *)item;
- (Tasks *)getTask:(NSDictionary *)item;
- (Notes *)getNote:(NSDictionary *)item;
- (void)setLastTimeStamp:(NSString *)strtime;
- (BOOL)setTimestampObject;

// data core properties
@property (nonatomic, retain, readonly) NSManagedObjectModel *managedObjectModel;
@property (nonatomic, retain, readonly) NSManagedObjectContext *managedObjectContent;
@property (nonatomic, retain, readonly) NSPersistentStoreCoordinator *persistentStoreCoordinator;

@property (nonatomic, strong) Config *timestampEntryObject;
@property (nonatomic, strong) NSString *lastTimeStamp;

@end
