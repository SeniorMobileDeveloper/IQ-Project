//
//  NSObject+TableCellHandler.m
//  iOS-id
//
//  Created by stephen on 10/20/13.
//  Copyright (c) 2013 stephen. All rights reserved.
//

#import "NSObject+TableCellHandler.h"

@implementation NSObject (TableCellHandler)

- (UIImageView *)createImageForCell:(NSString *)imageName {
    UIImageView *imgView = [[UIImageView alloc] initWithFrame:CGRectZero];
    imgView.image = [UIImage imageNamed:imageName];
    return imgView;
}
- (UITableViewCell *)addPositionContraintsToCell:(UITableViewCell *)cell forView:(id)view xpos:(CGFloat)xpos ypos:(CGFloat)ypos {
    
    NSLayoutConstraint *Hconstraint = [NSLayoutConstraint constraintWithItem:view attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual toItem:cell attribute:NSLayoutAttributeTrailing multiplier:1.0f constant:xpos];
    
    NSLayoutConstraint *Vconstraint = [NSLayoutConstraint constraintWithItem:view attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:cell attribute:NSLayoutAttributeTop multiplier:1.0f constant:ypos];
    
    [cell addConstraint:Vconstraint];
    [cell addConstraint:Hconstraint];
    
    return cell;
}
- (UITableViewCell *)addSizeContraintsToCell:(UITableViewCell *)cell forView:(id)view height:(CGFloat)height width:(CGFloat)width {
    
    NSLayoutConstraint *Wconstraint = [NSLayoutConstraint constraintWithItem:view attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0f constant:width];
    NSLayoutConstraint *Hconstraint = [NSLayoutConstraint constraintWithItem:view attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0f constant:height];
    
    [cell addConstraint:Wconstraint];
    [cell addConstraint:Hconstraint];
    
    return cell;
}

@end
