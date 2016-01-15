//
//  Projects.h
//  iOS-id
//
//  Created by stephen on 3/24/14.
//  Copyright (c) 2014 stephen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Company, Notes, ProjectGroup;

@interface Projects : NSManagedObject

@property (nonatomic, retain) NSNumber * id;
@property (nonatomic, retain) NSNumber * project_active;
@property (nonatomic, retain) NSString * project_name;
@property (nonatomic, retain) NSDate * timestamp;
@property (nonatomic, retain) NSNumber * sort;
@property (nonatomic, retain) Company *company;
@property (nonatomic, retain) NSSet *group;
@property (nonatomic, retain) NSSet *notes;
@end

@interface Projects (CoreDataGeneratedAccessors)

- (void)addGroupObject:(ProjectGroup *)value;
- (void)removeGroupObject:(ProjectGroup *)value;
- (void)addGroup:(NSSet *)values;
- (void)removeGroup:(NSSet *)values;

- (void)addNotesObject:(Notes *)value;
- (void)removeNotesObject:(Notes *)value;
- (void)addNotes:(NSSet *)values;
- (void)removeNotes:(NSSet *)values;

@end
