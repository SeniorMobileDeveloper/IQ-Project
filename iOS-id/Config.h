//
//  Config.h
//  iOS-id
//
//  Created by stephen on 3/24/14.
//  Copyright (c) 2014 stephen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Config : NSManagedObject

@property (nonatomic, retain) NSNumber * last_update_timestamp;

@end
