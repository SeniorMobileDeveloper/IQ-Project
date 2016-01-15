//
//  DataManagerObject.h
//  iOS-id
//
//  Created by stephen on 10/18/13.
//  Copyright (c) 2013 stephen. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DataManagerObject : NSObject

+(DataManagerObject*)sharedInstance;
-(void) setObject:(id)anObject forKey:(id<NSCopying>)aKey;
-(id) objectForKey:(id)aKey;
-(void) removeAllObjects;

@end
