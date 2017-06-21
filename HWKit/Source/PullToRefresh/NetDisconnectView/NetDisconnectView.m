//
//  NetDisconnectView.m
//  yyfe
//
//  Created by linmeihui on 15/11/11.
//  Copyright © 2015年 yy.com. All rights reserved.
//

#import "NetDisconnectView.h"
#import "ATNetworkInfo.h"
#import "HWHelper.h"

@interface NetDisconnectView () {
    __weak IBOutlet UILabel *_requestingTips;
}
@end

@implementation NetDisconnectView

+ (NetDisconnectView *)addNetDisConnectViewIn:(UIView*)parentView delegate:(id<NetDisconnectViewDelegate>)delegate
{
    if ([parentView.subviews.lastObject isKindOfClass:[NetDisconnectView class]]) {
        return parentView.subviews.lastObject;
    }
    
    NSBundle *bundle = [NSBundle bundleWithPath:[[NSBundle mainBundle] pathForResource:@"HWKitBundle" ofType:@"bundle"]];
    NetDisconnectView *disconnectView = [[bundle loadNibNamed:@"NetDisconnectView" owner:nil options:nil] objectAtIndex:0];
    
    disconnectView.frame = parentView.bounds;
    disconnectView.delegate = delegate;
    disconnectView.hidden = YES;
    [parentView addSubview:disconnectView];
    
    [[NSNotificationCenter defaultCenter] addObserver:disconnectView selector:@selector(onNetWorkStateChanged:) name:ATNetworkStateNotification object:nil];
    
    return disconnectView;
}

- (IBAction)retryButtonClicked:(id)sender
{
    [self requestRetry];
}

- (void)onNetWorkStateChanged:(NSNotification*)notify
{
    if (notify.userInfo == nil) {
        return;
    }
    
    ATNetworkState state = [notify.userInfo[ATNetworkStateNotificationUserInfoKeyState] intValue];
    switch (state) {
        case ATNetworkStateNotReachable:
            self.hidden = NO;
            break;
        case ATNetworkStateReachableViaWiFi:
        case ATNetworkStateReachableViaWWAN:
            if (self.hidden == NO) {
                [self requestRetry];
            }
            break;
        default: break;
    }
}

- (void)setRequestFinished:(BOOL)isFinished {
    _requestingTips.hidden = isFinished ? YES : NO;
}

- (void)requestRetry
{
    [self setRequestFinished:NO];
    if (_delegate && [_delegate respondsToSelector:@selector(retryConnect:withCompleted:)]) {
        
        ATWeakify(self)
        [self.delegate retryConnect:self withCompleted:^{
            ATStrongify(self)
            [self setRequestFinished:YES];
        }];
    }
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
