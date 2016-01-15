//
//  NSObject+TableCellHandler.h
//  iOS-id
//
//  Created by stephen on 10/20/13.
//  Copyright (c) 2013 stephen. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSObject (TableCellHandler)

- (UITableViewCell *)addPositionContraintsToCell:(UITableViewCell *)cell forView:(id)view xpos:(CGFloat)xpos ypos:(CGFloat)ypos;

- (UITableViewCell *)addSizeContraintsToCell:(UITableViewCell *)cell forView:(id)view height:(CGFloat)height width:(CGFloat)width;

- (UIImageView *)createImageForCell:(NSString *)imageName;

@end
