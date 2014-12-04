//
//  ScrollViewCustom.m
//  Testing
//
//  Created by Parikshit Hedau on 27/11/14.
//  Copyright (c) 2014 Parikshit Hedau. All rights reserved.
//

#import "ScrollViewCustom.h"

@implementation ScrollViewCustom

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (void)layoutSubviews {
    [super layoutSubviews];
    
    UIView *tileContainerView = (UIView*)[self viewWithTag:200];
    
    // center the image as it becomes smaller than the size of the screen
    CGSize boundsSize = self.bounds.size;
    CGRect frameToCenter = tileContainerView.frame;
    
    // center horizontally
    if (frameToCenter.size.width < boundsSize.width)
        frameToCenter.origin.x = (boundsSize.width - frameToCenter.size.width) / 2;
    else
        frameToCenter.origin.x = 0;
    
    // center vertically
    if (frameToCenter.size.height < boundsSize.height)
        frameToCenter.origin.y = (boundsSize.height - frameToCenter.size.height) / 2;
    else
        frameToCenter.origin.y = 0;
    
    tileContainerView.frame = frameToCenter;
}

@end
