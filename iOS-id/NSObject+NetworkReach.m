//
//  NSObject+NetworkReach.m
//  iOS-id
//
//  Created by stephen on 2/19/14.
//  Copyright (c) 2014 stephen. All rights reserved.
//

#import "NSObject+NetworkReach.h"
#import "NSObject+CommonFunctions.h"

@implementation NSObject (NetworkReach)


NetworkConnection* netconnect;
NSDictionary *webserviceRawData;
NSMutableArray *webserviceARRAY;

NSTimer *updateMonitorTimer; //

NSURLConnection *conn_ureq;
NSArray *dataARRAY;
NSMutableData *dataJSON;

NSURLRequest *_updateRequest;

Reachability *hostReachability;
Reachability *internetReachability;
Reachability *wifiReachability;

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

//--NETWORK MONITOR METHODS--//
- (void) startNetworkService
{
    // network
    if(!netconnect)
        netconnect = [NetworkConnection sharedInstance];
    
    if (![netconnect isNetworkServiceRunning]) {
        // 1099 disabled for now
        ////[self doInitalizeNetworkService];
    }
    
}
// This is only called by views when they unload
- (void) stopNetworkService
{
    // stop monitors
    [self updateConnectionServices:nil];
    
    // end listener
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kReachabilityChangedNotification object:nil];
    [netconnect setObject:nil forKey:@"isNetworkServiceRunning"];
}
- (void) doInitalizeNetworkService
{
    //Observe the kNetworkReachabilityChangedNotification. When that notification is posted, the method reachabilityChanged will be called.
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reachabilityChanged:) name:kReachabilityChangedNotification object:nil];
    
    //Change the host name here to change the server you want to monitor.
    NSString *remoteHostName = @"www.bqueue.com";
    //NSString *remoteHostLabelFormatString = NSLocalizedString(@"Remote Host: %@", @"Remote host label format string");
    //self.remoteHostLabel.text = [NSString stringWithFormat:remoteHostLabelFormatString, remoteHostName];
    
    // monitor host name
	hostReachability = [Reachability reachabilityWithHostName:remoteHostName];
	[hostReachability startNotifier];
	[self updateAppWithReachability:hostReachability];
    
    // monitor internet
    internetReachability = [Reachability reachabilityForInternetConnection];
	[internetReachability startNotifier];
	[self updateAppWithReachability:internetReachability];
    
    // monitor wifi
    wifiReachability = [Reachability reachabilityForLocalWiFi];
	[wifiReachability startNotifier];
	[self updateAppWithReachability:wifiReachability];
    
    
    [netconnect setObject:[NSNumber numberWithInt:1] forKey:@"isNetworkServiceRunning"];
}

//Called by Reachability whenever status changes.
- (void) reachabilityChanged:(NSNotification *)note
{
	Reachability* curReach = [note object];
	NSParameterAssert([curReach isKindOfClass:[Reachability class]]);
	[self updateAppWithReachability:curReach];
}
- (void) updateAppWithReachability:(Reachability *)reachability
{
  
    if (reachability == hostReachability)
	{
        BOOL connectionRequired = [reachability connectionRequired];
        
        // NetworkStatus netStatus = [reachability currentReachabilityStatus];
        //self.summaryLabel.hidden = (netStatus != ReachableViaWWAN);
        NSString* baseLabelText = @"";
        
        if (connectionRequired)
        {
            baseLabelText = NSLocalizedString(@"Cellular data network is available.\nInternet traffic will be routed through it after a connection is established.", @"Reachability text if a connection is required");
        }
        else
        {
            baseLabelText = NSLocalizedString(@"Cellular data network is active.\nInternet traffic will be routed through it.", @"Reachability text if a connection is not required");
        }
        //self.summaryLabel.text = baseLabelText;
    }
    
    // We only monitor active internet connections. The wifi reachability is
    // not an indication that we are actually connected to the internet.
    if (reachability == internetReachability)
	{
        // we use string because of the way our network object is configured.
        // Checking nil rather than 0 is easier
        NSString *isStrConnected = nil;
        
		if ([reachability currentReachabilityStatus]==NotReachable) {
            // the call to updateConnectionServices below will handle the requirements
        } else {
            
            isStrConnected = @"1";
            if (![netconnect isServiceRunning]) {
                [self startWebService];
            }
        }
        
        // set global connection status
        [self updateConnectionServices:isStrConnected];
      
	}
    
	if (reachability == wifiReachability)
	{
		//
	}
    
    [self configureNetworkFields:reachability];
}
- (void) updateConnectionServices:(NSString *)connectionStatus
{
    [netconnect setObject:connectionStatus forKey:@"isInternetConnected"];
    
    // handle no-connection states
    if (![netconnect isInternetConnected]) {
        [self stopUpdateMonitor];
        [self stopWebService];
    }
}
//- (void)configureNetworkFields:(UITextField *)textField imageView:(UIImageView *)imageView reachability:(Reachability *)reachability
- (void)configureNetworkFields:(Reachability *)reachability
{
    NetworkStatus netStatus = [reachability currentReachabilityStatus];
    BOOL connectionRequired = [reachability connectionRequired];
    NSString* statusString = @"";
    
    switch (netStatus)
    {
        case NotReachable:        {
            statusString = NSLocalizedString(@"Access Not Available", @"Text field text for access is not available");
            //imageView.image = [UIImage imageNamed:@"stop-32.png"] ;
            /*
             Minor interface detail- connectionRequired may return YES even when the host is unreachable. We cover that up here...
             */
            connectionRequired = NO;
            break;
        }
            
        case ReachableViaWWAN:        {
            statusString = NSLocalizedString(@"Reachable WWAN", @"");
            //imageView.image = [UIImage imageNamed:@"WWAN5.png"];
            break;
        }
        case ReachableViaWiFi:        {
            statusString= NSLocalizedString(@"Reachable WiFi", @"");
            //imageView.image = [UIImage imageNamed:@"Airport.png"];
            break;
        }
    }
    
    if (connectionRequired)
    {
        NSString *connectionRequiredFormatString = NSLocalizedString(@"%@, Connection Required", @"Concatenation of status string with connection requirement");
        statusString= [NSString stringWithFormat:connectionRequiredFormatString, statusString];
    }
    //textField.text= statusString;
}
/*- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kReachabilityChangedNotification object:nil];
}*/

//--end network monitor methods--//

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
    // clear network object
    [netconnect setObject:nil forKey:@"isServiceRunning"];
    
    _updateRequest = nil;
    
    if(conn_ureq) {
        [conn_ureq cancel];
        conn_ureq = nil;
        webserviceARRAY = nil;
    }
}
// make the actual request to the remote database
- (void) requestUpdateData
{
    [self stopUpdateMonitor];

    // build request query before each call so that the token and time are updated.
    // We can make _updateRequest variable local
    NSURL *_url = [netconnect getURL:@"update_req"];
    _updateRequest = [NSURLRequest requestWithURL:_url];
    
    
    // ALT request
    /*
    NSError *err = nil;
    NSData *jsonData = [NSData dataWithContentsOfURL:_url];
    //webserviceRawData = [NSJSONSerialization JSONObjectWithData:jsonData options:kNilOptions error:NULL];
    webserviceRawData = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingMutableContainers error:&err];
    
    // set token if not established or if new one is being forced
    for(id key in webserviceRawData) {
        id s = [webserviceRawData valueForKey:key];
    }
    */
    
    // original request method
    
    conn_ureq = [netconnect objectForKey:@"_conn_ureq"];
    if(conn_ureq) {
        [conn_ureq cancel];
        conn_ureq = nil;
        webserviceARRAY = nil;
    }
    conn_ureq = [NSURLConnection connectionWithRequest:_updateRequest delegate:self];
    [netconnect setObject:conn_ureq forKey:@"_conn_ureq"];
}
- (void) connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    
    
    NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *) response;
    int errorCode = httpResponse.statusCode;
    NSString *fileMIMEType = [[httpResponse MIMEType] lowercaseString];
    
    if(errorCode)
        NSLog(@"response is %d, %@", errorCode, fileMIMEType);
    
     
    // USING ALT METHOD FOR JSON
    // prepare object
    dataJSON = [[NSMutableData alloc] init];
    
}
- (void) connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    //NSLog(@"data is %@",data);
    
    //NSString *_string = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    
    //NSLog(@"%@",_string);
    
    // ORIGINAL JSON METHOD
    // Fails for nested strings
    /*
    NSError *err = nil;
     
    // capture raw data into dictionary
    webserviceRawData = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&err];
    
    
    // Timestamp is set after every call. This is the time on the server when the last request was made.
    // This call also updates the local database value
    [netconnect setTimeStampFromObject:webserviceRawData];
    
    // set token if not established or if new one is being forced
    if ([webserviceRawData valueForKey:@"newtoken"]) {
        [netconnect setConnectToken:[webserviceRawData valueForKey:@"newtoken"]];
    }
    */
    
    // USING ALT METHOD FOR JSON
    
    [dataJSON appendData:data];
}
- (void) connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    
    // clear update request connection
    [netconnect setObject:nil forKey:@"_conn_ureq"];
    
    //NSLog(@"Connection failed! Error - %@ %@", [error localizedDescription], [[error userInfo] objectForKey:NSURLErrorFailingURLStringErrorKey]);
    
    // restart interval
    [self startUpdateMonitor];
}
- (void) connectionDidFinishLoading:(NSURLConnection *)connection {
    
    // ALT METHOD FOR JSON
    // Previous method used in didReceiveData only succeeded for simple json strings. Nested
    // strings failed to convert. The alt method configured through didReceiveResponse, didReceiveData,
    // and here provides a proper parsing result
    webserviceRawData = [NSJSONSerialization JSONObjectWithData:dataJSON options:0 error:nil];
    
    //NSLog(@"Succeeded!");
    
    // Timestamp is set after every call. This is the time on the server when the last request was made.
    // This call also updates the local database value
    [netconnect setTimeStampFromObject:webserviceRawData];
    
    // set token if not established or if new one is being forced
    if ([webserviceRawData valueForKey:@"newtoken"]) {
        [netconnect setConnectToken:[webserviceRawData valueForKey:@"newtoken"]];
    }
    
    // Example retrieving information
    //NSString *s = [_webserviceRawData valueForKey:@"message"];
    
    
    
    
    // convert response data stored in our dictionary into our service array.
    // We only need to do this if we need values without keys. This is unlikely.
    /*
     _webserviceARRAY = [[NSMutableArray alloc] init];
     
     for(NSString *key in _webserviceRawData) {
     id object = _webserviceRawData[key];
     
     if([object isKindOfClass:[NSDictionary class]]) {
     // the entry is an array
     [_webserviceARRAY addObject:[object valueForKey:@"_content"]];
     
     } else {
     // the entry is a string
     [_webserviceARRAY addObject:_webserviceRawData[key]];
     }
     }
     */
    
    
    
    // clear update request connection
    [netconnect setObject:nil forKey:@"_conn_ureq"];
  
    // process data
    if ([self isDictionaryNotNull:[webserviceRawData valueForKey:@"data"]]) {
        [self processAndSyncData:[webserviceRawData valueForKey:@"data"]];
    } else {
        // restart interval
        [self startUpdateMonitor];
    }
  
}
//-- end connection methods--//

//-- PARSE METHODS --//
- (void) processAndSyncData:(NSDictionary *)a_ns {
    
    // Assume any data from the remote database needs to be applied.
    
    /*
    for(id key in a_ns) {
        NSDictionary *s = [a_ns valueForKey:key];
    }
    */
    
    // enumerate
    for(id keyInspection in a_ns) {
        // save photo to storage if not exist
        
        
            NSDictionary *inspectionobj = [a_ns valueForKey:keyInspection];
            
            // top level is Projects (inspection) table
            
            // process inspections
            Projects* inspectionRef = [netconnect updateOrInsertInspection:inspectionobj];
            
            // enumerate ProjectGroups (projects) table if exist
            NSArray *a_ns_projects = [inspectionobj valueForKey:@"projects"];
            if(a_ns_projects) {
                
                for (NSInteger j=0; j < [a_ns_projects count]; j++) {
                    
                    NSDictionary *projectobj = [a_ns_projects objectAtIndex:j];
                    
                    // process projects
                    ProjectGroup* projectRef = [netconnect updateOrInsertProject:projectobj inspectionReference:inspectionRef];
                    
                    // enumerate Tasks (task) table if exist
                    NSArray *a_ns_tasks = [projectobj valueForKey:@"tasks"];
                    if(a_ns_tasks) {
                        for (NSInteger m=0; m < [a_ns_tasks count]; m++) {
                            
                            NSDictionary *taskobj = [a_ns_tasks objectAtIndex:m];
                            
                            // process tasks
                            Tasks* taskRef = [netconnect updateOrInsertTask:taskobj projectReference:projectRef];
                            
                            // enumerate Notes table if exist
                            NSArray *a_ns_notes = [taskobj valueForKey:@"notes"];
                            if(a_ns_notes) {
                                for (NSInteger n=0; n < [a_ns_notes count]; n++) {
                                    
                                    NSDictionary *tasknoteobj = [a_ns_notes objectAtIndex:n];
                                    
                                    // process note
                                    Notes* taskNoteRef = [netconnect updateOrInsertTaskNote:tasknoteobj taskReference:taskRef];
                                                          
                                }
                            } // end tasks
                        }
                    } // end tasks
                }
            } // end projects
        
            // enumerate Inspection Notes (notes) table if exist
            NSArray *a_ns_inspection_notes = [inspectionobj valueForKey:@"notes"];
            if(a_ns_inspection_notes) {
                
                for (NSInteger jj=0; jj < [a_ns_inspection_notes count]; jj++) {
                    
                    NSDictionary *inspectionnoteobj = [a_ns_inspection_notes objectAtIndex:jj];
                    
                    // process note
                    Notes* inspectionNoteRef = [netconnect updateOrInsertInspectionNote:inspectionnoteobj inspectionReference:inspectionRef];
                    
                }
            }
        
    } // end inspections
    
    // restart interval
    [self startUpdateMonitor];
    
}



// -- end parse methods --//


@end
