//
//  MapExpandedView.h
//  iOS-id
//
//  Created by stephen on 10/31/13.
//  Copyright (c) 2013 stephen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>

#define METERS_PER_MILE 1609.344

@protocol MapExpandedControllerDelegate; // declare a protocol name to be used by the parent for communication

@interface MapExpandedView : UIViewController


- (IBAction)cancelButtonTouch:(id)sender;

@property IBOutlet UIButton *closeButton;


// parent connections
@property (weak)id <MapExpandedControllerDelegate> delegate;


// map
@property IBOutlet MKMapView *mapView;
@property CLLocationCoordinate2D zoomLocation;

@end


// define delegate protocol for parent.
// These protocol declarations dictate what the parent will define
@protocol MapExpandedControllerDelegate <NSObject>

@optional

- (void) dismissPopover:(BOOL) doclose update:(BOOL)doupdate;

@end

