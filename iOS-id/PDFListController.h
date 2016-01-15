//
//  PDFListController.h
//  iOS-id
//
//  Created by stephen on 11/15/13.
//  Copyright (c) 2013 stephen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Pdf.h"
#import "PDFWebViewController.h"

@protocol PDFListControllerDelegate; // declare a protocol name to be used by the parent for communication

@interface PDFListController : UIViewController <UITableViewDelegate, UITableViewDataSource, PDFViewerControllerDelegate>

- (void)loadData;

- (IBAction)cancelButtonTouch:(id)sender;

@property IBOutlet UITableView *cTableView;
@property IBOutlet UINavigationItem *cNavigationItem;
@property IBOutlet UINavigationBar *cNavigationBar;

@property (nonatomic, strong) Pdf *selectedPdf;

// parent
@property (nonatomic, retain) NSString *pdfTitle;
@property (nonatomic, assign) NSString *pdfItemId;

// child
@property (nonatomic, retain) NSString *pdfFilename;

@property UIPopoverController *popover;

// popover control
@property (strong, nonatomic) UIStoryboardPopoverSegue *currentPopoverSegue;
@property (strong, nonatomic) PDFWebViewController *pvcPdfViewer;


// parent connections
//@property (nonatomic, strong) Tasks *selectedTask;
@property (weak)id <PDFListControllerDelegate> delegate;


@end


// define delegate protocol for parent.
// These protocol declarations dictate what the parent will define
@protocol PDFListControllerDelegate <NSObject>

@optional

- (void) dismissPopover:(BOOL) doclose update:(BOOL)doupdate;
- (void) switchToWebViewOnDismissPopover:(BOOL) doclose;

@end

