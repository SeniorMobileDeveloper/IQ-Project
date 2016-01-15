//
//  projectInfoMapKit.m
//  iOS-id
//
//  Created by stephen on 10/7/13.
//  Copyright (c) 2013 stephen. All rights reserved.
//

#import "projectInfoMapKit.h"

@implementation projectInfoMapKit

-(id) initWithCoordinate:(CLLocationCoordinate2D)coordinate title:(NSString *)title {
    if ((self = [super init])) {
        self.coordinate =coordinate;
        //self.title = title; // does not yet exist
    }
    return self;
}

@end
