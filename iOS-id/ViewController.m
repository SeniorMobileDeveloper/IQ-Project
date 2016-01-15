//
//  ViewController.m
//  iOS-id
//
//  Created by stephen on 9/25/13.
//  Copyright (c) 2013 stephen. All rights reserved.
//

/*
 Entry View for app.
 
 ------------------------------
 Views that create new states:
 ------------------------------
 THIS
 dashboardNavigationController
 ControlPanelViewController
 ProjectInfoController
 
 Might be at least 1 more (web view) but only concerned
 with those that will use the update monitor
 
*/

#import "ViewController.h"
#import "AppDelegate.h"
#import "Projects.h"
#import "DataManagerObject.h"
#import "NSObject+DataCoreHandler.h"
#import "NSObject+NetworkReach.h"
#import "NSObject+CommonFunctions.h"

@interface ViewController ()

@property (nonatomic, retain) NSManagedObjectContext *managedObjectContent;



@end

@implementation ViewController

DataManagerObject* dm;


- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    // database;
    // make instance and reference content object
    AppDelegate *appDelegate = [UIApplication sharedApplication].delegate;
    self.managedObjectContent = appDelegate.managedObjectContent;
    
    // do we rebuild the database?
    // We have a new migration method that is causing the store check to be invalid on initial load.
    // Actually, that doesn't seem like it's the problem. The problem could be that I was not
    // resetting the rebuild flag. I say "seems" because I'm not testing right now. Instead, for the
    // prototype version, I am checking the project data and then rebuilding if none exist
    
    // 1099
    // LAST 12-12-13
    // Complete next commented code to rebuild photos on assignment. The assignment flag
    // is set when the database does not exist.
    
    dm = [DataManagerObject sharedInstance];
    
    //BOOL adminbuild = false;
    //if ([(NSString*)[dm objectForKey:@"database"] isEqual:@"rebuildDatabase"])adminbuild=true;
    
    // Typically, this only evaluates TRUE if the developer removed the SQL file from the build.
    // This is done to recreate a usable database to include with the project
    if ([(NSString*)[dm objectForKey:@"database"] isEqual:@"rebuildDatabase"]) {
        // _doBuildDatabaseOnStartupAfterDelay
        [self rebuildDatabaseOnEmpty:appDelegate managedObjectContent:self.managedObjectContent delayBuild:false];
    } else {
        
        if ([(NSString*)[dm objectForKey:@"database"] isEqual:@"rebuildPhotos"]) {
            _doBuildDatabaseOnStartupAfterDelay = true;
            
            
        }
    }
    // clear bit
    [dm setObject:@"none" forKey:@"database"];
    
    //[[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
   
    _loginButton.layer.cornerRadius = 7;
    _createAccountButton.layer.cornerRadius = 7;
    
    _userText.text = @"user";
    _userPass.text = @"pass";
    
    _versionLabel.text = @"version 1.4.2.435";
    
    // reset network monitor. At the login screen, the monitor is disabled.
    [self stopWebService];
    [self stopUpdateMonitor];
    [self stopNetworkService];
    
}
- (void)viewDidAppear:(BOOL)animated
{
    // If the app needs to rebuild the database, we check if there was a delay. If so,
    // provide indicator to user while database is rebuilt, and call build routine.
    if (_doBuildDatabaseOnStartupAfterDelay) {
        // dbBusyLoaderView
        //UIActivityIndicatorView *activity =
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:@"The database is being created. Please wait until the main screen activates (approx. 10 to 15 seconds.) \n\n You may need to restart the app once the database is complete." delegate:nil cancelButtonTitle:nil otherButtonTitles:nil, nil];
        
        [alert show];
        
        // Indicator subview is not displaying.
        // Adding subview to alert is not available for ios7
        //UIActivityIndicatorView *activity = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        //activity.frame = CGRectMake(10, 10, 16, 16);
        // OR
        //activity.center = CGPointMake(alert.bounds.size.width/2, alert.bounds.size.height/2);
        //[alert addSubview:activity];
        //[activity startAnimating];
        
        
        [self performSelector:@selector(dismissAlert:) withObject:alert afterDelay:13];
        
        
        // pause to give alert time to appear
        [self performSelector:@selector(beginDatabaseInstallation) withObject:self afterDelay:1];
        
    }
    
    [self startNetworkService];
}
- (void)beginDatabaseInstallation {
 
    ////[self installDatabasePhotos:appDelegate managedObjectContent:self.managedObjectContent];
    
    AppDelegate *appDelegate = [UIApplication sharedApplication].delegate;
    // if ([self rebuildDatabase:self.managedObjectContent]) {
    if ([self installDatabasePhotos:appDelegate managedObjectContent:self.managedObjectContent]) {
        // complete
    }
    
}
- (void) viewWillDisappear:(BOOL)animated
{
    //[self stopNetworkService];
}

- (void) dismissAlert:(UIAlertView*)x
{
    [x dismissWithClickedButtonIndex:-1 animated:YES];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

- (IBAction)loginButtonTouch:(id)sender {
    
    if ([_userText.text isEqual: @"user"] && [_userPass.text isEqual: @"pass"]) {

        _userPass.text = @"";
        
        
        // clear monitor reset bit
        [dm setObject:@"nil" forKey:@"isMonitorCancel"];
        
        
        //[self performSegueWithIdentifier:@"segueDashboard" sender:self];
        
        // get reference
        UIViewController *viewCon = [self.storyboard instantiateViewControllerWithIdentifier:@"applicationDashboard"];
        
        // set options
        viewCon.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
        
        // switch views
        [self presentViewController:viewCon animated:YES completion:nil];
        
        
    // open control panel if necessary
    } else if ([_userText.text isEqual: @"admin"] && [_userPass.text isEqual: @"pass"]){
        
        _userPass.text = @"";
        
        // get reference
        UIViewController *viewCon = [self.storyboard instantiateViewControllerWithIdentifier:@"adminControlPanelStoryboardView"];
        
        // set options
        viewCon.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
        
        // switch views
        [self presentViewController:viewCon animated:YES completion:nil];
        
    } else {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:@"Incorrect Username or Password" delegate:nil cancelButtonTitle:@"ok" otherButtonTitles:nil, nil];
        
        [alert show];
    }
}

@end
