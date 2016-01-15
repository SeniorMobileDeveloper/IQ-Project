//
//  projectInfoMapKit.h
//  iOS-id
//
//  Created by stephen on 10/7/13.
//  Copyright (c) 2013 stephen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

@interface projectInfoMapKit : NSObject

// map
@property (nonatomic,assign) CLLocationCoordinate2D coordinate;

-(id) initWithCoordinate:(CLLocationCoordinate2D)coordinate title:(NSString *)title;


@end
