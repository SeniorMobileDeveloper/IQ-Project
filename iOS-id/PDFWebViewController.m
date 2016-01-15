//
//  PDFWebViewController.m
//  iOS-id
//
//  Created by stephen on 11/18/13.
//  Copyright (c) 2013 stephen. All rights reserved.
//

#import "PDFWebViewController.h"
#import "DataManagerObject.h"

@interface PDFWebViewController ()

@end

@implementation PDFWebViewController

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
	// Do any additional setup after loading the view.
    
    // ensure item is loaded
    DataManagerObject* dm = [DataManagerObject sharedInstance];
    if(pdfFilename==nil) {
        // we use pdfFilename for all url protocols.
        // check requestType for instructions
        pdfFilename = (NSString *)[dm objectForKey:@"pdfFilename"];
    }
    urlRequestType = [dm objectForKey:@"requestType"];
    
    
    // apply data from parent
    [cNavigationItem setTitle:pdfFilename];
    
    [self openPDF];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)openPDF {
    NSURL *url;
    DataManagerObject* dm = [DataManagerObject sharedInstance];
    
    if (urlRequestType!=nil && ![urlRequestType isEqual:@"nil"]) {
        url = [NSURL URLWithString:pdfFilename];
    } else {
        NSString *urlAddress = [[NSString alloc]init];
        urlAddress = [[NSBundle mainBundle]pathForResource:pdfFilename ofType:nil];
        url = [NSURL fileURLWithPath:urlAddress];
    }
    
    // always clear the url request type
    
    [dm setObject:@"nil" forKey:@"requestType"];
    
    NSURLRequest *requestObj = [NSURLRequest requestWithURL:url];
    [cWebView loadRequest:requestObj];
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

@end
