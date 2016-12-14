//
//  CALayer+HWAnimation.h
//  HWAnimationDemo
//
//  Created by 陈智颖 on 2016/12/14.
//  Copyright © 2016年 YY. All rights reserved.
//

#import "HWAnimation.h"
#import "NSArray+FunctionalType.h"

@interface CALayer (HWAnimation)

- (void)addHWAnimation:(HWAnimation *)anim;
- (void)removeHWAnimation:(HWAnimation *)anim;

@end
