//
//  NSObject+CommonFunctions.h
//  iOS-id
//
//  Created by stephen on 2/25/14.
//  Copyright (c) 2014 stephen. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSObject (CommonFunctions)

- (void)beforeLogOut;
-(NSNumber *)convertStringToNumber:(NSString *)str;
-(NSDate *)convertStrintToDate:(NSString *)str;
- (NSString *)stringVal:(NSString *)str;
- (BOOL)isDictionaryNotNull:(NSDictionary *)dictionary;

@end
