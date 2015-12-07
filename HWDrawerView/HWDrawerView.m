//
//  HWDrawerView.m
//  DrawerDemo
//
//  Created by 陈智颖 on 15/12/2.
//  Copyright © 2015年 YY. All rights reserved.
//

#import "HWDrawerView.h"

#define DrawerDeepRatio 0.6
#define DrawerOpenX (DrawerDeepRatio * [UIScreen mainScreen].bounds.size.width)
#define DrawerOpenMiddleX (DrawerOpenX / 2)

#define DrawerScale 0.9
#define DrawerScalePerX ((1 - DrawerScale) / DrawerOpenX)

#define AutoAnimDuration 0.3

@interface HWDrawerView () <UIGestureRecognizerDelegate> {
    UIView *_topView;
    UIView *_bottomView;
    
    CGFloat _beginOffsetX;
}

@end

@implementation HWDrawerView

- (instancetype)initWithFrame:(CGRect)frame andBottomView:(UIView *)bottomView andTopView:(UIView *)topView{
    self = [super initWithFrame:frame];
    if (self) {
        _beginOffsetX = 0;
        
        CGRect rect = CGRectMake(0, 0, frame.size.width, frame.size.height);
        
        _topView = topView;
        _bottomView = bottomView;
        
        _topView.frame = rect;
        _bottomView.frame = rect;
        
        [self addSubview:_bottomView];
        [self addSubview:_topView];
        
        UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(onPanStart:)];
        [_topView addGestureRecognizer:pan];
        
    }
    return self;
}

- (void)drawRect:(CGRect)rect {
    [super drawRect:rect];
    
    _topView.layer.shadowOffset = CGSizeMake(0, 0);
    _topView.layer.shadowRadius = 10.0f;
    _topView.layer.shadowColor = [UIColor blackColor].CGColor;
    _topView.layer.shadowOpacity = 1;
}

- (void)onPanStart:(UIPanGestureRecognizer *)gesture {
    CGPoint contentOff = [gesture translationInView:gesture.view];
    CGFloat scaleOff = 1 - _topView.frame.origin.x * DrawerScalePerX;
    
    switch (gesture.state) {
        case UIGestureRecognizerStateBegan:
            break;
        case UIGestureRecognizerStateChanged:
        {
            if (_topView.frame.origin.x <= 0 && contentOff.x < 0 ) {
                _topView.transform = CGAffineTransformScale(CGAffineTransformMakeTranslation(0, 0), 1, 1);
                return;
            }
            if (_topView.frame.origin.x >= DrawerOpenX && contentOff.x > 0) {
                _topView.transform = CGAffineTransformScale(CGAffineTransformMakeTranslation(DrawerOpenX, 0), DrawerScale, DrawerScale);
                return;
            }
            _topView.transform = CGAffineTransformScale(CGAffineTransformMakeTranslation(_beginOffsetX + contentOff.x, 0), scaleOff, scaleOff);
            break;
        }
        default:
        {
            if (_topView.frame.origin.x >= DrawerOpenMiddleX) {
                [UIView animateWithDuration:AutoAnimDuration animations:^{
                    _topView.transform = CGAffineTransformScale(CGAffineTransformMakeTranslation(DrawerOpenX, 0), DrawerScale, DrawerScale);
                }];
                _beginOffsetX = DrawerOpenX;
            } else {
                [UIView animateWithDuration:AutoAnimDuration animations:^{
                    _topView.transform = CGAffineTransformScale(CGAffineTransformMakeTranslation(0, 0), 1, 1);
                }];
                _beginOffsetX = 0;
            }
            break;
        }
    }
    
}

@end
