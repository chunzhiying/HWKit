//
//  HWViewHelper.m
//  HWKitDemo
//
//  Created by 陈智颖 on 2016/10/17.
//  Copyright © 2016年 YY. All rights reserved.
//

#import "HWHelper.h"

@implementation UIView (UIViewGeometryHelper)

#pragma mark - Width
- (CGFloat)width {
    return self.frame.size.width;
}

- (void)setWidth:(CGFloat)width {
    self.frame = CGRectMake(self.x, self.y, width, self.height);
}

#pragma mark - Height
- (CGFloat)height {
    return self.frame.size.height;
}

- (void)setHeight:(CGFloat)height {
    self.frame = CGRectMake(self.x, self.y, self.width, height);
}

#pragma mark - X
- (CGFloat)x {
    return self.frame.origin.x;
}

- (void)setX:(CGFloat)x {
    self.frame = CGRectMake(x, self.y, self.width, self.height);
}

#pragma mark - Y
- (CGFloat)y {
    return self.frame.origin.y;
}

- (void)setY:(CGFloat)y {
    self.frame = CGRectMake(self.x, y, self.width, self.height);
}

#pragma mark - Bottom
- (CGFloat)bottom {
    CGRect frame = self.frame;
    return frame.origin.y + frame.size.height;
}

@end
