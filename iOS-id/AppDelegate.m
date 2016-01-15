//
//  AppDelegate.m
//  iOS-id
//
//  Created by stephen on 9/25/13.
//  Copyright (c) 2013 stephen. All rights reserved.
//

#import "AppDelegate.h"
#import "DataManagerObject.h"
#import "NSObject+CommonFunctions.h"


@implementation AppDelegate

@synthesize window;

// data core
@synthesize managedObjectContent = _managedObjectContent;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;
@synthesize timestampEntryObject;
@synthesize lastTimeStamp;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Override point for customization after application launch.
    return YES;
}
							
- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

//
// Core Data Methods
//

- (NSManagedObjectContext *)getContextInstance
{
    return self.managedObjectContent;
}

- (NSMutableArray *)getAllProjects {
    // initialize
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    
    // set entity into query
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Projects" inManagedObjectContext:self.managedObjectContent];
    [fetchRequest setEntity:entity];
    
    // sort
    NSSortDescriptor *sort = [[NSSortDescriptor alloc] initWithKey:@"sort" ascending:YES];
    NSSortDescriptor *sortByName = [[NSSortDescriptor alloc] initWithKey:@"project_name" ascending:YES];
    NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:sort,sortByName,nil];
    [fetchRequest setSortDescriptors:sortDescriptors];
    //[fetchRequest setSortDescriptors:[NSArray arrayWithObject:sort]]; // quick statement if using only 1 sort field
    //[fetchRequest setFetchBatchSize:20];
    
    // fetch data
    NSError *error;
    NSMutableArray *fetchedRecords = [[self.managedObjectContent executeFetchRequest:fetchRequest error:&error] mutableCopy];
    
    return fetchedRecords;
}
- (NSMutableArray *)getAllPhotos {
    // initialize
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    
    // set entity into query
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Photos" inManagedObjectContext:self.managedObjectContent];
    [fetchRequest setEntity:entity];
    
    // sort
    NSSortDescriptor *sort = [[NSSortDescriptor alloc] initWithKey:@"sort" ascending:YES];
    NSSortDescriptor *sortByDate = [[NSSortDescriptor alloc] initWithKey:@"photo_date_created" ascending:NO];
    NSSortDescriptor *sortByName = [[NSSortDescriptor alloc] initWithKey:@"photo_name" ascending:YES];
    NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:sort,sortByDate,sortByName,nil];
    [fetchRequest setSortDescriptors:sortDescriptors];
    //[fetchRequest setSortDescriptors:[NSArray arrayWithObject:sort]]; // quick statement if using only 1 sort field
    //[fetchRequest setFetchBatchSize:20];
    
    // fetch data
    NSError *error;
    NSMutableArray *fetchedRecords = [[self.managedObjectContent executeFetchRequest:fetchRequest error:&error] mutableCopy];
    
    return fetchedRecords;
}
- (NSMutableArray *)getTasksByGroup:(ProjectGroup *)item {
    // initialize
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    
    // set entity into query
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Tasks" inManagedObjectContext:self.managedObjectContent];
    [fetchRequest setEntity:entity];
    
    // sort
    NSSortDescriptor *sort = [[NSSortDescriptor alloc] initWithKey:@"sort" ascending:YES];
    NSSortDescriptor *sortByName = [[NSSortDescriptor alloc] initWithKey:@"task_name" ascending:YES];
    NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:sort,sortByName,nil];
    [fetchRequest setSortDescriptors:sortDescriptors];
    //[fetchRequest setSortDescriptors:[NSArray arrayWithObject:sort]]; // quick statement if using only 1 sort field
    //[fetchRequest setFetchBatchSize:20];
    
    // create predicate filter
    //NSPredicate *pred = [NSPredicate predicateWithFormat:@"name CONTAINS %a",@"1099"];
    //[fetchRequest setPredicate:pred];
    //
    [fetchRequest setPredicate:[NSPredicate predicateWithFormat:@"group == %@",item]];
    
    
    // fetch data
    NSError *error;
    NSMutableArray *fetchedRecords = [[self.managedObjectContent executeFetchRequest:fetchRequest error:&error] mutableCopy];
    
    return fetchedRecords;
}
- (NSMutableArray *)getGroupsByProject:(Projects *)item {
    // initialize
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    
    // set entity into query
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"ProjectGroup" inManagedObjectContext:self.managedObjectContent];
    [fetchRequest setEntity:entity];
    
    // sort
    NSSortDescriptor *sort = [[NSSortDescriptor alloc] initWithKey:@"sort" ascending:YES];
    NSSortDescriptor *sortByName = [[NSSortDescriptor alloc] initWithKey:@"projectgroup_name" ascending:YES];
    NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:sort,sortByName,nil];
    [fetchRequest setSortDescriptors:sortDescriptors];
    //[fetchRequest setSortDescriptors:[NSArray arrayWithObject:sort]]; // quick statement if using only 1 sort field
    //[fetchRequest setFetchBatchSize:20];
    
    // create predicate filter
    [fetchRequest setPredicate:[NSPredicate predicateWithFormat:@"project == %@",item]];
    
    
    // fetch data
    NSError *error;
    NSMutableArray *fetchedRecords = [[self.managedObjectContent executeFetchRequest:fetchRequest error:&error] mutableCopy];
    
    return fetchedRecords;
}
- (NSMutableArray *)getNotesByProject:(Projects *)item {
    // initialize
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    
    // set entity into query
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Notes" inManagedObjectContext:self.managedObjectContent];
    [fetchRequest setEntity:entity];
    
    // sort
    NSSortDescriptor *sort = [[NSSortDescriptor alloc] initWithKey:@"sort" ascending:YES];
    NSSortDescriptor *sortByDate = [[NSSortDescriptor alloc] initWithKey:@"date_created" ascending:NO];
    NSSortDescriptor *sortByName = [[NSSortDescriptor alloc] initWithKey:@"name" ascending:YES];
    NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:sort,sortByDate,sortByName,nil];
    [fetchRequest setSortDescriptors:sortDescriptors];
    //[fetchRequest setSortDescriptors:[NSArray arrayWithObject:sort]]; // quick statement if using only 1 sort field
    //[fetchRequest setFetchBatchSize:20];
    
    // create predicate filter
    [fetchRequest setPredicate:[NSPredicate predicateWithFormat:@"project == %@",item]];
    
    
    // fetch data
    NSError *error;
    NSMutableArray *fetchedRecords = [[self.managedObjectContent executeFetchRequest:fetchRequest error:&error] mutableCopy];
    
    return fetchedRecords;
}
- (NSMutableArray *)getPhotosByNote:(Notes *)item {
    // initialize
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    
    // set entity into query
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Photos" inManagedObjectContext:self.managedObjectContent];
    [fetchRequest setEntity:entity];
    
     // Order the photos by creation date, most recent first.

     // sort
     NSSortDescriptor *sort = [[NSSortDescriptor alloc] initWithKey:@"sort" ascending:YES];
     NSSortDescriptor *sortByDate = [[NSSortDescriptor alloc] initWithKey:@"photo_date_created" ascending:NO];
     NSSortDescriptor *sortByName = [[NSSortDescriptor alloc] initWithKey:@"photo_name" ascending:YES];
     NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:sort,sortByDate,sortByName,nil];
     [fetchRequest setSortDescriptors:sortDescriptors];
     //[fetchRequest setSortDescriptors:[NSArray arrayWithObject:sort]]; // quick statement if using only 1 sort field
     //[fetchRequest setFetchBatchSize:20];
    
    
    // create predicate filter
    [fetchRequest setPredicate:[NSPredicate predicateWithFormat:@"note == %@",item]];
    
    
    // fetch data
    NSError *error;
    NSMutableArray *fetchedRecords = [[self.managedObjectContent executeFetchRequest:fetchRequest error:&error] mutableCopy];
    
    return fetchedRecords;
}
- (NSMutableArray *)getNotesByTask:(Tasks *)item {
    // initialize
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    
    // set entity into query
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Notes" inManagedObjectContext:self.managedObjectContent];
    [fetchRequest setEntity:entity];
    
    // sort
    NSSortDescriptor *sort = [[NSSortDescriptor alloc] initWithKey:@"sort" ascending:YES];
    NSSortDescriptor *sortByDate = [[NSSortDescriptor alloc] initWithKey:@"date_created" ascending:NO];
    NSSortDescriptor *sortByName = [[NSSortDescriptor alloc] initWithKey:@"name" ascending:YES];
    NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:sort,sortByDate,sortByName,nil];
    [fetchRequest setSortDescriptors:sortDescriptors];
    //[fetchRequest setSortDescriptors:[NSArray arrayWithObject:sort]]; // quick statement if using only 1 sort field
    //[fetchRequest setFetchBatchSize:20];
    
    // create predicate filter
    [fetchRequest setPredicate:[NSPredicate predicateWithFormat:@"task == %@",item]];
    
    
    // fetch data
    NSError *error;
    NSMutableArray *fetchedRecords = [[self.managedObjectContent executeFetchRequest:fetchRequest error:&error] mutableCopy];
    
    return fetchedRecords;
}
- (NSMutableArray *)getPDFListById:(NSString *)itemid {
    // initialize
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    
    // set entity into query
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Pdf" inManagedObjectContext:self.managedObjectContent];
    [fetchRequest setEntity:entity];
    
    // no need to sort
    
    // create predicate filter
    NSNumber *numitem = (NSNumber *)itemid;
    [fetchRequest setPredicate:[NSPredicate predicateWithFormat:@"pdf_type == %@",numitem]];
    
    
    // fetch data
    NSError *error;
    NSMutableArray *fetchedRecords = [[self.managedObjectContent executeFetchRequest:fetchRequest error:&error] mutableCopy];
    
    return fetchedRecords;
}

- (NSString *)getLastTimeStamp {
  
    // if we haven't set the time object or the stamp value, try to set them now
    if (!timestampEntryObject || !lastTimeStamp) {
        // retrieve last timestamp
        if([self setTimestampObject]) {
            // set session variable
            lastTimeStamp = [timestampEntryObject valueForKey:@"last_update_timestamp"];
        }
    } else {
        // we have a situation in which the timestamp is sent back as a string and gets
        // locked into the loop. We work with strings but the base value is a number.
        // To prevent a real date from being passed around, we evaluate the value
        if (![self convertStringToNumber:lastTimeStamp]) { // we could also check against NSDate I believe
            // we got 0 even though lastTimeStamp evaulated as being set.
            // We probably have a date type instead of a number
            lastTimeStamp = [timestampEntryObject valueForKey:@"last_update_timestamp"];
        }
    }
    
    return lastTimeStamp;
}
- (void)setLastTimeStamp:(NSString *)strtime {
    
    BOOL doUpdate = FALSE;
    
    // set global
    lastTimeStamp = strtime;
    
    // if we haven't set the time object, try to set it now
    if (!timestampEntryObject) {
        // retrieve last timestamp
        if([self setTimestampObject]) {
            doUpdate = TRUE;
        }
    } else {
        doUpdate = TRUE;
    }
    
    // call database
    
    //[strtime isKindOfClass:[NSNumber class]];
    
    
    if (doUpdate) { // update
        [timestampEntryObject setValue:[self convertStringToNumber:strtime] forKey:@"last_update_timestamp"];
        
    } else { // insert
        // create instance of table
        Config *newEntry = [NSEntityDescription insertNewObjectForEntityForName:@"Config" inManagedObjectContext:self.managedObjectContent];
        
        // cast strtime as a number for Core data
        newEntry.last_update_timestamp = [self convertStringToNumber:strtime];
    }
    
    // execute
    NSError *error;
    //@try {
        if (![self.managedObjectContent save:&error]) {
            NSLog(@"Error, could not save %@ to local device",[error localizedDescription]);
        }
    //}
    //@catch (NSException *exception) {
    //    NSString *strerror = @"error";
    //}
    //@finally {
        //
    //}
    
    
}
- (BOOL)setTimestampObject {
    
    BOOL didSucceed = FALSE;
 
    // initialize
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    
    // set entity into query - Config
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Config" inManagedObjectContext:self.managedObjectContent];
    [fetchRequest setEntity:entity];
    
    // create filter
    //[fetchRequest setResultType:NSDictionaryResultType];
    //[fetchRequest setReturnsDistinctResults:YES];
    [fetchRequest setPropertiesToFetch:@[@"last_update_timestamp"]];
    
  
    // fetch data
    NSError *error;
    
    NSArray *objects = [self.managedObjectContent executeFetchRequest:fetchRequest error:&error];
    if ([objects count] > 0) {

        didSucceed = TRUE;
        
        // if we haven't set the time object, try to set it now
        if (!timestampEntryObject) {
            timestampEntryObject = [objects objectAtIndex:0];
        }
       
        // We should only have 1 item but as an example for finding a specific value
        // from a returned dictionary. This example assumes we retrieved data from the
        // Projects table with the project_name attribute
        /*
        for (NSDictionary * objectInstance in objects) {
            NSLog(@"Value: %@", [objectInstance valueForKey:@"project_name"]);
            
            if ([[objectInstance valueForKey:@"project_name"] isEqual:@"BOEING 747 (SF-34)"]) {
                fetchedValue = [objectInstance valueForKey:@"project_name"];
            }
        }
        */

    }
    
    return didSucceed;
}

- (Projects *)getInspection:(NSDictionary *)item  {
    
    //NSError *err = nil;
    //NSManagedObjectID * itemId = (NSManagedObjectID *)[item valueForKey:@"_id"];
    //Projects * proj = (Projects *)[self.managedObjectContent existingObjectWithID:itemId error:&err];
    
    //NSManagedObjectID *oid = [[[self managedObjectContent] persistentStoreCoordinator] managedObjectIDForURIRepresentation:[item valueForKey:@"_id"]];
    
    
    //NSManagedObject *mo = [self.managedObjectContent objectWithID:[NSPersistentStoreCoordinator managedObjectIDforURIRepresentation:[NSURL URLWithString:[item valueForKey:@"id"]]]];
    
    
    
    // initialize
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    
    // set entity into query
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Projects" inManagedObjectContext:self.managedObjectContent];
    [fetchRequest setEntity:entity];
    
    // set params
    NSNumber *numId = (NSNumber *)[item valueForKey:@"db_id"];
    
    // create filter
    //[fetchRequest setResultType:NSDictionaryResultType];
    //[fetchRequest setReturnsDistinctResults:YES];
   
    // create predicate filter.
    // Projects are the inspections. They are at the top level and only require an ID search
    [fetchRequest setPredicate:[NSPredicate predicateWithFormat:@"id == %@",numId]];
    
    // fetch data
    NSError *error;
    
    NSArray *objects = [self.managedObjectContent executeFetchRequest:fetchRequest error:&error];
    if ([objects count] > 0) {
        
        
        return [objects objectAtIndex:0];
        
        // We should only have 1 item but as an example for finding a specific value
        // from a returned dictionary. This example assumes we retrieved data from the
        // Projects table with the project_name attribute
        /*
         for (NSDictionary * objectInstance in objects) {
         NSLog(@"Value: %@", [objectInstance valueForKey:@"project_name"]);
         
         if ([[objectInstance valueForKey:@"project_name"] isEqual:@"BOEING 747 (SF-34)"]) {
         fetchedValue = [objectInstance valueForKey:@"project_name"];
         }
         }
         */
        
    }
    
    return NULL;
}
- (ProjectGroup *)getProjectGroup:(NSDictionary *)item  {
    
    // initialize
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    
    // set entity into query
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"ProjectGroup" inManagedObjectContext:self.managedObjectContent];
    [fetchRequest setEntity:entity];
    
    // set params
    NSNumber *numId = (NSNumber *)[item valueForKey:@"db_id"];
    
    // create filter
    //[fetchRequest setResultType:NSDictionaryResultType];
    //[fetchRequest setReturnsDistinctResults:YES];
    
    // create predicate filter
    [fetchRequest setPredicate:[NSPredicate predicateWithFormat:@"id == %@",numId]];
    
    // fetch data
    NSError *error;
    
    NSArray *objects = [self.managedObjectContent executeFetchRequest:fetchRequest error:&error];
    if ([objects count] > 0) {
        
        
        return [objects objectAtIndex:0];
 
    }
    
    return NULL;
}
- (Tasks *)getTask:(NSDictionary *)item  {
    
    // initialize
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    
    // set entity into query
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Tasks" inManagedObjectContext:self.managedObjectContent];
    [fetchRequest setEntity:entity];
    
    // set params
    NSNumber *numId = (NSNumber *)[item valueForKey:@"db_id"];
    
    // create filter
    //[fetchRequest setResultType:NSDictionaryResultType];
    //[fetchRequest setReturnsDistinctResults:YES];
    
    // create predicate filter
    [fetchRequest setPredicate:[NSPredicate predicateWithFormat:@"id == %@",numId]];
    
    // fetch data
    NSError *error;
    
    NSArray *objects = [self.managedObjectContent executeFetchRequest:fetchRequest error:&error];
    if ([objects count] > 0) {
        
        
        return [objects objectAtIndex:0];
        
    }
    
    return NULL;
}
- (Notes *)getNote:(NSDictionary *)item  {
    
    // initialize
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    
    // set entity into query
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Notes" inManagedObjectContext:self.managedObjectContent];
    [fetchRequest setEntity:entity];
    
    // set params
    NSNumber *numId = (NSNumber *)[item valueForKey:@"db_id"];
    
    // create filter
    //[fetchRequest setResultType:NSDictionaryResultType];
    //[fetchRequest setReturnsDistinctResults:YES];
    
    // create predicate filter
    [fetchRequest setPredicate:[NSPredicate predicateWithFormat:@"id == %@",numId]];
    
    // fetch data
    NSError *error;
    
    NSArray *objects = [self.managedObjectContent executeFetchRequest:fetchRequest error:&error];
    if ([objects count] > 0) {
        
        
        return [objects objectAtIndex:0];
        
    }
    
    return NULL;
}
- (NSManagedObjectContext *) managedObjectContent {
    if(_managedObjectContent != nil) {
        return _managedObjectContent;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (coordinator != nil) {
        _managedObjectContent = [[NSManagedObjectContext alloc] init];
        [_managedObjectContent setPersistentStoreCoordinator:coordinator];
    }
    
    return _managedObjectContent;
}
- (NSManagedObjectModel *) managedObjectModel {
    if(_managedObjectModel != nil) {
        return _managedObjectModel;
    }
    
    _managedObjectModel = [NSManagedObjectModel mergedModelFromBundles:nil];
    
    return  _managedObjectModel;
}
/*
- (NSPersistentStoreCoordinator *) persistentStoreCoordinator {
    if (_persistentStoreCoordinator != nil) {
        return _persistentStoreCoordinator;
    }
    
    NSURL *storeUrl = [NSURL fileURLWithPath:[[self applicationDocumentsDirectory] stringByAppendingPathComponent:@"ProjectBook.sqlite"]];
    NSError *error = nil;
    if (![[NSFileManager defaultManager] fileExistsAtPath:[storeUrl path]]) {
        //NSURL *preloadURL = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"ProjectBook" ofType:@"sqlite"]];
        //if(![[NSFileManager defaultManager] copyItemAtURL:preloadURL toURL:storeUrl error:&error]) {
        //    NSLog(@"could not copy preloaded data");
        //}
        
        // alert app to rebuild database
        DataManagerObject* dm = [DataManagerObject sharedInstance];
        [dm setObject:@"rebuild" forKey:@"database"];
    }
    
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    
    // 1099 add database version migration statement
    NSDictionary *storeoptions = @{NSMigratePersistentStoresAutomaticallyOption:@YES, NSInferMappingModelAutomaticallyOption:@YES};
    
    // 1099 added storeoptions to following statement
    if ([_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeUrl options:storeoptions error:&error]) {
        // handle error fore store creation
    }
    
    return _persistentStoreCoordinator;
}
*/
// Returns the persistent store coordinator for the application.
// If the coordinator doesn't already exist, it is created and the application's store added to it.
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator
{
    if (_persistentStoreCoordinator != nil) {
        return _persistentStoreCoordinator;
    }
    
    DataManagerObject* dm = [DataManagerObject sharedInstance];
    
    NSURL *storeURL = [NSURL fileURLWithPath:[[self applicationDocumentsDirectory] stringByAppendingPathComponent:@"ProjectBook.sqlite"]];
    
    NSError *error = nil;
    
    // Typically, the only time the SQL database does not exist in the bundle is when we are building a new set.
    if ([[NSFileManager defaultManager] fileExistsAtPath:[[NSBundle mainBundle] pathForResource:@"ProjectBook" ofType:@"sqlite"]]) {
        
        // We add a new migration method below to provide a prepopulated database
        if (![[NSFileManager defaultManager] fileExistsAtPath:[storeURL path]]) {
            
            NSURL *preloadURL = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"ProjectBook" ofType:@"sqlite"]];
            if(![[NSFileManager defaultManager] copyItemAtURL:preloadURL toURL:storeURL error:&error]) {
                //    NSLog(@"could not copy preloaded data");
            } else {
                // photos must be inserted after database copy. To do this, we tell the
                // main view to handle the routine
                [dm setObject:@"rebuildPhotos" forKey:@"database"];
            }
            
            // alert app to rebuild database
            //DataManagerObject* dm = [DataManagerObject sharedInstance];
            //[dm setObject:@"rebuild" forKey:@"database"];
        }
        
    } else {
        [dm setObject:@"rebuildDatabase" forKey:@"database"];
    }
    
    
    
    
    // turn off WAL database mode
    NSMutableDictionary *pragmaOptions = [NSMutableDictionary dictionary];
    [pragmaOptions setObject:@"DELETE" forKey:@"journal_mode"];
    
    NSDictionary *storeoptions = [NSDictionary dictionaryWithObjectsAndKeys:
                             [NSNumber numberWithBool:YES],NSMigratePersistentStoresAutomaticallyOption,
                             [NSNumber numberWithBool:YES], NSInferMappingModelAutomaticallyOption, pragmaOptions, NSSQLitePragmasOption, nil];
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:storeoptions error:&error]) {
        
        //NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        //abort();
    }
    
    return _persistentStoreCoordinator;
}

- (NSString *)applicationDocumentsDirectory {
    return [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
}


@end
