//
//  PDFWebViewController.h
//  iOS-id
//
//  Created by stephen on 11/18/13.
//  Copyright (c) 2013 stephen. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol PDFViewerControllerDelegate; // declare a protocol name to be used by the parent for communication

@interface PDFWebViewController : UIViewController

- (IBAction)closeButtonTouch:(id)sender;
- (IBAction)cancelButtonTouch:(id)sender;

- (void)openPDF;

@property IBOutlet UINavigationItem *cNavigationItem;
@property IBOutlet UIWebView *cWebView;

@property (nonatomic, retain)NSString *urlRequestType;

// parent
@property (nonatomic, retain) NSString *pdfFilename;

// parent connections
//@property (nonatomic, strong) Tasks *selectedTask;
@property (weak)id <PDFViewerControllerDelegate> delegate;


@end


// define delegate protocol for parent.
// These protocol declarations dictate what the parent will define
@protocol PDFViewerControllerDelegate <NSObject>

@optional

- (void) dismissDynamicPopover:(BOOL) doclose update:(BOOL)doupdate;

@end
