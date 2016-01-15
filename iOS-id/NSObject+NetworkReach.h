//
//  NSObject+NetworkReach.h
//  iOS-id
//
//  Created by stephen on 2/19/14.
//  Copyright (c) 2014 stephen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NetworkConnection.h"

#import "Reachability.h"


@interface NSObject (NetworkReach)




//--web service

- (void)startUpdateMonitor; //
- (void)stopUpdateMonitor; //
- (void) onUpdateMonitorInterval; //
- (void) requestUpdateData;
- (void) startNetworkService;
- (void) stopNetworkService;
- (void) stopWebService; //
- (void) updateConnectionServices:(NSString *)connectionStatus;
- (void) doInitalizeNetworkService;
- (void) reachabilityChanged:(NSNotification *)note;
- (void) updateAppWithReachability:(Reachability *)reachability;
- (void)configureNetworkFields:(Reachability *)reachability;
- (void) startWebService; //

- (void) processAndSyncData:(NSDictionary *)a_ns;

- (void) connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response;
- (void) connection:(NSURLConnection *)connection didReceiveData:(NSData *)data;
- (void) connection:(NSURLConnection *)connection didFailWithError:(NSError *)error;
- (void) connectionDidFinishLoading:(NSURLConnection *)connection;

@end
