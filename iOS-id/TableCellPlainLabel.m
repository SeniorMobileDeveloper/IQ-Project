//
//  TableCellPlainLabel.m
//  iOS-id
//
//  Created by stephen on 10/22/13.
//  Copyright (c) 2013 stephen. All rights reserved.
//

#import "TableCellPlainLabel.h"

@implementation TableCellPlainLabel


@synthesize titleLabel;


- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

// Use subviews to locate delete confirmation view. We will bring
// this view to the front so that nothing covers it. The animation
// is a bit shaky when canceling the delete view.
- (void)layoutSubviews
{
    [super layoutSubviews];
    
    for(UIView *subview in self.subviews) {
        
        for(UIView *subview2 in subview.subviews) {
            if([NSStringFromClass([subview2 class]) isEqualToString:@"UITableViewCellDeleteConfirmationView"]) {
                // bring delete view to front
                [subview bringSubviewToFront:subview2];
            }
        }
    }
}

@end
