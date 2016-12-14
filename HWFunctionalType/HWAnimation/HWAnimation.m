//
//  HWAnimation.m
//  HWAnimationDemo
//
//  Created by 陈智颖 on 2016/12/14.
//  Copyright © 2016年 YY. All rights reserved.
//

#import "HWAnimation.h"
#import "NSArray+FunctionalType.h"
#import "CALayer+HWAnimation.h"

#define SafeBlock(atBlock, ...) \
    if(atBlock) { atBlock(__VA_ARGS__); }

#define SeparateSymbol @"_"

@interface HWAnimation () <CAAnimationDelegate>
{
    HWAnimationType _type;
    HWFillMode _fillMode;
    HWTimingFunctionType _timingFunction;
    CABasicAnimation *_basicAnimation;
    CAKeyframeAnimation *_keyFrameAnimation;
    CAAnimationGroup *_animationGroup;
}

@property (nonatomic, copy) finishedBlock block;

@end

@implementation HWAnimation

- (NSString *)keyPath {
    return  [NSString stringWithFormat:@"HWAnimation_%@", _keyPath];
}

- (CAAnimation *)animation {
    switch (_type) {
        case HW_Basic: return _basicAnimation;
        case HW_KeyFrame: return _keyFrameAnimation;
        case HW_Group: return _animationGroup;
    }
}

- (HWAnimation *(^)())run {
    return ^{
        [_layer addAnimation:self.animation forKey:self.keyPath];
        return self;
    };
}

- (HWAnimation *(^)())cancle {
    return ^{
        [_layer removeAnimationForKey:self.keyPath];
        return self;
    };
}

- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag {
    SafeBlock(_block, flag);
}

@end

@implementation HWAnimation (Base)

- (HWAnimation *(^)(HWAnimationType, NSString *))animate {
    return ^(HWAnimationType type, NSString *keyPath) {
        _type = type;
        self.keyPath = keyPath;
        switch (_type) {
            case HW_Basic:
                _basicAnimation = [CABasicAnimation animationWithKeyPath:keyPath];
                break;
            case HW_KeyFrame:
                _keyFrameAnimation = [CAKeyframeAnimation animationWithKeyPath:keyPath];
                break;
            default:
                break;
        }
        self.animation.delegate = self;
        return self;
    };
}

- (HWAnimation *(^)(finishedBlock))finish {
    return  ^(finishedBlock block) {
        _block = block;
        return self;
    };
}

- (HWAnimation *(^)(CALayer *))addTo {
    return ^(CALayer *layer) {
        [self shouldRetainLayer:layer];
        [layer addHWAnimation:self];
        return self;
    };
}

- (void)shouldRetainLayer:(CALayer *)layer {
    if (_fillMode != HW_FillMode_Retain) {
        return;
    }
    if (_type == HW_Group) {
        NSArray *keyPaths = [_keyPath componentsSeparatedByString:SeparateSymbol];
        keyPaths.justTail(keyPaths.count - 1).forEachWithIndex(^(NSString *keyPath, NSUInteger index) {
            CAAnimation *anim = [_animationGroup.animations objectAtIndex:index];
            if ([anim isKindOfClass:[CABasicAnimation class]] && [(CABasicAnimation *)anim toValue]) {
                [layer setValue:[(CABasicAnimation *)anim toValue] forKeyPath:keyPath];
            }
        });
    }
    if (_type == HW_Basic && _basicAnimation.toValue) {
        [layer setValue:_basicAnimation.toValue forKeyPath:_keyPath];
    }
}

#pragma mark -
- (HWAnimation *(^)(CFTimeInterval))duration {
    return ^(CFTimeInterval duration){
        self.animation.duration = duration;
        return self;
    };
}

- (HWAnimation *(^)(CFTimeInterval))beginTime {
    return ^(CFTimeInterval beginTime){
        self.animation.beginTime = beginTime;
        return self;
    };
}

- (HWAnimation *(^)(float))repeatCount {
    return ^(float repeatCount){
        self.animation.repeatCount = repeatCount;
        return self;
    };
}

- (HWAnimation *(^)(BOOL))removedOnCompletion {
    return ^(BOOL removedOnCompletion){
        self.animation.removedOnCompletion = removedOnCompletion;
        return self;
    };
}

#pragma mark -
- (HWAnimation *(^)(HWTimingFunctionType))timingFunction {
    return ^(HWTimingFunctionType timingFunction){
        _timingFunction = timingFunction;
        self.animation.timingFunction = [CAMediaTimingFunction functionWithName:
                                         [self transFromTimingFunction:timingFunction]];
        return self;
    };
}

- (HWAnimation *(^)(HWFillMode))fillMode {
    return ^(HWFillMode fillmode){
        _fillMode = fillmode;
        NSString *mode = kCAFillModeForwards;
        switch (fillmode) {
            case HW_FillMode_Both:
                mode = kCAFillModeBoth;
                break;
            case HW_FillMode_Forwards:
            case HW_FillMode_Retain:
                mode = kCAFillModeForwards;
                break;
            case HW_FillMode_Backwards:
                mode = kCAFillModeBackwards;
                break;
            case HW_FillMode_Removed:
                mode = kCAFillModeRemoved;
                break;
        }
        self.animation.removedOnCompletion = NO;
        self.animation.fillMode = mode;
        return self;
    };
}

- (NSString *)transFromTimingFunction:(HWTimingFunctionType)timingFunction {
    NSString *function = kCAMediaTimingFunctionDefault;
    switch (timingFunction) {
        case HW_TimingFunction_EaseIn:
            function = kCAMediaTimingFunctionEaseIn;
            break;
        case HW_TimingFunction_EaseOut:
            function = kCAMediaTimingFunctionEaseOut;
            break;
        case HW_TimingFunction_EaseInEaseOut:
            function = kCAMediaTimingFunctionEaseInEaseOut;
            break;
        case HW_TimingFunction_Linear:
            function = kCAMediaTimingFunctionLinear;
            break;
    }
    return function;
}

@end


@implementation HWAnimation (Basic_Extension)

- (HWAnimation *(^)(id))from {
    return ^(id value){
        _basicAnimation.fromValue = value;
        return self;
    };
}

- (HWAnimation *(^)(id))to {
    return ^(id value){
        _basicAnimation.toValue = value;
        return self;
    };
}

- (HWAnimation *(^)(id))by {
    return ^(id value){
        if ([value isKindOfClass:[NSNumber class]]) {
            _basicAnimation.toValue = @([(NSNumber *)value floatValue] + [(NSNumber *)_basicAnimation.fromValue floatValue]);
        } else {
            _basicAnimation.byValue = value;
        }
        return self;
    };
}

@end


@implementation HWAnimation (KeyFrame_Extension)

- (HWAnimation *(^)(NSArray *))values {
    return ^(NSArray *values){
        _keyFrameAnimation.values = values;
        return self;
    };
}

- (HWAnimation *(^)(NSArray<NSNumber *> *))keyTimes {
    return ^(NSArray<NSNumber *> *keyTimes){
        _keyFrameAnimation.keyTimes = keyTimes;
        return self;
    };
}

- (HWAnimation *(^)(CGPathRef))path {
    return ^(CGPathRef path) {
        _keyFrameAnimation.path = path;
        return self;
    };
}

- (HWAnimation *(^)(NSArray<NSNumber *> *))timingFunctions {
    return ^(NSArray<NSNumber *> *timingFunctions){
        _keyFrameAnimation.timingFunctions = timingFunctions.map(^(NSNumber *timingFunctionValue) {
            return  [CAMediaTimingFunction functionWithName:
                     [self transFromTimingFunction:[timingFunctionValue integerValue]]];
        });
        return self;
    };
}

@end


@implementation HWAnimation (AnimationGroup_Extension)

- (HWAnimation *(^)())animateGroup {
    return ^{
        _type = HW_Group;
        _animationGroup = [CAAnimationGroup animation];
        self.keyPath = @"group";
        self.animation.delegate = self;
        return self;
    };
}

- (HWAnimation *(^)(NSArray<HWAnimation *> *))animations {
    return ^(NSArray<HWAnimation *> *animations){
        [(CAAnimationGroup *)self.animation setAnimations:animations
         .map(^(HWAnimation *animation) {
            _keyPath = [NSString stringWithFormat:@"%@%@%@", _keyPath, SeparateSymbol, animation->_keyPath];
            return animation.animation;
        })];
        return self;
    };
}

@end


@implementation NSArray (HWAnimation_Extension)

- (HWAnimation *)animationGroup {
    return [HWAnimation new]
    .animateGroup()
    .animations(self.filter(^(NSObject *object) {
        return @([object isKindOfClass:[HWAnimation class]]);
    }));
}

@end
