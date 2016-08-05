//
//  LoadingBox.m
//  yyfe
//
//  Created by chenzy on 15/7/21.
//  Copyright (c) 2015年 yy.com. All rights reserved.
//

#import "LoadingBox.h"

#define LoadingBoxWide 150
#define LoadingBoxHeight 100


@interface LoadingBox(){
    
    __weak IBOutlet UIActivityIndicatorView *_activityIndicator;
    __weak IBOutlet UILabel *_loadingTxt;
    UIView *_containerView;
    NSTimer *_timer;
}

@end

@implementation LoadingBox

- (instancetype)init{
    self = [super init];
    if (self) {
        self = [[[NSBundle mainBundle] loadNibNamed:@"LoadingBox" owner:nil options:nil] lastObject];
        _isHide = YES;
    }
    return self;
}

- (instancetype)initWithDelegate:(id<LoadingBoxDelegate>)delegate {
    self = [self init];
    if (self) {
        _delegate = delegate;
    }
    return self;
}

- (void)showInView:(UIView*)parentView withText:(NSString *)str {
    [self showInView:parentView withText:str withWaitingTime:0];
}

- (void)showInView:(UIView *)parentView withText:(NSString *)str withWaitingTime:(NSTimeInterval)time {
    
    [self removeSelf];
    
    self.frame = CGRectMake(0, 0, LoadingBoxWide, LoadingBoxHeight);
    _loadingTxt.text = str;
    [_activityIndicator startAnimating];
    
    _containerView = [[UIView alloc] initWithFrame:CGRectMake((parentView.frame.size.width - LoadingBoxWide) / 2,
                                                              (parentView.frame.size.height - LoadingBoxHeight) / 2 - 50,
                                                              LoadingBoxWide, LoadingBoxHeight)];
    
    _containerView.backgroundColor = [UIColor blackColor];
    _containerView.alpha = 0.7;
    _containerView.layer.cornerRadius = 5.f;
    _containerView.layer.masksToBounds = YES;
    
    [_containerView addSubview:self];
    [parentView addSubview:_containerView];
    
    _isHide = NO;
    
    if (time > 0) {
        [self addTimerWaiting:time];
    }
}

- (void)hide {
    
    [self invalidateTimer];
    if (_containerView == nil || _isHide) {
        return;
    }
    _isHide = YES;
    
    [UIView animateWithDuration:0.3 animations:^{
        _containerView.alpha = 0;
        
    } completion:^(BOOL finish){
        [self removeSelf];
        
    }];
}

- (void)removeSelf {
    [_containerView removeFromSuperview];
    _containerView = nil;
    [self invalidateTimer];
}

#pragma mark - Timer
- (void)addTimerWaiting:(NSTimeInterval)time {
    [self invalidateTimer];
    _timer = [NSTimer timerWithTimeInterval:time target:self selector:@selector(timeOut) userInfo:nil repeats:NO];
    [[NSRunLoop currentRunLoop] addTimer:_timer forMode:NSRunLoopCommonModes];
}

- (void)invalidateTimer {
    if (_timer) {
        [_timer invalidate];
        _timer = nil;
    }
}

- (void)timeOut {
    
    [self hide];
    
    if (_delegate && [_delegate respondsToSelector:@selector(loadingBoxTimeOut)]) {
        [_delegate loadingBoxTimeOut];
    }
}

@end
