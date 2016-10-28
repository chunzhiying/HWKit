//
//  HWGradualChangeHeaderView.m
//  HWKitDemo
//
//  Created by 陈智颖 on 2016/10/27.
//  Copyright © 2016年 YY. All rights reserved.
//

#import "HWGradualChangeHeaderView.h"
#import "UIView+RxObserver.h"
#import "HWHelper.h"

@interface HWGradualChangeHeaderView ()
{
    CGFloat _originalY;
    CGFloat _maxHeight;
    CGFloat _minHeight;
    CGFloat _linkViewOriginalHeight;
}

@property (nonatomic, strong) UIView *mainView;
@property (nonatomic, strong) UIView *anotherView;
@property (nonatomic, weak) UIView<HWScrollable> *linkView;

@end

@implementation HWGradualChangeHeaderView

- (instancetype)initWithFrame:(CGRect)frame
                         main:(UIView *)main another:(UIView *)another
                         link:(UIView<HWScrollable> *)link
{
    self = [super initWithFrame:frame];
    if (self) {
        self.clipsToBounds = YES;
        _mainView = main;
        _anotherView = another;
        _linkView = link;
        _downType = HWGCDown_Scale;
        _upType = HWGCUp_Alpha;
        [self initView];
        [self bindData];
    }
    return self;
}

- (void)initView {
    _originalY = self.y;
    _maxHeight = _mainView.bounds.size.height;
    _minHeight = _anotherView.bounds.size.height;
    _linkViewOriginalHeight = _linkView.bounds.size.height;
    
    _mainView.layer.anchorPoint = CGPointMake(0.5, 0);
    _mainView.frame = _mainView.bounds;
    _anotherView.frame = _anotherView.bounds;
    _anotherView.alpha = 0;
    
    self.backgroundColor = [UIColor yellowColor];
    [self addSubview:_mainView];
    [self addSubview:_anotherView];
}

- (void)bindData {
    
    __block CGFloat lastOffsetY = 0;
    
    self.Rx(@"frame").distinctUntilChanged()
    .subscribe(^(NSValue *frameValue) {
        CGFloat height = [frameValue CGRectValue].size.height;
        _anotherView.alpha = MAX(0, MIN(1, (_maxHeight * 1.0 - height) / (_maxHeight - _minHeight)));
    })
    .filter(^(NSValue *frameValue){
        CGFloat height = [frameValue CGRectValue].size.height;
        return @(height <= _maxHeight);
    })
    .subscribe(^(NSValue *frameValue) {
        [self executeUpAnimation];
    })
    .map(^(NSValue *frameValue) {
        CGFloat height = [frameValue CGRectValue].size.height;
        return [NSValue valueWithCGRect:CGRectMake(self.linkView.x, height + _originalY,
                                                   self.linkView.width,
                                                   _linkViewOriginalHeight + (_maxHeight - height))];
    }).bindTo(_linkView, @"frame");
    

    _linkView.Rx(@"contentOffset")
    .subscribe(^(NSValue *contentOffset)
    {
        CGFloat offsetY = [contentOffset CGPointValue].y;
        CGFloat currentHeight = self.frame.size.height;

        CGFloat changeY = offsetY - lastOffsetY;
        lastOffsetY = offsetY;
        
        self.y = _originalY;
        
        if (offsetY == 0) {
            return;
        }
        
        if (offsetY < 0 && currentHeight >= _maxHeight) {
            [self executeDownAnimationWithOffsetY:offsetY];
            self.height = _maxHeight - offsetY;
            return;
        }
        
        if ((offsetY > 0 && currentHeight <= _minHeight)) {
            self.height = _minHeight;
            return;
        }
        
        _linkView.contentOffset = CGPointMake(0, 0);
        self.height = currentHeight - changeY;
    });
    
    self.height = _maxHeight;
}

- (void)executeDownAnimationWithOffsetY:(CGFloat)offsetY {
    switch (_downType) {
        case HWGCDown_Scale:
        {
            CGFloat scale = self.height * 1.0 / _maxHeight;
            _mainView.transform = CGAffineTransformMakeScale(scale * scale, scale * scale);
            break;
        }
        case HWGCDown_Move:
            _mainView.layer.position = CGPointMake(_mainView.width / 2, -offsetY);
            break;
    }
    _mainView.alpha = 1;
}

- (void)executeUpAnimation {
    
    switch (_upType) {
        case HWGCUp_Move:
            _mainView.y = self.height - _maxHeight;
            break;
        
        case HWGCUp_Alpha:
            _mainView.alpha = 1 - (_maxHeight * 1.0 - self.height) / _maxHeight;
            break;
        
        case HWGCUp_Static:
            _mainView.frame = _mainView.bounds;
            break;
    }
}

@end
