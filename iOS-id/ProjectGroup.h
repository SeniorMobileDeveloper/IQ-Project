//
//  ProjectGroup.h
//  iOS-id
//
//  Created by stephen on 3/24/14.
//  Copyright (c) 2014 stephen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Projects, Tasks;

@interface ProjectGroup : NSManagedObject

@property (nonatomic, retain) NSNumber * id;
@property (nonatomic, retain) NSNumber * projectgroup_active;
@property (nonatomic, retain) NSString * projectgroup_name;
@property (nonatomic, retain) NSDate * timestamp;
@property (nonatomic, retain) NSNumber * sort;
@property (nonatomic, retain) Projects *project;
@property (nonatomic, retain) NSSet *tasks;
@end

@interface ProjectGroup (CoreDataGeneratedAccessors)

- (void)addTasksObject:(Tasks *)value;
- (void)removeTasksObject:(Tasks *)value;
- (void)addTasks:(NSSet *)values;
- (void)removeTasks:(NSSet *)values;

@end
