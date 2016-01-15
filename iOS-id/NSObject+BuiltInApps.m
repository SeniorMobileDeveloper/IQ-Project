//
//  NSObject+BuiltInApps.m
//  iOS-id
//
//  Created by stephen on 11/15/13.
//  Copyright (c) 2013 stephen. All rights reserved.
//

#import "NSObject+BuiltInApps.h"

@implementation NSObject (BuiltInApps)

static id selfSender;

// Address Book

- (void)openAddressBook:(id)sender {
    selfSender = sender;
 
    ABPeoplePickerNavigationController *picker = [[ABPeoplePickerNavigationController alloc] init];
    picker.peoplePickerDelegate = self;
   
    [sender presentViewController:picker animated:YES completion:nil];
    
}
- (void)openEventCalendar:(id)sender {
    selfSender = sender;
    
    EKEventStore *eventStore = [[EKEventStore alloc]init];
    
    if ([eventStore respondsToSelector:@selector(requestAccessToEntityType:completion:)]) {
        [eventStore requestAccessToEntityType:EKEntityTypeEvent completion:^(BOOL granted, NSError *error) {
            
            [selfSender performSelectorOnMainThread:@selector(presentEventEditViewControllerWithEventStore:) withObject:eventStore waitUntilDone:NO];
        }];
    }
    
}
- (void)presentEventEditViewControllerWithEventStore:(EKEventStore *)eventStore {
    EKEventEditViewController *eventEditVC = [[EKEventEditViewController alloc] init];
    eventEditVC.eventStore = eventStore;
    
    eventEditVC.editViewDelegate = selfSender;
    
    // uncomment the following to create an event
    /*
    EKEvent * event = [EKEvent eventWithEventStore:eventStore];
    event.title = @"New Event";
    event.startDate = [NSDate date];
    event.endDate = [NSDate date];
    event.URL = [NSURL URLWithString:@"http://www.google.com"];
    event.notes = @"Scheduled Event";
    event.allDay = YES;
    eventEditVC.event = event;
    */
    
    // open view
    [selfSender presentViewController:eventEditVC animated:YES completion:nil];
    
}

- (void)eventEditViewController:(EKEventEditViewController *)controller didCompleteWithAction:(EKEventEditViewAction)action {
    [selfSender dismissViewControllerAnimated:YES completion:nil];
}
- (EKCalendar *)eventEditViewControllerDefaultCalendarForNewEvents:(EKEventEditViewController *)controller {
    EKCalendar *calendarForEdit = nil; // this should point to self.defaultCalendar but we do not have a SELF interface
    
    return calendarForEdit;
}

- (void)peoplePickerNavigationControllerDidCancel:(ABPeoplePickerNavigationController *)peoplePicker {
    [selfSender dismissViewControllerAnimated:YES completion:nil];
}
- (BOOL)peoplePickerNavigationController:(ABPeoplePickerNavigationController *)peoplePicker shouldContinueAfterSelectingPerson:(ABRecordRef)person {
    // do something with selection
    
    [selfSender dismissViewControllerAnimated:YES completion:nil];
    
    return NO;
}
- (BOOL)peoplePickerNavigationController:(ABPeoplePickerNavigationController *)peoplePicker shouldContinueAfterSelectingPerson:(ABRecordRef)person property:(ABPropertyID)property identifier:(ABMultiValueIdentifier)identifier {
    
    return NO;
}

@end
