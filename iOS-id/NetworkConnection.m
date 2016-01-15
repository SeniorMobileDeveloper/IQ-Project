//
//  NetworkConnection.m
//  iOS-id
//
//  Created by stephen on 2/19/14.
//  Copyright (c) 2014 stephen. All rights reserved.
//

#import "NetworkConnection.h"
#import "AppDelegate.h"
#import "NSObject+CommonFunctions.h"
#import "DataManagerObject.h"

@implementation NetworkConnection

static NetworkConnection *sharedInstance;
static NSMutableDictionary* dictionary;

AppDelegate *appDelegate;
DataManagerObject* dm;

NSString *connectToken = nil;

- (id)init {
    self = [super init];
    if (self) {
        dictionary = [[NSMutableDictionary alloc] initWithCapacity:0];
    }
    
    // reference for database calls
    appDelegate = [UIApplication sharedApplication].delegate;
    
    // initialize communcication object
    dm = [DataManagerObject sharedInstance];
    
    return self;
}


+ (NetworkConnection *) sharedInstance
{
    @synchronized(self)
    {
        if (sharedInstance == NULL)
        {
            sharedInstance = [[NetworkConnection alloc] init];
        }
    }
    
    return sharedInstance;
}

-(BOOL) isServiceRunning
{
    if ([dictionary objectForKey:@"isServiceRunning"]) {
        return TRUE;
    }
    return FALSE;
}
-(BOOL) isNetworkServiceRunning
{
    if ([dictionary objectForKey:@"isNetworkServiceRunning"]) {
        return TRUE;
    }
    return FALSE;
}
-(BOOL) isInternetConnected
{
    if ([dictionary objectForKey:@"isInternetConnected"]) {
        return TRUE;
    }
    return FALSE;
}
-(void) setConnectToken:(NSString *)token
{
    connectToken = token;
}
-(NSURL *) getURL:(NSString *)typeByString
{
  
    if ([typeByString isEqual:@"update_req"]) {
        // join parameters
        NSString *ct = (connectToken)?connectToken :@"";
        NSString *ts = [self getTimeStamp];
   
        NSString *url = [NSString stringWithFormat:@"http://www.bqueue.com/dev/services/rest/service.php?method=poll&token=%@&ts=%@",ct,((ts)?ts:@"")];
        
        return [NSURL URLWithString:url];
    }
    
    return nil;
}
-(void) setTimeStampFromObject:(NSDictionary*)data
{
    
    // we were only setting the timestamp once per session, but it is now set
    // after every successful call to the remote database
    if ([data valueForKey:@"timestamp"]) { // && ![dictionary objectForKey:@"timestamp"]
        // convert for storage (not necessary)
        // int value = [[data valueForKey:@"timestamp"] intValue];
        
        // save to session variable and configuration table
        [appDelegate setLastTimeStamp:[data valueForKey:@"timestamp"]];
        
        // set local object
        //[dictionary setObject:[data valueForKey:@"timestamp"] forKey:@"timestamp"];
    }
}
-(NSString *) getTimeStamp
{
    return [appDelegate getLastTimeStamp];
    //return [dictionary objectForKey:@"timestamp"];
}

-(void) setObject:(id)anObject forKey:(id<NSCopying>)aKey
{
    if(anObject) {
        // we do not handle timestamps here
        if ( [[NSString stringWithFormat:@"%@",aKey] isEqual:@"timestamp"] ) {
            // do nothing
        } else
            [dictionary setObject:anObject forKey:aKey];
    }
    else {
        if ([dictionary objectForKey:aKey]) {
            [dictionary removeObjectForKey:aKey];
        }
    }
}

//--UPDATE METHODS--//

- (Projects *) updateOrInsertInspection:(NSDictionary *)data {
    
    // do we have a matching item? Remember, the sync param(s)
    // might not yet be established
    Projects *inspection = [appDelegate getInspection:data];
    
    // save to database
    
    NSManagedObjectContext *managedObjectContent = [appDelegate getContextInstance];
    
    // convert time to date
    NSDate *newdate = [self convertStrintToDate:[data valueForKey:@"update_time"]];
    
    if (inspection) {
        //NSNumber *num = [data valueForKey:@"isInspectionUpdated"];
        
        // the remote database also sets a param that explicitly states whether
        // this item needs to be updated or it simply needs reference for children
        if (![data valueForKey:@"isInspectionUpdated"] || [[data valueForKey:@"isInspectionUpdated"] intValue]==0) {
            return inspection;
        }
        
        // check for delete requests
        if ([self isDictionaryNotNull:[data valueForKey:@"delete"]]) {
            // delete object from database
            [[inspection managedObjectContext] deleteObject:inspection];
            inspection = NULL;
            // set flag
            [dm setObject:@"YES" forKey:@"isInspectionToBeDeleted"];
        } else {
       
            // update
            [inspection setValue:[self stringVal:[data valueForKey:@"name"]] forKey:@"project_name"];
            [inspection setValue:[self convertStringToNumber:[data valueForKey:@"sort"]] forKey:@"sort"];
            [inspection setValue:newdate forKey:@"timestamp"];
        }
        
    } else {
        // insert
        
        // we check for phantom deletions. This occurs if the remote and local databases are out of sync. If
        // a delete request is in the post, then item should not be created.
        if ([self isDictionaryNotNull:[data valueForKey:@"delete"]]) {
            return NULL;
        }
        
        inspection = [NSEntityDescription insertNewObjectForEntityForName:@"Projects" inManagedObjectContext:managedObjectContent];
        
        inspection.id = [self convertStringToNumber:[data valueForKey:@"db_id"]];
        inspection.project_name = [self stringVal:[data valueForKey:@"name"]];
        // cast strtime as date for Core data
        inspection.timestamp = newdate;
    }

     // error trap
     NSError *error = nil;
     if (![managedObjectContent save:&error]) {
     //NSLog(@"Error, could not save %@ to local device",[error localizedDescription]);
     }
    
    // Since we did not return early, we either updated or added new
    [dm setObject:@"YES" forKey:@"isInspectionUpdated"];
    
    return inspection;
}
- (ProjectGroup *) updateOrInsertProject:(NSDictionary *)data inspectionReference:(Projects*)reference; {
    
    // do we have a matching item? Remember, the sync param(s)
    // might not yet be established
    ProjectGroup *group = [appDelegate getProjectGroup:data];
    
    // save to database
    
    NSManagedObjectContext *managedObjectContent = [appDelegate getContextInstance];
    
    // convert time to date
    NSDate *newdate = [self convertStrintToDate:[data valueForKey:@"update_time"]];
    
    if (group) {
        // the remote database also sets a param that explicitly states whether
        // this item needs to be updated or it simply needs reference for children
        if (![data valueForKey:@"isProjectUpdated"] || [[data valueForKey:@"isProjectUpdated"] intValue]==0) {
            return group;
        }
        
        // check for delete requests
        if ([self isDictionaryNotNull:[data valueForKey:@"delete"]]) {
            // delete object from database
            [[group managedObjectContext] deleteObject:group];
            // null the group since it should not be referenced
            group = NULL;
            // set flag
            [dm setObject:@"YES" forKey:@"isProjectToBeDeleted"];
        } else {
            // update
            [group setValue:[self stringVal:[data valueForKey:@"name"]] forKey:@"projectgroup_name"];
            [group setValue:[self convertStringToNumber:[data valueForKey:@"sort"]] forKey:@"sort"];
            [group setValue:newdate forKey:@"timestamp"];
        }
    } else {
        // insert
        // We can have phantom items if the reference does not exist. In this case, we do not want to allow insert.
        // This will prevent errors and allow the item to remain in queue until the appropriate reference is located
        if (reference==NULL) {
            return NULL;
        }
        // we also check for phantom deletions. This occurs if the remote and local databases are out of sync. If
        // a delete request is in the post, then item should not be created.
        if ([self isDictionaryNotNull:[data valueForKey:@"delete"]]) {
            return NULL;
        }
        
        group = [NSEntityDescription insertNewObjectForEntityForName:@"ProjectGroup" inManagedObjectContext:managedObjectContent];
        
        group.id = [self convertStringToNumber:[data valueForKey:@"db_id"]];
        
        group.projectgroup_name = [self stringVal:[data valueForKey:@"name"]];
        // cast strtime as date for Core data
        group.timestamp = newdate;
        group.sort = [self convertStringToNumber:[data valueForKey:@"sort"]];
        group.project = reference;
    }
    
    // error trap
    NSError *error = nil;
    if (![managedObjectContent save:&error]) {
        //NSLog(@"Error, could not save %@ to local device",[error localizedDescription]);
    }
    
    // Since we did not return early, we either updated or added new
    [dm setObject:@"YES" forKey:@"isProjectUpdated"];
    
    return group;
}
- (Tasks *) updateOrInsertTask:(NSDictionary *)data projectReference:(ProjectGroup*)reference {
    
    // do we have a matching item? Remember, the sync param(s)
    // might not yet be established
    Tasks *task = [appDelegate getTask:data];
    
    // save to database
    
    NSManagedObjectContext *managedObjectContent = [appDelegate getContextInstance];
    
    // convert time to date
    NSDate *newdate = [self convertStrintToDate:[data valueForKey:@"update_time"]];
    
    if (task) {
        // the remote database also sets a param that explicitly states whether
        // this item needs to be updated or it simply needs reference for children
        if (![data valueForKey:@"isTaskUpdated"] || [[data valueForKey:@"isTaskUpdated"] intValue]==0) {
            return task;
        }
        
        // check for delete requests
        if ([self isDictionaryNotNull:[data valueForKey:@"delete"]]) {
            // delete object from database
            [[task managedObjectContext] deleteObject:task];
            task = NULL;
            // set flag
            [dm setObject:@"YES" forKey:@"isTaskToBeDeleted"];
        } else {
            // update
            [task setValue:[self stringVal:[data valueForKey:@"name"]] forKey:@"task_name"];
            [task setValue:[self stringVal:[data valueForKey:@"desc"]] forKey:@"task_desc"];
            [task setValue:[self convertStringToNumber:[data valueForKey:@"sort"]] forKey:@"sort"];
            [task setValue:newdate forKey:@"timestamp"];
        }
    } else {
        // insert
        // We can have phantom items if the reference does not exist. In this case, we do not want to allow insert.
        // This will prevent errors and allow the item to remain in queue until the appropriate reference is located
        if (reference==NULL) {
            return NULL;
        }
        // we also check for phantom deletions. This occurs if the remote and local databases are out of sync. If
        // a delete request is in the post, then item should not be created.
        if ([self isDictionaryNotNull:[data valueForKey:@"delete"]]) {
            return NULL;
        }
        
        task = [NSEntityDescription insertNewObjectForEntityForName:@"Tasks" inManagedObjectContext:managedObjectContent];
        
        task.id = [self convertStringToNumber:[data valueForKey:@"db_id"]];
        
        task.task_name = [self stringVal:[data valueForKey:@"name"]];
        task.task_desc = [self stringVal:[data valueForKey:@"desc"]];
        task.sort = [self convertStringToNumber:[data valueForKey:@"sort"]];
        // cast strtime as date for Core data
        task.timestamp = newdate;
        task.group = reference;
    }
    
    // error trap
    NSError *error = nil;
    if (![managedObjectContent save:&error]) {
        //NSLog(@"Error, could not save %@ to local device",[error localizedDescription]);
    }
    
    // Since we did not return early, we either updated or added new
    [dm setObject:@"YES" forKey:@"isTaskUpdated"];
    
    return task;
}
- (Notes *) updateOrInsertTaskNote:(NSDictionary *)data taskReference:(Tasks*)reference {
    
    // do we have a matching item? Remember, the sync param(s)
    // might not yet be established
    Notes *note = [appDelegate getNote:data];
    
    // save to database
    
    NSManagedObjectContext *managedObjectContent = [appDelegate getContextInstance];
    
    // convert time to date
    NSDate *newdate = [self convertStrintToDate:[data valueForKey:@"update_time"]];
    
    if (note) {
        // the remote database also sets a param that explicitly states whether
        // this item needs to be updated or it simply needs reference for children
        if (![data valueForKey:@"isTaskNoteUpdated"] || [[data valueForKey:@"isTaskNoteUpdated"] intValue]==0) {
            return note;
        }
        
        // check for delete requests
        if ([self isDictionaryNotNull:[data valueForKey:@"delete"]]) {
            // delete object from database
            [[note managedObjectContext] deleteObject:note];
            note = NULL;
            // set flag
            [dm setObject:@"YES" forKey:@"isTaskNoteToBeDeleted"];
        } else {
            // update
            [note setValue:[self stringVal:[data valueForKey:@"message"]] forKey:@"message"];
            [note setValue:[self convertStringToNumber:[data valueForKey:@"sort"]] forKey:@"sort"];
            [note setValue:newdate forKey:@"timestamp"];
        }
    } else {
        // insert
        // We can have phantom items if the reference does not exist. In this case, we do not want to allow insert.
        // This will prevent errors and allow the item to remain in queue until the appropriate reference is located
        if (reference==NULL) {
            return NULL;
        }
        // we also check for phantom deletions. This occurs if the remote and local databases are out of sync. If
        // a delete request is in the post, then item should not be created.
        if ([self isDictionaryNotNull:[data valueForKey:@"delete"]]) {
            return NULL;
        }
        
        note = [NSEntityDescription insertNewObjectForEntityForName:@"Notes" inManagedObjectContext:managedObjectContent];
        
        note.message = [self stringVal:[data valueForKey:@"message"]];
        
        note.id = [self convertStringToNumber:[data valueForKey:@"db_id"]];
        
        // cast strtime as date for Core data
        note.timestamp = newdate;
        note.sort = [self convertStringToNumber:[data valueForKey:@"sort"]];
        note.task = reference;
    }
    
    // error trap
    NSError *error = nil;
    if (![managedObjectContent save:&error]) {
        //NSLog(@"Error, could not save %@ to local device",[error localizedDescription]);
    }
    
    // Since we did not return early, we either updated or added new
    [dm setObject:@"YES" forKey:@"isTaskNoteUpdated"];
    
    return note;
}
- (Notes *) updateOrInsertInspectionNote:(NSDictionary *)data inspectionReference:(Projects*)reference {
    
    // do we have a matching item? Remember, the sync param(s)
    // might not yet be established
    Notes *note = [appDelegate getNote:data];
    
    // save to database
    
    NSManagedObjectContext *managedObjectContent = [appDelegate getContextInstance];
    
    // convert time to date
    NSDate *newdate = [self convertStrintToDate:[data valueForKey:@"update_time"]];
    
    if (note) {
        // the remote database also sets a param that explicitly states whether
        // this item needs to be updated or it simply needs reference for children
        if (![data valueForKey:@"isInspectionNoteUpdated"] || [[data valueForKey:@"isInspectionNoteUpdated"] intValue]==0) {
            return note;
        }
        
        // check for delete requests
        if ([self isDictionaryNotNull:[data valueForKey:@"delete"]]) {
            // delete object from database
            [[note managedObjectContext] deleteObject:note];
            note = NULL;
            // set flag
            [dm setObject:@"YES" forKey:@"isInspectionNoteToBeDeleted"];
        } else {
            // update
            [note setValue:[self stringVal:[data valueForKey:@"message"]] forKey:@"message"];
            [note setValue:[self convertStringToNumber:[data valueForKey:@"sort"]] forKey:@"sort"];
            [note setValue:newdate forKey:@"timestamp"];
        }
    } else {
        // insert
        // We can have phantom items if the reference does not exist. In this case, we do not want to allow insert.
        // This will prevent errors and allow the item to remain in queue until the appropriate reference is located
        if (reference==NULL) {
            return NULL;
        }
        // we also check for phantom deletions. This occurs if the remote and local databases are out of sync. If
        // a delete request is in the post, then item should not be created.
        if ([self isDictionaryNotNull:[data valueForKey:@"delete"]]) {
            return NULL;
        }
        
        note = [NSEntityDescription insertNewObjectForEntityForName:@"Notes" inManagedObjectContext:managedObjectContent];
        
        note.message = [self stringVal:[data valueForKey:@"message"]];
        
        note.id = [self convertStringToNumber:[data valueForKey:@"db_id"]];
        
        // cast strtime as date for Core data
        note.timestamp = newdate;
        note.sort = [self convertStringToNumber:[data valueForKey:@"sort"]];
        note.project = reference;
    }
    
    // error trap
    NSError *error = nil;
    if (![managedObjectContent save:&error]) {
        //NSLog(@"Error, could not save %@ to local device",[error localizedDescription]);
    }
    
    // Since we did not return early, we either updated or added new
    [dm setObject:@"YES" forKey:@"isInspectionNoteUpdated"];
    
    return note;
}
//--end parse methods--//

-(id) objectForKey:(id)aKey
{
    return [dictionary objectForKey:aKey];
}

-(void) removeAllObjects
{
    [dictionary removeAllObjects];
}

@end
