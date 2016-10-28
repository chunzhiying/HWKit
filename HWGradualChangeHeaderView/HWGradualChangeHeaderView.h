//
//  HWGradualChangeHeaderView.h
//  HWKitDemo
//
//  Created by 陈智颖 on 2016/10/27.
//  Copyright © 2016年 YY. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum : NSUInteger {
    HWGCDown_Scale,
    HWGCDown_Move,
} HWGCDownType;

typedef enum : NSUInteger {
    HWGCUp_Move,
    HWGCUp_Static,
    HWGCUp_Alpha,
} HWGCUpType;


@protocol HWScrollable <NSObject>

@required @property (nonatomic) CGPoint contentOffset;

@end


@interface HWGradualChangeHeaderView : UIView

@property (nonatomic) HWGCDownType downType; //default: Scale
@property (nonatomic) HWGCUpType upType;     //default: Alpha

- (instancetype)initWithFrame:(CGRect)frame
                         main:(UIView *)main another:(UIView *)another
                         link:(UIView<HWScrollable> *)link;

@end
