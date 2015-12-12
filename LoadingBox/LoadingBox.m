//
//  LoadingBox.m
//  yyfe
//
//  Created by chenzy on 15/7/21.
//  Copyright (c) 2015年 yy.com. All rights reserved.
//

#import "LoadingBox.h"

static int LoadingBoxWide = 150;
static int LoadingBoxHeight = 100;

@interface LoadingBox(){
    
    __weak IBOutlet UIActivityIndicatorView *_activityIndicator;
    __weak IBOutlet UILabel *_loadingTxt;
    UIView *_containerView;
    
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
    
    if (!_isHide) {
        return;
    }
    
    self.frame = CGRectMake(0, 0, LoadingBoxWide, LoadingBoxHeight);
    _loadingTxt.text = str;
    [_activityIndicator startAnimating];
    
    _containerView = [[UIView alloc] initWithFrame:CGRectMake((parentView.frame.size.width - LoadingBoxWide)/2, (parentView.frame.size.height - LoadingBoxHeight)/2 - 50, LoadingBoxWide, LoadingBoxHeight)];
    
    _containerView.backgroundColor = [UIColor blackColor];
    _containerView.alpha = 0.7;
    _containerView.layer.cornerRadius = 5.f;
    _containerView.layer.masksToBounds = YES;
    
    [_containerView addSubview:self];
    [parentView addSubview:_containerView];
    
    self.isHide = NO;
    
    if (time <= 0) {
        return;
    }
    
    NSTimer *timer = [NSTimer timerWithTimeInterval:time target:self selector:@selector(timeOut) userInfo:nil repeats:NO];
    [[NSRunLoop currentRunLoop] addTimer:timer forMode:NSRunLoopCommonModes];
}

- (void)hide{
    
    if (_containerView == nil) {
        return;
    }
    
    __weak __typeof(self)weakSelf = self;
    
    [UIView animateWithDuration:0.3 animations:^{
        _containerView.alpha = 0;
        
    } completion:^(BOOL finish){
        if (weakSelf) {
            __strong __typeof(weakSelf)strongSelf = weakSelf;
            [strongSelf->_containerView removeFromSuperview];
            strongSelf ->_containerView = nil;
            strongSelf.isHide = YES;
        }
    }];
}


- (void)timeOut {
    
    [self hide];
    
    if (_delegate && [_delegate respondsToSelector:@selector(loadingBoxTimeOut)]) {
        [_delegate loadingBoxTimeOut];
    }
    
}

@end
