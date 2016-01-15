//
//  DataManagerObject.m
//  iOS-id
//
//  Created by stephen on 10/18/13.
//  Copyright (c) 2013 stephen. All rights reserved.
//

#import "DataManagerObject.h"

@implementation DataManagerObject

static DataManagerObject *sharedInstance;
static NSMutableDictionary* dictionary;

- (id)init {
    self = [super init];
    if (self) {
        dictionary = [[NSMutableDictionary alloc] initWithCapacity:0];
    }
    return self;
}


+ (DataManagerObject *) sharedInstance
{
    @synchronized(self)
    {
        if (sharedInstance == NULL)
        {
            sharedInstance = [[DataManagerObject alloc] init];
        }
    }
    
    return sharedInstance;
}


-(void) setObject:(id)anObject forKey:(id<NSCopying>)aKey
{
    [dictionary setObject:anObject forKey:aKey];
}

-(id) objectForKey:(id)aKey
{
    return [dictionary objectForKey:aKey];
}

-(void) removeAllObjects
{
    [dictionary removeAllObjects];
}

@end
