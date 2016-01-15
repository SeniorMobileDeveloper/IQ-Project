//
//  NSObject+BuiltInApps.h
//  iOS-id
//
//  Created by stephen on 11/15/13.
//  Copyright (c) 2013 stephen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AddressBookUI/AddressBookUI.h>
#import <EventKit/EventKit.h>
#import <EventKitUI/EventKitUI.h>

@interface NSObject (BuiltInApps) <ABPeoplePickerNavigationControllerDelegate, EKEventEditViewDelegate>

- (void)openAddressBook:(id)sender;
- (void)openEventCalendar:(id)sender;

- (void)presentEventEditViewControllerWithEventStore:(EKEventStore *)eventStore;

@end
