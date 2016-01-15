//
//  Photos.h
//  iOS-id
//
//  Created by stephen on 3/24/14.
//  Copyright (c) 2014 stephen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Notes;

@interface Photos : NSManagedObject

@property (nonatomic, retain) NSNumber * id;
@property (nonatomic, retain) NSDate * photo_date_created;
@property (nonatomic, retain) NSData * photo_image;
@property (nonatomic, retain) NSString * photo_name;
@property (nonatomic, retain) NSString * photo_path;
@property (nonatomic, retain) NSDate * timestamp;
@property (nonatomic, retain) NSNumber * sort;
@property (nonatomic, retain) Notes *note;

@end
