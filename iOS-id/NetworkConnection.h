//
//  NetworkConnection.h
//  iOS-id
//
//  Created by stephen on 2/19/14.
//  Copyright (c) 2014 stephen. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "Config.h"

#import "Projects.h"
#import "ProjectGroup.h"
#import "Tasks.h"


@interface NetworkConnection : NSObject

+(NetworkConnection*)sharedInstance;
-(void) setConnectToken:(NSString *)token;
-(BOOL) isServiceRunning;
-(BOOL) isNetworkServiceRunning;
-(BOOL) isInternetConnected;
-(NSURL *) getURL:(NSString *)typeByString;
-(void) setTimeStampFromObject:(NSDictionary*)data;
-(NSString *) getTimeStamp;

- (Projects *) updateOrInsertInspection:(NSDictionary *)data;
- (ProjectGroup *) updateOrInsertProject:(NSDictionary *)data inspectionReference:(Projects*)reference;
- (Tasks *) updateOrInsertTask:(NSDictionary *)data projectReference:(ProjectGroup*)reference;
- (Notes *) updateOrInsertTaskNote:(NSDictionary *)data taskReference:(Tasks*)reference;
- (Notes *) updateOrInsertInspectionNote:(NSDictionary *)data inspectionReference:(Projects*)reference;

-(void) setObject:(id)anObject forKey:(id<NSCopying>)aKey;
-(id) objectForKey:(id)aKey;
-(void) removeAllObjects;

@end
