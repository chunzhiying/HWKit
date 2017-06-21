//
//  NetDisconnectView.h
//  yyfe
//
//  Created by linmeihui on 15/11/11.
//  Copyright © 2015年 yy.com. All rights reserved.
//

#import <UIKit/UIKit.h>

@class NetDisconnectView;

typedef void(^RetryResultBlock)();

@protocol NetDisconnectViewDelegate <NSObject>

- (void)retryConnect:(NetDisconnectView*)disconnectView withCompleted:(RetryResultBlock)block;

@end


@interface NetDisconnectView : UIView

@property (nonatomic, weak) id<NetDisconnectViewDelegate>delegate;

+ (NetDisconnectView *)addNetDisConnectViewIn:(UIView*)parentView delegate:(id<NetDisconnectViewDelegate>)delegate;
@end
