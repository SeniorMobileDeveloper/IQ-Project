//
//  PDFListController.m
//  iOS-id
//
//  Created by stephen on 11/15/13.
//  Copyright (c) 2013 stephen. All rights reserved.
//

#import "PDFListController.h"
#import "AppDelegate.h"
#import "DataManagerObject.h"

@interface PDFListController ()

// data core properties
@property (nonatomic, retain) NSManagedObjectContext *managedObjectContent;
@property (nonatomic, strong) NSMutableArray *a_ns_tableData;

@end

@implementation PDFListController

@synthesize delegate;
@synthesize cNavigationBar;
@synthesize cNavigationItem;
@synthesize cTableView;
@synthesize pdfItemId;
@synthesize pdfTitle;
@synthesize selectedPdf;
@synthesize pdfFilename;
@synthesize currentPopoverSegue;
@synthesize popover;

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
    
    // database;
    // make instance and reference content object
    AppDelegate *appDelegate = [UIApplication sharedApplication].delegate;
    self.managedObjectContent = appDelegate.managedObjectContent;
    
    // ensure item is loaded
    if(pdfItemId==nil) {
        DataManagerObject* dm = [DataManagerObject sharedInstance];
        pdfItemId = (NSString *)[dm objectForKey:@"pdfItemId"];
        pdfTitle = (NSString *)[dm objectForKey:@"pdfTitle"];
    }

    // apply data from parent
    [cNavigationItem setTitle:pdfTitle];
    
    // load projects from database
    [self loadData];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)loadData {
    
    AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    
    // get records; load into array
    _a_ns_tableData = [appDelegate getPDFListById:pdfItemId];
    
    // apply data to table
    [cTableView reloadData];
    
}

- (IBAction)cancelButtonTouch:(id)sender {

    // call delegated method to dismiss. This goes to the
    // parent method where it is defined
    [delegate dismissPopover:YES update:NO];
}

//
// Table
//

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [_a_ns_tableData count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"tableCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    if(cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    // Configure the cell...
    
    // get project
    Pdf *record = [_a_ns_tableData objectAtIndex:indexPath.row];
    NSString *recordName = [NSString stringWithFormat:@"%@ ",record.pdf_name];
    
    cell.textLabel.text = recordName;

    return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    // retain
    selectedPdf = [_a_ns_tableData objectAtIndex:indexPath.row];
    
    DataManagerObject* dm = [DataManagerObject sharedInstance];
    [dm setObject:selectedPdf.pdf_filename forKey:@"pdfFilename"];
    [dm setObject:pdfItemId forKey:@"pdfItemId"];
    [dm setObject:pdfTitle forKey:@"pdfTitle"];

    //
    // open pdf
    //
    
    
    // get reference
    ////UIViewController *viewCon = [self.storyboard instantiateViewControllerWithIdentifier:@"pdfWebViewID"];
    //UIView *anchor = self.view;
    //popover = [[UIPopoverController alloc] initWithContentViewController:viewCon];
   
    
    //[popover presentPopoverFromRect:CGRectMake(anchor.frame.origin.x, anchor.frame.origin.y, anchor.frame.size.height, anchor.frame.size.width) inView:anchor.superview permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
    
    
    // set options
    //viewCon.modalPresentationStyle = UIModalPresentationFormSheet;
    ////viewCon.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
    
    // switch views
    ////[self presentViewController:viewCon animated:YES completion:nil];
    //viewCon.view.superview.frame = CGRectMake(0, 0, 540, 620);
    //viewCon.view.superview.center = self.view.center;
    
    // dismiss list
    [delegate switchToWebViewOnDismissPopover:YES];
}


//
// Methods defined in popup
//

- (void) dismissDynamicPopover:(BOOL) doclose update:(BOOL)doupdate {
    // dismiss view
    [popover dismissPopoverAnimated:YES];
   
    if (doupdate) {
        // refresh data
        [self loadData];
    }
}

- (void) dismissPopover:(BOOL) doclose update:(BOOL)doupdate {
    // dismiss view
    [[currentPopoverSegue popoverController] dismissPopoverAnimated:YES];
    
    if (doupdate) {
        // refresh data
        [self loadData];
    }
}


@end
