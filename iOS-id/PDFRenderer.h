//
//  PDFRender.h
//  iOS-id
//
//  Created by H.M on 6/9/15.
//  Copyright (c) 2015 stephen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreText/CoreText.h>
#import "DataManagerObject.h"
#import "Projects.h"
#import "AppDelegate.h"
#import "ProjectGroup.h"
#import "Tasks.h"
#import "Notes.h"
#import "Photos.h"

@interface PDFRenderer : NSObject
+(void)drawPDF:(NSString*)fileName;

+(void)drawText;

+(void)drawLineFromPoint:(CGPoint)from toPoint:(CGPoint)to;

+(void)drawImage:(UIImage*)image inRect:(CGRect)rect;

+(void)drawText:(NSString*)textToDraw inFrame:(CGRect)frameRect;

+(void)drawLabels;

+(void)drawLogo;

+(void)generateHTML;

+(NSMutableArray*) myStaticArray;

+(void)drawTableAt:(CGPoint)origin
     withRowHeight:(int)rowHeight
    andColumnWidth:(int)columnWidth
       andRowCount:(int)numberOfRows
    andColumnCount:(int)numberOfColumns;


+(void)drawTableDataAt:(CGPoint)origin
         withRowHeight:(int)rowHeight
        andColumnWidth:(int)columnWidth
           andRowCount:(int)numberOfRows
        andColumnCount:(int)numberOfColumns;
@end
