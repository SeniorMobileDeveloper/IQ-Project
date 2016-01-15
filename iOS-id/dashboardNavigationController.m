//
//  dashboardNavigationController.m
//  iOS-id
//
//  Created by stephen on 11/4/13.
//  Copyright (c) 2013 stephen. All rights reserved.
//

#import "dashboardNavigationController.h"
#import "NSObject+NetworkReach.h" // first used by login screen; not sure it needs to be declared again

@interface dashboardNavigationController ()

@end

@implementation dashboardNavigationController

@synthesize navbar;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidAppear:(BOOL)animated {
 
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    // Still not 100% reliable.
    // assigning point of 30 instead of the original 32 or 37
    //navbar.barTintColor = [UIColor colorWithRed:30.0/255.0 green:30.0/255.0 blue:30.0/255.0 alpha:1.0];
    //[[[self navigationController] navigationBar] setBarTintColor:[UIColor colorWithRed:30.0/255.0 green:30.0/255.0 blue:30.0/255.0 alpha:1.0]];
    [self applyCustomColors];

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

- (void)applyCustomColors; {
    navbar.barTintColor = [UIColor colorWithRed:32.0/255.0 green:32.0/255.0 blue:32.0/255.0 alpha:1.0];
    navbar.translucent = NO;
}

@end
