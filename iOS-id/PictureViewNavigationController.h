//
//  PictureViewNavigationController.h
//  iOS-id
//
//  Created by Stephen on 6/11/15.
//  Copyright (c) 2015 stephen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Notes.h"

@interface PictureViewNavigationController : UINavigationController

@property (nonatomic, strong) Notes *selectedNote;

@end
