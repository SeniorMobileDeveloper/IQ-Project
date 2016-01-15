//
//  NSObject+UpdateMonitor.h
//  iOS-id
//
//  Created by stephen on 3/4/14.
//  Copyright (c) 2014 stephen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NSObject+NetworkReach.h"

@interface UpdateMonitor : NSObject


// service
- (void)startUpdateMonitor;
- (void)stopUpdateMonitor;
- (void) onUpdateMonitorInterval;

- (void) stopWebService;
- (void) startWebService;

@end

@interface UpdateMonitor ()
    @property NetworkConnection* netconnect;
@end