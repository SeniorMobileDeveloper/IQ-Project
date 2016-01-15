//
//  PDFRender.m
//  iOS-id
//
//  Created by H.M on 6/9/15.
//  Copyright (c) 2015 stephen. All rights reserved.
//

#import "PDFRenderer.h"

@implementation PDFRenderer

static NSMutableArray *groupsArray = nil;

+(void)drawPDF:(NSString*)fileName
{
    // Create the PDF context using the default page size of 612 x 792.
    UIGraphicsBeginPDFContextToFile(fileName, CGRectZero, nil);
    // Mark the beginning of a new page.
    UIGraphicsBeginPDFPageWithInfo(CGRectMake(0, 0, 612, 792), nil);
    
    [self drawText:@"Hello World" inFrame:CGRectMake(0, 0, 300, 50)];
    
    [self drawLabels];
    //[self drawLogo];
    
    int xOrigin = 50;
    int yOrigin = 300;
    
    int rowHeight = 50;
    int columnWidth = 120;
    
    int numberOfRows = 7;
    int numberOfColumns = 4;
    
    [self drawTableAt:CGPointMake(xOrigin, yOrigin) withRowHeight:rowHeight andColumnWidth:columnWidth andRowCount:numberOfRows andColumnCount:numberOfColumns];
    
    [self drawTableDataAt:CGPointMake(xOrigin, yOrigin) withRowHeight:rowHeight andColumnWidth:columnWidth andRowCount:numberOfRows andColumnCount:numberOfColumns];
    
    // Close the PDF context and write the contents out.
    UIGraphicsEndPDFContext();
    
    /*NSString *myHTML = @"<html><body><h1>Hello, world!</h1></body></html>";
    [myUIWebView loadHTMLString:myHTML baseURL:nil];*/
}

+(void)loadProjectData
{
    AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    DataManagerObject *dm = [DataManagerObject sharedInstance];
    Projects *selectedProject = (Projects*)[dm objectForKey:@"selectedProject"];
    groupsArray = [appDelegate getGroupsByProject:selectedProject];
}

+(void)generateHTML
{
    [self loadProjectData];
    NSDate *today = [NSDate date];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"MMMM dd, yyyy"];
    NSString *str_today = [dateFormatter stringFromDate:today];
    
    NSMutableString *myHTML = [NSMutableString stringWithString:@"<html><body><div style='width:800px; margin:0 auto;'><div style='height:50px;'>&nbsp;</div>"];
    NSString *title = @"<h1 style='text-align:center'>FlyRight Inc.</h1>";
    [myHTML appendString:title];
    NSString *subTitle = [NSString stringWithFormat:@"<h3 style='text-align:center'>Inspection Report — %@</h3>", str_today];
    [myHTML appendString:subTitle];
    [myHTML appendString:@"<div style='height:10px;'>&nbsp;</div>"];
    
    NSString *table = [self profileTable];
    [myHTML appendString:table];
//    [myHTML appendString:@"<table border=0 cellspacing=0 style='margin:0 auto; width:90%;'>"];
    for(int i=0; i<[groupsArray count]; i++)
    {
        
        NSString *groupTable = [self groupTable:i];
        [myHTML appendString:groupTable];
        [myHTML appendString:@"<div style='height:40px;'>&nbsp;</div>"];
    }
    
    [myHTML appendString:@"</div></body></html>"];
    
    DataManagerObject *dm = [DataManagerObject sharedInstance];
    [dm setObject:myHTML forKey:@"pdfHTML"];
}

+(NSString*) profileTable
{
    NSMutableArray *strArray = [[NSMutableArray alloc] init];
    [strArray addObject:@"<table border=1 cellspacing=0 style='margin:0 auto; width:90%;'>"];
    [strArray addObject:@"  <tr>"];
    [strArray addObject:@"      <td style='width:20%; text-align:right;'>Client Name:</td>"];
    [strArray addObject:@"      <td colspan='2'>&nbsp;</td>"];
    [strArray addObject:@"      <td colspan='2'>Client Phone #:</td>"];
    [strArray addObject:@"  </tr>"];
    [strArray addObject:@"  <tr>"];
    [strArray addObject:@"      <td style='text-align:right;'>Aircraft Type:</td>"];
    [strArray addObject:@"      <td colspan='4'>&nbsp;</td>"];
    [strArray addObject:@"  </tr>"];
    [strArray addObject:@"  <tr>"];
    [strArray addObject:@"      <td style='text-align:right;'>Registration:</td>"];
    [strArray addObject:@"      <td colspan='2'>&nbsp;</td>"];
    [strArray addObject:@"      <td colspan='2'>To:</td>"];
    [strArray addObject:@"  </tr>"];
    [strArray addObject:@"  <tr>"];
    [strArray addObject:@"      <td style='text-align:right;'>Serial #:</td>"];
    [strArray addObject:@"      <td colspan='4'>&nbsp;</td>"];
    [strArray addObject:@"  </tr>"];
    [strArray addObject:@"<tr>"];
    [strArray addObject:@"<td style='text-align:right;'>Line Number:</td>"];
    [strArray addObject:@"<td colspan='4'>&nbsp;</td>"];
    [strArray addObject:@"</tr>"];
    [strArray addObject:@"<tr>"];
    [strArray addObject:@"<td style='text-align:right;'>Aircaft TT:</td>"];
    [strArray addObject:@"<td colspan='2'>&nbsp;</td>"];
    [strArray addObject:@"<td colspan='2'>TC:</td>"];
    [strArray addObject:@"</tr>"];
    [strArray addObject:@"<tr>"];
    [strArray addObject:@"<td style='text-align:right;'>Last HMV:</td>"];
    [strArray addObject:@"<td colspan='2'>&nbsp;</td>"];
    [strArray addObject:@"<td colspan='2'>Type Check:</td>"];
    [strArray addObject:@"</tr>"];
    [strArray addObject:@"<tr>"];
    [strArray addObject:@"<td style='text-align:right;'>Last HMV:</td>"];
    [strArray addObject:@"<td style='width:20%;'>L:</td>"];
    [strArray addObject:@"<td style='width:20%;'>R:</td>"];
    [strArray addObject:@"<td colspan='2'>N:</td>"];
    [strArray addObject:@"</tr>"];
    [strArray addObject:@"<tr>"];
    [strArray addObject:@"<td colspan='5'>Delivery / Lease Return / Purchase / Air Craft Carrier / Other:</td>"];
    [strArray addObject:@"</tr>"];
    [strArray addObject:@"<tr>"];
    [strArray addObject:@"<td style='text-align:right;'>Engine Type:</td>"];
    [strArray addObject:@"<td colspan='4'>&nbsp;</td>"];
    [strArray addObject:@"</tr>"];
    [strArray addObject:@"<tr>"];
    [strArray addObject:@"<td style='text-align:right;'>Engine #1 S/N:</td>"];
    [strArray addObject:@"<td>&nbsp;</td>"];
    [strArray addObject:@"<td colspan='3'>LSV:</td>"];
    [strArray addObject:@"</tr>"];
    [strArray addObject:@"<tr>"];
    [strArray addObject:@"<td style='text-align:right;'>Engine #2 S/N:</td>"];
    [strArray addObject:@"<td>&nbsp;</td>"];
    [strArray addObject:@"<td colspan='3'>LSV:</td>"];
    [strArray addObject:@"</tr>"];
    [strArray addObject:@"<tr>"];
    [strArray addObject:@"<td style='text-align:right;'>APU Type</td>"];
    [strArray addObject:@"<td>&nbsp;</td>"];
    [strArray addObject:@"<td colspan='3'>LSV:</td>"];
    [strArray addObject:@"</tr>"];
    [strArray addObject:@"</table>"];
    NSString *tableString = [strArray componentsJoinedByString:@""];
    return tableString;
}

+(NSString*)groupTable:(NSInteger)section
{
    NSMutableArray *taskArray;
    ProjectGroup *record = [groupsArray objectAtIndex:section];
    AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    if(record.tasks) {
        // get records; load into array
        taskArray = [appDelegate getTasksByGroup:record];
    }
    else
    {
        return @"";
    }
    NSMutableArray *strArray = [[NSMutableArray alloc] init];
    [strArray addObject:@"<table border=0 cellspacing=0 style='margin:0 auto; width:90%;'>"];
    [strArray addObject:@"<tr style='background-color:#D0B510'>"];
    [strArray addObject:@"<td style='width:5%; height:50px; text-align:right;'>"];
    [strArray addObject:[NSString stringWithFormat:@"%ld.", section+1]];
    [strArray addObject:@"</td><td style='width:55%;'>"];
    [strArray addObject:[NSString stringWithFormat:@"%@", record.projectgroup_name]];
    [strArray addObject:@"</td>"];
    [strArray addObject:@"<td style='width:7%; text-align:center; border-width:0px; border-style:solid; border-left-width:1px;'>Yes</td>"];
    [strArray addObject:@"<td style='width:7%; text-align:center; border-width:0px; border-style:solid; border-left-width:1px;'>No</td>"];
    [strArray addObject:@"<td style='width:26%; text-align:center; border-width:0px; border-style:solid; border-left-width:1px;'>Notes</td>"];
    [strArray addObject:@"</tr>"];
    
    for(int i=0; i<[taskArray count]; i++)
    {
        Tasks *task = (Tasks*)[taskArray objectAtIndex:i];
        if(i%2 == 0)
        {
            [strArray addObject:@"<tr style='background-color:#EEEEEE'>"];
        }
        else
        {
            [strArray addObject:@"<tr style='background-color:#BBBBBB'>"];
        }
        [strArray addObject:[NSString stringWithFormat:@"<td style='text-align:right;'>%ld.%d </td>", section+1, i+1]];
        NSMutableString *desc = [NSMutableString stringWithString:@"<td height:40px;'>"];
        [desc appendString:task.task_desc];
        [desc appendString:@"</td>"];
        [strArray addObject:desc];
        NSMutableString *tdStr = [NSMutableString stringWithString:@"<td style='width:7%; text-align:center; border-width:0px; border-style:solid; border-left-width:1px;'>"];
        if([task.task_complete intValue] == 1)
        {
            [tdStr appendString:@"<img src='selector-checked.png' alt='asdf' />"];
            [tdStr appendString:@"</td><td style='width:7%; text-align:center; border-width:0px; border-style:solid; border-left-width:1px;'>&nbsp;</td>"];
        }
        else if([task.task_complete intValue] == 0)
        {
            [tdStr appendString:@"&nbsp;</td><td style='width:7%; text-align:center; border-width:0px; border-style:solid; border-left-width:1px;'>"];
            [tdStr appendString:@"<img src='selector-checked.png' alt='asdf' />"];
            [tdStr appendString:@"</td>"];
        }
        [strArray addObject:tdStr];
        [strArray addObject:@"<td style='width:26%; border-width:0px; border-style:solid; border-left-width:1px;'>"];
        NSMutableArray *notesArray = [appDelegate getNotesByTask:task];
        if([notesArray count]>0)
        {
            Notes *note = [notesArray objectAtIndex:0];
            NSString *noteStr = note.message;
            [strArray addObject:noteStr];
            [strArray addObject:@"<br />"];
            NSMutableArray *a_photos = [appDelegate getPhotosByNote:note];
            if ([a_photos count]) {
                Photos *item = [a_photos objectAtIndex:0];
                NSData* data = [item valueForKey:@"photo_image"];
                NSString *styleStr = @"style='width:100%;'";
                NSString *imgStr = [NSString stringWithFormat:@"<img src='data:image/jpg;base64,%@' %@/>", [data base64EncodedStringWithOptions:NSDataBase64EncodingEndLineWithCarriageReturn], styleStr];
                [strArray addObject:imgStr];
            }
        }
        else
        {
            [strArray addObject:@"&nbsp;"];
        }
        [strArray addObject:@"</td>"];
        [strArray addObject:@"</tr>"];
    }
    
    NSString *tableString = [strArray componentsJoinedByString:@""];
    return tableString;
}

+(void)drawPDFOld:(NSString*)fileName
{
    // Create the PDF context using the default page size of 612 x 792.
    UIGraphicsBeginPDFContextToFile(fileName, CGRectZero, nil);
    // Mark the beginning of a new page.
    UIGraphicsBeginPDFPageWithInfo(CGRectMake(0, 0, 612, 792), nil);
    
    /*[self drawText:@"Hello World" inFrame:CGRectMake(0, 0, 300, 50)];
    
    CGPoint from = CGPointMake(0, 0);
    CGPoint to = CGPointMake(200, 300);
    [PDFRenderer drawLineFromPoint:from toPoint:to];
    
    UIImage* logo = [UIImage imageNamed:@"pilot"];
    CGRect frame = CGRectMake(20, 100, 300, 60);
    
    [PDFRenderer drawImage:logo inRect:frame];*/
    
    [self drawLabels];
    [self drawLogo];
    
    // Close the PDF context and write the contents out.
    UIGraphicsEndPDFContext();
}

+(void)drawText
{
    
    NSString* textToDraw = @"Hello World";
    CFStringRef stringRef = (__bridge CFStringRef)textToDraw;
    // Prepare the text using a Core Text Framesetter
    CFAttributedStringRef currentText = CFAttributedStringCreate(NULL, stringRef, NULL);
    CTFramesetterRef framesetter = CTFramesetterCreateWithAttributedString(currentText);
    
    
    CGRect frameRect = CGRectMake(0, 0, 300, 50);
    CGMutablePathRef framePath = CGPathCreateMutable();
    CGPathAddRect(framePath, NULL, frameRect);
    
    // Get the frame that will do the rendering.
    CFRange currentRange = CFRangeMake(0, 0);
    CTFrameRef frameRef = CTFramesetterCreateFrame(framesetter, currentRange, framePath, NULL);
    CGPathRelease(framePath);
    
    // Get the graphics context.
    CGContextRef    currentContext = UIGraphicsGetCurrentContext();
    
    // Put the text matrix into a known state. This ensures
    // that no old scaling factors are left in place.
    CGContextSetTextMatrix(currentContext, CGAffineTransformIdentity);
    
    
    // Core Text draws from the bottom-left corner up, so flip
    // the current transform prior to drawing.
    CGContextTranslateCTM(currentContext, 0, 100);
    CGContextScaleCTM(currentContext, 1.0, -1.0);
    
    // Draw the frame.
    CTFrameDraw(frameRef, currentContext);
    
    CFRelease(frameRef);
    CFRelease(stringRef);
    CFRelease(framesetter);
}

+(void)drawLineFromPoint:(CGPoint)from toPoint:(CGPoint)to
{
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextSetLineWidth(context, 2.0);
    
    CGColorSpaceRef colorspace = CGColorSpaceCreateDeviceRGB();
    
    CGFloat components[] = {0.2, 0.2, 0.2, 0.3};
    
    CGColorRef color = CGColorCreate(colorspace, components);
    
    CGContextSetStrokeColorWithColor(context, color);
    
    
    CGContextMoveToPoint(context, from.x, from.y);
    CGContextAddLineToPoint(context, to.x, to.y);
    
    CGContextStrokePath(context);
    CGColorSpaceRelease(colorspace);
    CGColorRelease(color);
    
}


+(void)drawImage:(UIImage*)image inRect:(CGRect)rect
{
    [image drawInRect:rect];
}

+(void)drawText:(NSString*)textToDraw inFrame:(CGRect)frameRect
{
    
    CFStringRef stringRef = (__bridge CFStringRef)textToDraw;
    // Prepare the text using a Core Text Framesetter
    CFAttributedStringRef currentText = CFAttributedStringCreate(NULL, stringRef, NULL);
    CTFramesetterRef framesetter = CTFramesetterCreateWithAttributedString(currentText);
    
    
    CGMutablePathRef framePath = CGPathCreateMutable();
    CGPathAddRect(framePath, NULL, frameRect);
    
    // Get the frame that will do the rendering.
    CFRange currentRange = CFRangeMake(0, 0);
    CTFrameRef frameRef = CTFramesetterCreateFrame(framesetter, currentRange, framePath, NULL);
    CGPathRelease(framePath);
    
    // Get the graphics context.
    CGContextRef    currentContext = UIGraphicsGetCurrentContext();
    
    // Put the text matrix into a known state. This ensures
    // that no old scaling factors are left in place.
    CGContextSetTextMatrix(currentContext, CGAffineTransformIdentity);
    
    // Core Text draws from the bottom-left corner up, so flip
    // the current transform prior to drawing.
    CGContextTranslateCTM(currentContext, 0, frameRect.origin.y*2);
    CGContextScaleCTM(currentContext, 1.0, -1.0);
    
    // Draw the frame.
    CTFrameDraw(frameRef, currentContext);
    
    CGContextScaleCTM(currentContext, 1.0, -1.0);
    CGContextTranslateCTM(currentContext, 0, (-1)*frameRect.origin.y*2);
    
    CFRelease(frameRef);
    CFRelease(stringRef);
    CFRelease(framesetter);
}


+(void)drawLabels
{
    NSArray* objects = [[NSBundle mainBundle] loadNibNamed:@"ReportView" owner:nil options:nil];
    UIView* mainView = [objects objectAtIndex:0];
    for (UIView* view in [mainView subviews]) {
        if([view isKindOfClass:[UILabel class]])
        {
            UILabel* label = (UILabel*)view;
            [self drawText:label.text inFrame:label.frame];
        }
    }
}


+(void)drawLogo
{
    
    NSArray* objects = [[NSBundle mainBundle] loadNibNamed:@"ReportView" owner:nil options:nil];
    
    UIView* mainView = [objects objectAtIndex:0];
    
    for (UIView* view in [mainView subviews]) {
        if([view isKindOfClass:[UIImageView class]])
        {
            
            UIImage* logo = [UIImage imageNamed:@"pilot"];
            [self drawImage:logo inRect:view.frame];
        }
    }
    
}


+(void)drawTableAt:(CGPoint)origin
     withRowHeight:(int)rowHeight
    andColumnWidth:(int)columnWidth
       andRowCount:(int)numberOfRows
    andColumnCount:(int)numberOfColumns

{
    
    for (int i = 0; i <= numberOfRows; i++) {
        
        int newOrigin = origin.y + (rowHeight*i);
        
        
        CGPoint from = CGPointMake(origin.x, newOrigin);
        CGPoint to = CGPointMake(origin.x + (numberOfColumns*columnWidth), newOrigin);
        
        [self drawLineFromPoint:from toPoint:to];
        
        
    }
    
    for (int i = 0; i <= numberOfColumns; i++) {
        
        int newOrigin = origin.x + (columnWidth*i);
        
        
        CGPoint from = CGPointMake(newOrigin, origin.y);
        CGPoint to = CGPointMake(newOrigin, origin.y +(numberOfRows*rowHeight));
        
        [self drawLineFromPoint:from toPoint:to];
        
        
    }
}

+(void)drawTableDataAt:(CGPoint)origin
         withRowHeight:(int)rowHeight
        andColumnWidth:(int)columnWidth
           andRowCount:(int)numberOfRows
        andColumnCount:(int)numberOfColumns
{
    int padding = 10;
    
    NSArray* headers = [NSArray arrayWithObjects:@"Quantity", @"Description", @"Unit price", @"Total", nil];
    NSArray* invoiceInfo1 = [NSArray arrayWithObjects:@"1", @"Development", @"$1000", @"$1000", nil];
    NSArray* invoiceInfo2 = [NSArray arrayWithObjects:@"1", @"Development", @"$1000", @"$1000", nil];
    NSArray* invoiceInfo3 = [NSArray arrayWithObjects:@"1", @"Development", @"$1000", @"$1000", nil];
    NSArray* invoiceInfo4 = [NSArray arrayWithObjects:@"1", @"Development", @"$1000", @"$1000", nil];
    
    NSArray* allInfo = [NSArray arrayWithObjects:headers, invoiceInfo1, invoiceInfo2, invoiceInfo3, invoiceInfo4, nil];
    
    for(int i = 0; i < [allInfo count]; i++)
    {
        NSArray* infoToDraw = [allInfo objectAtIndex:i];
        
        for (int j = 0; j < numberOfColumns; j++)
        {
            
            int newOriginX = origin.x + (j*columnWidth);
            int newOriginY = origin.y + ((i+1)*rowHeight);
            
            CGRect frame = CGRectMake(newOriginX + padding, newOriginY + padding, columnWidth, rowHeight);
            
            
            [self drawText:[infoToDraw objectAtIndex:j] inFrame:frame];
        }
        
    }
    
}

@end
