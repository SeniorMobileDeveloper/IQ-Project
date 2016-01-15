//
//  LabelStandardIndent.m
//  iOS-id
//
//  Created by stephen on 10/30/13.
//  Copyright (c) 2013 stephen. All rights reserved.
//

#import "LabelStandardIndent.h"

@implementation LabelStandardIndent

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

// indent
- (void)drawTextInRect:(CGRect)rect {
    UIEdgeInsets insets = {0,19,0,10};
    return [super drawTextInRect:UIEdgeInsetsInsetRect(rect, insets)];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/


@end
