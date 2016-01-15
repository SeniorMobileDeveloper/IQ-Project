//
//  ViewController.h
//  iOS-id
//
//  Created by stephen on 9/25/13.
//  Copyright (c) 2013 stephen. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface ViewController : UIViewController


- (IBAction)loginButtonTouch:(id)sender;

- (void) dismissAlert:(UIAlertView*)x;




@property IBOutlet UITextField *userText;
@property IBOutlet UITextField *userPass;
@property IBOutlet UIButton *loginButton;
@property IBOutlet UIButton *createAccountButton;
@property (nonatomic,strong) IBOutlet UILabel *versionLabel;

@property BOOL doBuildDatabaseOnStartupAfterDelay;


@end
