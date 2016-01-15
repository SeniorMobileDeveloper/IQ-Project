//
//  Tasks.h
//  iOS-id
//
//  Created by stephen on 3/24/14.
//  Copyright (c) 2014 stephen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Notes, ProjectGroup;

@interface Tasks : NSManagedObject

@property (nonatomic, retain) NSNumber * id;
@property (nonatomic, retain) NSNumber * task_active;
@property (nonatomic, retain) NSNumber * task_complete;  //0 for NO, 1 for YES, 2 for NA
@property (nonatomic, retain) NSString * task_desc;
@property (nonatomic, retain) NSString * task_name;
@property (nonatomic, retain) NSDate * timestamp;
@property (nonatomic, retain) NSNumber * sort;
@property (nonatomic, retain) ProjectGroup *group;
@property (nonatomic, retain) NSSet *notes;
@end

@interface Tasks (CoreDataGeneratedAccessors)

- (void)addNotesObject:(Notes *)value;
- (void)removeNotesObject:(Notes *)value;
- (void)addNotes:(NSSet *)values;
- (void)removeNotes:(NSSet *)values;

@end
