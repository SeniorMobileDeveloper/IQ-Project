//
//  MapExpandedView.m
//  iOS-id
//
//  Created by stephen on 10/31/13.
//  Copyright (c) 2013 stephen. All rights reserved.
//

#import "MapExpandedView.h"

@interface MapExpandedView ()

@end

@implementation MapExpandedView

@synthesize zoomLocation;
@synthesize mapView;
@synthesize delegate;
@synthesize closeButton;

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
    
    // go to location
    if (zoomLocation.latitude != 0 || zoomLocation.longitude != 0) {
        MKCoordinateRegion viewRegion = MKCoordinateRegionMakeWithDistance(zoomLocation, 0.3*METERS_PER_MILE, 0.3*METERS_PER_MILE);
        [mapView setRegion:viewRegion animated:NO];
    }
    
    closeButton.layer.masksToBounds = YES;
    closeButton.layer.cornerRadius = 5.0f;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)cancelButtonTouch:(id)sender {
    
    // is new data saved?
    //
    // IF NOT confirm cancel
    //
    
    // call delegated method to dismiss. This goes to the
    // parent method where it is defined
    [delegate dismissPopover:YES update:NO];
    
}

@end
