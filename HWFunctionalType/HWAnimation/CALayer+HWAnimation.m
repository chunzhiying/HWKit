//
//  CALayer+HWAnimation.m
//  HWAnimationDemo
//
//  Created by 陈智颖 on 2016/12/14.
//  Copyright © 2016年 YY. All rights reserved.
//

#import "CALayer+HWAnimation.h"

#define HWAnimationsKey @"HWAnimations"

@implementation CALayer (HWAnimation)

- (void)addHWAnimation:(HWAnimation *)anim {
    anim.layer = self;
    NSMutableArray *animations = [[NSMutableArray alloc] initWithArray:[self valueForKey:HWAnimationsKey]];
    [animations addObject:anim];
    [self setValue:animations forKey:HWAnimationsKey];
}

- (void)removeHWAnimation:(HWAnimation *)anim {
    anim.cancle();
    NSMutableArray *animations = [[NSMutableArray alloc] initWithArray:[self valueForKey:HWAnimationsKey]];
    [animations removeObject:anim];
    [self setValue:animations forKey:HWAnimationsKey];
}

@end


