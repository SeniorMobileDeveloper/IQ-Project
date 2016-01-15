//
//  NSObject+UpdateMonitor.m
//  iOS-id
//
//  Created by stephen on 3/4/14.
//  Copyright (c) 2014 stephen. All rights reserved.
//

#import "NSObject+UpdateMonitor.h"


@implementation UpdateMonitor

@synthesize netconnect;

NSTimer *updateMonitorTimer;

//--INTERVAL METHODS--//

#pragma mark - Start and stop notifier

- (void)startUpdateMonitor
{
    updateMonitorTimer = [NSTimer scheduledTimerWithTimeInterval:5.0f target:self selector:@selector(onUpdateMonitorInterval) userInfo:nil repeats:NO];
}
- (void) onUpdateMonitorInterval
{
	if ([netconnect isServiceRunning]) {
        if([netconnect isInternetConnected])
            [self requestUpdateData];
        else {
            // the service was running but the internet connection has gone down.
            // Stop the service. The network reachability monitor will restart
            // the service once internet connection is re-established.
            [self stopWebService];
            
            // note, we don't call stopUpdateMonitor because at this point it
            // is not running.
        }
    }
}
- (void)stopUpdateMonitor
{
	[updateMonitorTimer invalidate];
    updateMonitorTimer = nil;
}
//--end interval methods--//

//--CONNECTION METHODS--//
// establish connection parameters and then call connection function
- (void) startWebService
{
    // initiate network object
    [netconnect setObject:[NSNumber numberWithInt:1] forKey:@"isServiceRunning"];
    
    
    [self requestUpdateData];
    
}
// The web service is stopped when internet connection cannot be established or goes down
- (void) stopWebService
{
    /*
    // clear network object
    [netconnect setObject:nil forKey:@"isServiceRunning"];
    
    _updateRequest = nil;
    
    if(conn_ureq) {
        [conn_ureq cancel];
        conn_ureq = nil;
        webserviceARRAY = nil;
    }
    */
}
@end
