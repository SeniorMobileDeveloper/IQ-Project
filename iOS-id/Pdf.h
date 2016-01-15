//
//  Pdf.h
//  iOS-id
//
//  Created by stephen on 3/24/14.
//  Copyright (c) 2014 stephen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Pdf : NSManagedObject

@property (nonatomic, retain) NSNumber * id;
@property (nonatomic, retain) NSString * pdf_filename;
@property (nonatomic, retain) NSString * pdf_name;
@property (nonatomic, retain) NSNumber * pdf_type;
@property (nonatomic, retain) NSDate * timestamp;
@property (nonatomic, retain) NSNumber * sort;

@end
