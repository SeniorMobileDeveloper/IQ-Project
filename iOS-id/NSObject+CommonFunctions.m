//
//  NSObject+CommonFunctions.m
//  iOS-id
//
//  Created by stephen on 2/25/14.
//  Copyright (c) 2014 stephen. All rights reserved.
//

#import "NSObject+CommonFunctions.h"
#import "DataManagerObject.h"

@implementation NSObject (CommonFunctions)

- (void)beforeLogOut
{
    // cancel monitors for all views
    //DataManagerObject* dm;
    //[dm setObject:@"YES" forKey:@"isMonitorCancel"];
}

-(NSNumber *)convertStringToNumber:(NSString *)str
{
    // be sure we are working with a string. Even though str should be
    // a string, our timestamp for instance comes in as LONG. We force
    // to string to prevent the conversion from creating an error.
    NSString *s = [NSString stringWithFormat:@"%@",str];
    
    NSNumberFormatter *f = [[NSNumberFormatter alloc] init];
    [f setNumberStyle:NSNumberFormatterDecimalStyle];
    NSNumber *numtime = [f numberFromString:s];
    
    return (numtime)?numtime :0;
}
-(NSDate *)convertStrintToDate:(NSString *)str
{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    
    return [formatter dateFromString:str];
}
- (NSString *)stringVal:(NSString *)str
{
    // test both nil and NSNull type
    if(!str || [str isKindOfClass:[NSNull class]]) {
        return @"";
    }
    
    return str;
}
- (BOOL)isDictionaryNotNull:(NSDictionary *)dictionary
{
    // test both nil and NSNull type
    if(!dictionary || [dictionary isKindOfClass:[NSNull class]]) {
        return false;
    }
    return true;
}

@end
