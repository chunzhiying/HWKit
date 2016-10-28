//
//  HWViewHelper.h
//  HWKitDemo
//
//  Created by 陈智颖 on 2016/10/17.
//  Copyright © 2016年 YY. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface UIView (UIViewGeometryHelper)

@property (nonatomic) CGFloat width;
@property (nonatomic) CGFloat height;
@property (nonatomic) CGFloat x;
@property (nonatomic) CGFloat y;
@property (nonatomic, readonly) CGFloat bottom;

@end
