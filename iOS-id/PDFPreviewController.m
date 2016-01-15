//
//  PDFWebViewController.m
//  iOS-id
//
//  Created by stephen on 11/18/13.
//  Copyright (c) 2013 stephen. All rights reserved.
//

#import "PDFPreviewController.h"
#import "DataManagerObject.h"

@interface PDFPreviewController ()

@end

@implementation PDFPreviewController

@synthesize delegate;
@synthesize pdfFilename;
@synthesize cNavigationItem;
@synthesize cWebView;
@synthesize urlRequestType;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [cNavigationItem setTitle:@"Preview"];
    [self openPDF];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)openPDF {
    DataManagerObject* dm = [DataManagerObject sharedInstance];
    NSString *content = [dm objectForKey:@"pdfHTML"];
    [dm setObject:@"nil" forKey:@"requestType"];
    NSString *path = [[NSBundle mainBundle] bundlePath];
    NSURL *baseURL = [NSURL fileURLWithPath:path];
    [cWebView loadHTMLString:content baseURL:baseURL];
}

- (IBAction)cancelButtonTouch:(id)sender {
    
    // call delegated method to dismiss. This goes to the
    // parent method where it is defined
    [delegate dismissDynamicPopover:YES update:NO];
    
}
- (IBAction)closeButtonTouch:(id)sender {
    
    // we assume the parent stored its id
    DataManagerObject* dm = [DataManagerObject sharedInstance];
    NSString *storyboardId = (NSString *)[dm objectForKey:@"pdfParentStoryboardId"]; //projectInfoStoryboardView
    
    // get reference
    UIViewController *viewCon = [self.storyboard instantiateViewControllerWithIdentifier:storyboardId];
    
    // set options
    //viewCon.modalPresentationStyle = UIModalPresentationFormSheet;
    viewCon.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
    
    // switch views
    [self presentViewController:viewCon animated:YES completion:nil];
}

- (IBAction)createPDF:(id)sender
{
    NSDate *today = [NSDate date];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd"];
    NSString *str_today = [dateFormatter stringFromDate:today];
    NSString *newFileName = [str_today stringByAppendingString:@".pdf"];
    [self createPDFfromUIView:newFileName];
    
    NSString *message = [NSString stringWithFormat:@"PDF created with the name of %@", newFileName];
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"" message:message delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
    [alertView show];
}

-(void)createPDFfromUIView:(NSString*)aFilename
{
    NSString *heightStr = [cWebView stringByEvaluatingJavaScriptFromString:@"document.body.scrollHeight;"];
    
    int height = [heightStr intValue];
    //  CGRect screenRect = [[UIScreen mainScreen] bounds];
    //  CGFloat screenHeight = (self.contentWebView.hidden)?screenRect.size.width:screenRect.size.height;
    CGFloat screenHeight = cWebView.bounds.size.height;
    int pages = ceil(height / screenHeight);
    
    NSMutableData *pdfData = [NSMutableData data];
    UIGraphicsBeginPDFContextToData(pdfData, cWebView.bounds, nil);
    CGRect frame = [cWebView frame];
    for (int i = 0; i < pages; i++) {
        // Check to screenHeight if page draws more than the height of the UIWebView
        if ((i+1) * screenHeight  > height) {
            CGRect f = [cWebView frame];
            f.size.height -= (((i+1) * screenHeight) - height);
            [cWebView setFrame: f];
        }
        
        UIGraphicsBeginPDFPage();
        CGContextRef currentContext = UIGraphicsGetCurrentContext();
        //      CGContextTranslateCTM(currentContext, 72, 72); // Translate for 1" margins
        
        [[[cWebView subviews] lastObject] setContentOffset:CGPointMake(0, screenHeight * i) animated:NO];
        [cWebView.layer renderInContext:currentContext];
    }
    
    UIGraphicsEndPDFContext();
    // Retrieves the document directories from the iOS device
    NSArray* documentDirectories = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask,YES);
    
    NSString* documentDirectory = [documentDirectories objectAtIndex:0];
    NSString* documentDirectoryFilename = [documentDirectory stringByAppendingPathComponent:aFilename];
    
    // instructs the mutable data object to write its context to a file on disk
    [pdfData writeToFile:documentDirectoryFilename atomically:YES];
    [cWebView setFrame:frame];
}

@end
